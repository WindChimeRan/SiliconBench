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

CONCURRENCY_ARG=$(echo $CONCURRENCY_LEVELS | tr ' ' ',')

# Bump context window for agent split — prompts reach ~8.8K tokens.
# llamacpp's --parallel 4 divides ctx across slots, so 65536 = 16384/slot.
if [ "$SPLIT" = "agent" ]; then
    export DGX_VLLM_MAX_MODEL_LEN=16384
    export LLAMACPP_CTX_SIZE=65536
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

    # Start server
    echo "Starting $name server..."
    bash "$SCRIPT_DIR/$serve"
    echo ""

    # Run benchmark
    MODEL_FLAG=""
    if [ -n "$model_override" ]; then
        MODEL_FLAG="--model $model_override"
    fi

    RUN_TS=$(date +%Y%m%d_%H%M%S)
    BENCH_OUT="$SPLIT_RESULTS_DIR/${name}_${RUN_TS}.json"
    OUTPUTS_OUT="$SPLIT_RESULTS_DIR/${name}_${RUN_TS}_outputs.jsonl"

    python "$SCRIPT_DIR/benchmark.py" \
        --framework "$name" \
        --port "$port" \
        --concurrency "$CONCURRENCY_ARG" \
        --requests "$BENCHMARK_REQUESTS" \
        --warmup "$WARMUP_REQUESTS" \
        --output "$BENCH_OUT" \
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
