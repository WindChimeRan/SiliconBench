#!/bin/bash
# Start sglang server (CUDA) on DGX Spark.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

VENV_DIR="$VENVS_DIR/sglang_dgxspark"

if [ ! -d "$VENV_DIR" ]; then
    echo "Error: sglang venv not found. Run scripts/dgxspark/install_sglang.sh first."
    exit 1
fi

source "$VENV_DIR/bin/activate"

echo "=== Starting sglang server on port $SGLANG_PORT ==="

# Unlike the Apple/MLX build, CUDA supports radix cache and CUDA graphs, so
# (unlike serve_sglang.sh's Apple counterpart) neither is disabled here.
python -m sglang.launch_server \
    --model-path "$HF_MODEL" \
    --host 0.0.0.0 \
    --port "$SGLANG_PORT" \
    --trust-remote-code \
    &> "$PROJECT_DIR/.frameworks/sglang_dgxspark_server.log" &

echo $! > "$PROJECT_DIR/.frameworks/sglang_dgxspark_server.pid"
echo "PID: $(cat "$PROJECT_DIR/.frameworks/sglang_dgxspark_server.pid")"

# Wait for server to be ready
echo "Waiting for server to be ready..."
for i in $(seq 1 300); do
    if curl -s "http://localhost:$SGLANG_PORT/v1/models" > /dev/null 2>&1; then
        echo "sglang server is ready on port $SGLANG_PORT"
        exit 0
    fi
    sleep 1
done

echo "Error: Server failed to start within 300 seconds"
cat "$PROJECT_DIR/.frameworks/sglang_dgxspark_server.log"
exit 1
