#!/bin/bash
# Start vllm-metal server
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

VENV_DIR="$HOME/.venv-vllm-metal"

if [ ! -d "$VENV_DIR" ]; then
    echo "Error: vllm-metal venv not found. Run install_vllm_metal.sh first."
    exit 1
fi

source "$VENV_DIR/bin/activate"

echo "=== Starting vllm-metal server on port $VLLM_METAL_PORT ==="

# VLLM_METAL_MEMORY_FRACTION: vllm-metal's own default is `auto`, which defers
# to --gpu-memory-utilization and so resolves to 0.92 (vllm_metal/config.py:
# effective_memory_fraction). Pinning 0.5 here handed vllm-metal half the
# machine while oMLX ran its own memory guard at soft 0.85 / hard 0.95 and
# llama.cpp had no comparable cap -- not an apples-to-apples budget. Measured
# on Qwen3.6-35B-A3B 4-bit the pin cost 25/36/52% of output throughput at
# concurrency 1/2/4, and on Qwen3.8-27B 12/28/38%. Default to the engine's own
# default; override the env var explicitly to study the cap.
#
# Keep these assignments on unbroken continuation lines: a comment between them
# terminates the chain, so the ones above it silently become shell-local
# assignments instead of being exported to the server process.
VLLM_METAL_USE_PAGED_ATTENTION=1 \
VLLM_METAL_MEMORY_FRACTION="${VLLM_METAL_MEMORY_FRACTION:-auto}" \
vllm serve "$HF_MODEL" \
    --port "$VLLM_METAL_PORT" \
    --host 0.0.0.0 \
    --enable-prefix-caching \
    --max-model-len "${VLLM_METAL_MAX_MODEL_LEN:-4096}" \
    ${VLLM_METAL_SERVE_EXTRA_ARGS:-} \
    &> "$PROJECT_DIR/.frameworks/vllm_metal_server.log" &

echo $! > "$PROJECT_DIR/.frameworks/vllm_metal_server.pid"
echo "PID: $(cat "$PROJECT_DIR/.frameworks/vllm_metal_server.pid")"

# Wait for server to be ready
echo "Waiting for server to be ready..."
for i in $(seq 1 300); do
    if curl -s "http://localhost:$VLLM_METAL_PORT/v1/models" > /dev/null 2>&1; then
        echo "vllm-metal server is ready on port $VLLM_METAL_PORT"
        exit 0
    fi
    sleep 1
done

echo "Error: Server failed to start within 300 seconds"
cat "$PROJECT_DIR/.frameworks/vllm_metal_server.log"
exit 1
