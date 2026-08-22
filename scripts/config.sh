#!/bin/bash
# SiliconBench configuration — sourced by all scripts

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRAMEWORKS_DIR="$PROJECT_DIR/.frameworks"
VENVS_DIR="$PROJECT_DIR/.venvs"
MODELS_DIR="$PROJECT_DIR/.models"
RESULTS_BASE_DIR="$PROJECT_DIR/results"
SCRIPTS_DIR="$PROJECT_DIR/scripts"

# Ports (one per framework)
LLAMACPP_PORT=8001
MLX_LM_PORT=8002
MISTRALRS_PORT=8003
VLLM_METAL_PORT=8004
OMLX_PORT=8005
OLLAMA_PORT=8006
VLLM_MLX_PORT=8008
HF_TRANSFORMERS_PORT=8009
SGLANG_PORT=8010

# Model profile — set APPLEBENCH_MODEL env var to switch models
# Default: qwen3-0.6b. See models/*.sh for available profiles.
APPLEBENCH_MODEL="${APPLEBENCH_MODEL:-qwen3-0.6b}"
MODEL_PROFILE="$PROJECT_DIR/models/${APPLEBENCH_MODEL}.sh"
if [ ! -f "$MODEL_PROFILE" ]; then
    echo "Error: model profile not found: $MODEL_PROFILE"
    echo "Available profiles:"
    ls "$PROJECT_DIR/models/"*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh$//'
    exit 1
fi
source "$MODEL_PROFILE"

# Derived model paths
GGUF_MODEL="$MODELS_DIR/$GGUF_FILE"
MLX_MODEL="$MODELS_DIR/$MLX_DIR_NAME"
HF_MODEL="$MODELS_DIR/$HF_DIR_NAME"
# APPLEBENCH_RESULTS_SUBDIR scopes results to one machine within the apple
# track: results/<MODEL>/<subdir>/<split>/. It is now derived from the hardware
# rather than remembered, because forgetting it was destructive, not merely
# untidy — run_all deletes stale results in the active split dir at startup, so
# a bare run on a second Apple machine wipes the first machine's tree in place.
# That is exactly what happened on 2026-08-21, and the machine-provenance guard
# added in b1e3f62 could not catch it: that guard only blocks a KNOWN-DIFFERENT
# chip, and the legacy files predate the "machine" field it reads.
#
# Only a real M2 Max resolves to the legacy root results/<MODEL>/<split>/, which
# is the tree the site renders under its "Apple M2 Max" tab. Every other
# machine — recognised or not — gets its own subdir. An unrecognised host
# therefore lands somewhere harmless and visibly empty rather than on top of
# someone else's data: the failure mode is a missing tab, not lost results.
#
# An explicit APPLEBENCH_RESULTS_SUBDIR always wins, including an empty value,
# which forces the legacy root. No effect on dgxspark, which overrides
# RESULTS_DIR in config_dgxspark.sh after sourcing this file.
if [ -z "${APPLEBENCH_RESULTS_SUBDIR+set}" ]; then
    if [ "$(uname -s)" = "Darwin" ]; then
        _ab_chip="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "")"
        case "$_ab_chip" in
            "Apple M2 Max")
                # The original host: legacy layout, no subdir.
                APPLEBENCH_RESULTS_SUBDIR="" ;;
            "")
                APPLEBENCH_RESULTS_SUBDIR="unknown-apple" ;;
            *)
                # "Apple M5 Pro" -> "m5pro", "Apple M3 Ultra" -> "m3ultra".
                APPLEBENCH_RESULTS_SUBDIR="$(echo "$_ab_chip" \
                    | tr '[:upper:]' '[:lower:]' | sed -e 's/^apple //' -e 's/[^a-z0-9]//g')" ;;
        esac
        unset _ab_chip
    else
        APPLEBENCH_RESULTS_SUBDIR=""
    fi
fi
export APPLEBENCH_RESULTS_SUBDIR
RESULTS_DIR="$RESULTS_BASE_DIR/$MODEL_NAME${APPLEBENCH_RESULTS_SUBDIR:+/$APPLEBENCH_RESULTS_SUBDIR}"
mkdir -p "$RESULTS_DIR" 2>/dev/null || true
# Fallback only — model profiles should set OLLAMA_MODEL_NAME explicitly
# (to an ollama registry tag like qwen3:0.6b-fp16). The older derived form
# built a lowercase-<model>-bf16 tag used with a bare-FROM Modelfile, which
# produced a broken chat template for Qwen3.
OLLAMA_MODEL_NAME="${OLLAMA_MODEL_NAME:-$(echo "$MODEL_NAME" | tr '[:upper:]' '[:lower:]')-bf16}"

# Benchmark
CONCURRENCY_LEVELS="1 8 16"
COOLDOWN_SECONDS="${COOLDOWN_SECONDS:-60}"   # env-overridable; bump (e.g. 120) on hot/throttling hosts
WARMUP_REQUESTS=3
BENCHMARK_REQUESTS=100  # per concurrency level

# Ensure directories exist
mkdir -p "$FRAMEWORKS_DIR" "$VENVS_DIR" "$MODELS_DIR" "$RESULTS_BASE_DIR" "$RESULTS_DIR"
