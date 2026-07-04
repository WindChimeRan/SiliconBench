#!/bin/bash
# Start vllm server (native CUDA source build) on DGX Spark
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

# Default to the project-managed venv, but allow pointing at an existing
# working vllm install (e.g. a local dev checkout's venv) via
# VLLM_DGXSPARK_VENV — handy on a box that already has vllm built, to skip a
# 20-minute from-source rebuild.
VENV_DIR="${VLLM_DGXSPARK_VENV:-$VENVS_DIR/vllm_dgxspark}"

if [ ! -d "$VENV_DIR" ]; then
    echo "Error: vllm venv not found at $VENV_DIR. Run scripts/dgxspark/install_vllm.sh first (or set VLLM_DGXSPARK_VENV)."
    exit 1
fi

source "$VENV_DIR/bin/activate"

echo "=== Starting vllm server on port $VLLM_PORT ==="

vllm serve "$HF_MODEL" \
    --port "$VLLM_PORT" \
    --host 0.0.0.0 \
    --max-model-len "${DGX_VLLM_MAX_MODEL_LEN:-4096}" \
    &> "$PROJECT_DIR/.frameworks/vllm_dgxspark_server.log" &

echo $! > "$PROJECT_DIR/.frameworks/vllm_dgxspark_server.pid"
echo "PID: $(cat "$PROJECT_DIR/.frameworks/vllm_dgxspark_server.pid")"

# Wait for server to be ready
echo "Waiting for server to be ready..."
for i in $(seq 1 300); do
    if curl -s "http://localhost:$VLLM_PORT/v1/models" > /dev/null 2>&1; then
        echo "vllm server is ready on port $VLLM_PORT"
        exit 0
    fi
    sleep 1
done

echo "Error: Server failed to start within 300 seconds"
cat "$PROJECT_DIR/.frameworks/vllm_dgxspark_server.log"
exit 1
