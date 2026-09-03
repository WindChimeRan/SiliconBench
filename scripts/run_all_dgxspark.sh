#!/bin/bash
# SiliconBench — Run full benchmark across DGX Spark frameworks (llama.cpp,
# vllm, sglang; all CUDA builds). Independent sibling of run_all_apple.sh —
# no shared control flow, no metalstat sidecar (Apple-only).
# Usage: bash scripts/run_all_dgxspark.sh [--model MODEL] [--split SPLIT] [--skip-existing] [framework ...]
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse flags before sourcing config
ONLY_FRAMEWORKS=()
SPLIT="chat"
SKIP_EXISTING=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --model)
            export APPLEBENCH_MODEL="$2"
            shift 2
            ;;
        --split)
            SPLIT="$2"
            shift 2
            ;;
        --skip-existing)
            SKIP_EXISTING=true
            shift
            ;;
        *)
            ONLY_FRAMEWORKS+=("$1")
            shift
            ;;
    esac
done

source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

BENCH_VENV="$VENVS_DIR/bench"

# Pre-flight check
bash "$SCRIPT_DIR/env_check_dgxspark.sh"
echo ""

# Auto-create bench venv if missing (shared, platform-agnostic — benchmark.py/
# collect_results.py/generate_report.py are pure Python HTTP clients)
if [ ! -d "$BENCH_VENV" ]; then
    echo "Bench venv not found — installing..."
    bash "$SCRIPT_DIR/install_bench.sh"
fi

source "$BENCH_VENV/bin/activate"
export PYTHONUNBUFFERED=1

# Hard cleanup: kill any leftover inference processes from this platform's
# frameworks only.
cleanup() {
    echo "  Cleaning up all inference processes..."
    pkill -f llama-server 2>/dev/null || true
    pkill -f "vllm serve" 2>/dev/null || true
    pkill -f "sglang.launch_server" 2>/dev/null || true
    sleep 5  # let processes die and release memory
}

# Frameworks to benchmark: name, port, serve_script, stop_script, model_override
FRAMEWORKS=(
    "llamacpp:$LLAMACPP_PORT:dgxspark/serve_llamacpp.sh:dgxspark/stop_llamacpp.sh:"
    "vllm:$VLLM_PORT:dgxspark/serve_vllm.sh:dgxspark/stop_vllm.sh:"
    "sglang:$SGLANG_PORT:dgxspark/serve_sglang.sh:dgxspark/stop_sglang.sh:$HF_MODEL"
)

# llama.cpp serves at most --parallel requests concurrently; anything beyond
# that queues (huge TTFT) and can't batch. Set it to the max concurrency
# tested so the comparison against vllm/sglang is apples-to-apples. Note -c is
# the TOTAL context shared across slots, so size it as parallel × per-slot to
# keep each concurrent request's room constant as --parallel grows. Memory is
# not a constraint on GB10 (128 GB unified; Gemma also uses sliding-window
# attention, so its KV stays small even at large ctx).
export LLAMACPP_PARALLEL=16
if [ "$SPLIT" = "agent" ]; then
    export DGX_VLLM_MAX_MODEL_LEN=16384
    export LLAMACPP_CTX_SIZE=$((LLAMACPP_PARALLEL * 16384))  # 16384/slot — agent prompts reach ~8.8K tokens
else
    export LLAMACPP_CTX_SIZE=$((LLAMACPP_PARALLEL * 8192))   # 8192/slot — chat prompts reach ~4K tokens
fi

# Per-split output directory: results/<MODEL>/dgxspark/<split>/
SPLIT_RESULTS_DIR="$RESULTS_DIR/$SPLIT"
mkdir -p "$SPLIT_RESULTS_DIR"

echo "========================================="
echo " SiliconBench — DGX Spark Benchmark Run"
echo " Model: $MODEL_NAME"
echo " Split: $SPLIT"
echo " Output: $SPLIT_RESULTS_DIR"
echo " Skip-existing: $SKIP_EXISTING"
echo " $(date)"
echo "========================================="
echo ""

# Clean old result files so comparison.json reflects this run only
# (skipped in resume mode so prior successful frameworks stay intact)
if [ "$SKIP_EXISTING" = "false" ]; then
    echo "Cleaning old result files..."
    rm -f "$SPLIT_RESULTS_DIR"/*_*.json "$SPLIT_RESULTS_DIR"/*_outputs.jsonl "$SPLIT_RESULTS_DIR/comparison.json"
    rm -rf "$SPLIT_RESULTS_DIR/.levels"
else
    echo "Resume mode — keeping existing results."
fi

# Initial cleanup
cleanup

for entry in "${FRAMEWORKS[@]}"; do
    IFS=':' read -r name port serve stop model_override <<< "$entry"

    # Skip if user specified frameworks and this isn't one of them
    if [ ${#ONLY_FRAMEWORKS[@]} -gt 0 ]; then
        match=false
        for f in "${ONLY_FRAMEWORKS[@]}"; do
            [ "$f" = "$name" ] && match=true
        done
        $match || continue
    fi

    # Skip if --skip-existing and a result file from the last 24h exists
    if [ "$SKIP_EXISTING" = "true" ]; then
        recent=$(find "$SPLIT_RESULTS_DIR" -maxdepth 1 -name "${name}_*.json" -mtime -1 2>/dev/null | head -1)
        if [ -n "$recent" ]; then
            echo "Skipping $name — recent result exists: $(basename "$recent")"
            continue
        fi
    fi

    echo "==========================================="
    echo " Benchmarking: $name (port $port)"
    echo "==========================================="

    # Run benchmark
    MODEL_FLAG=""
    if [ -n "$model_override" ]; then
        MODEL_FLAG="--model $model_override"
    fi

    # Shared timestamp so the benchmark JSON and the outputs sidecar share a
    # suffix. Fixed once per framework: the per-level loop below must write
    # every level under the same stem.
    RUN_TS=$(date +%Y%m%d_%H%M%S)
    BENCH_OUT="$SPLIT_RESULTS_DIR/${name}_${RUN_TS}.json"
    OUTPUTS_OUT="$SPLIT_RESULTS_DIR/${name}_${RUN_TS}_outputs.jsonl"

    # Per-level parts live in a subdirectory, not next to the results. A part
    # left behind by a skipped merge is itself a valid one-level result file,
    # and collect_results.py globs this directory — it would pick the part up
    # and publish a single level as the framework's arm for the whole run.
    LEVEL_DIR="$SPLIT_RESULTS_DIR/.levels"
    mkdir -p "$LEVEL_DIR"

    LEVEL_PARTS=()
    LEVEL_FAILED=false

    # One server per concurrency level, so each level is an independent
    # cold-start measurement. Levels sharing a server share its caches, and on
    # this platform every engine caches prefixes by default: vllm's automatic
    # prefix caching, sglang's RadixAttention, llama.cpp's per-slot prompt
    # reuse. On the agent split, whose prompts repeat, level 1 then warms the
    # cache that later levels hit and the levels stop being independent
    # measurements. Costs one server start per level.
    for LEVEL_ARG in $CONCURRENCY_LEVELS; do
    LEVEL_OUT="$LEVEL_DIR/${name}_${RUN_TS}_level_${LEVEL_ARG//,/_}.json"

    # Start server. Guarded: under `set -e`, an unguarded non-zero exit here
    # (server never becomes ready — bad build, unsupported model arch, port
    # conflict, etc.) would otherwise kill this whole script and silently
    # skip every remaining framework, not just this one.
    echo "Starting $name server (concurrency $LEVEL_ARG)..."
    if ! bash "$SCRIPT_DIR/$serve"; then
        echo "ERROR: $name server failed to start — skipping remaining levels"
        cleanup
        echo "Cooling down for ${COOLDOWN_SECONDS}s..."
        sleep "$COOLDOWN_SECONDS"
        echo ""
        LEVEL_FAILED=true
        break
    fi
    echo ""

    python "$SCRIPT_DIR/benchmark.py" \
        --framework "$name" \
        --port "$port" \
        --concurrency "$LEVEL_ARG" \
        --requests "$BENCHMARK_REQUESTS" \
        --warmup "$WARMUP_REQUESTS" \
        --output "$LEVEL_OUT" \
        --outputs "$OUTPUTS_OUT" \
        --split "$SPLIT" \
        $MODEL_FLAG || true
    echo ""

    # Stop server gracefully
    echo "Stopping $name server..."
    bash "$SCRIPT_DIR/$stop"

    # Hard cleanup — kill orphans, release GPU memory
    cleanup

    # Cooldown — let GPU thermals and memory settle
    echo "Cooling down for ${COOLDOWN_SECONDS}s..."
    sleep "$COOLDOWN_SECONDS"
    echo ""

    LEVEL_PARTS+=("$LEVEL_OUT")
    done   # per-level loop

    # Stitch the per-level files back into the one-file-per-framework shape the
    # rest of the pipeline expects. The merged run_config records that the
    # levels did not share a server.
    if [ "$LEVEL_FAILED" = "true" ]; then
        echo "  $name: stopped early — a level's server failed to start"
    fi
    # Merge the levels that produced a file. A missing part means that level
    # died; keeping the levels that did run beats discarding them, and
    # run_config.concurrency_levels records which those were. Guarded: an
    # unguarded merge failure would take the whole script down under `set -e`
    # and skip every remaining framework.
    PRESENT_PARTS=()
    MISSING_PARTS=()
    for part in "${LEVEL_PARTS[@]}"; do
        if [ -s "$part" ]; then
            PRESENT_PARTS+=("$part")
        else
            MISSING_PARTS+=("$(basename "$part")")
        fi
    done
    if [ ${#MISSING_PARTS[@]} -gt 0 ]; then
        echo "  ⚠ $name produced no result for: ${MISSING_PARTS[*]}"
    fi
    if [ ${#PRESENT_PARTS[@]} -eq 0 ]; then
        echo "  no levels completed for $name — no result file written"
    elif ! python "$SCRIPT_DIR/merge_levels.py" --output "$BENCH_OUT" "${PRESENT_PARTS[@]}"; then
        echo "  ⚠ merge failed for $name — no result file written"
        rm -f "$BENCH_OUT"
    fi
    # Always drop the parts, merged or not: a stray part is a valid one-level
    # result file that the next collect_results would adopt as this
    # framework's arm.
    if [ ${#LEVEL_PARTS[@]} -gt 0 ]; then
        rm -f "${LEVEL_PARTS[@]}"
    fi
done

echo "==========================================="
echo " Collecting results and generating report"
echo "==========================================="
python "$SCRIPT_DIR/collect_results.py" --results-dir "$SPLIT_RESULTS_DIR" --model-name "$MODEL_NAME"
python "$SCRIPT_DIR/generate_report.py" --results-dir "$SPLIT_RESULTS_DIR"

echo ""
echo "========================================="
echo " SiliconBench (DGX Spark) complete!"
echo "========================================="
