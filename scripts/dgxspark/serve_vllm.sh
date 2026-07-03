#!/bin/bash
# Start vllm server (native CUDA source build) on DGX Spark
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

VENV_DIR="$VENVS_DIR/vllm_dgxspark"

if [ ! -d "$VENV_DIR" ]; then
    echo "Error: vllm venv not found. Run scripts/dgxspark/install_vllm.sh first."
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
