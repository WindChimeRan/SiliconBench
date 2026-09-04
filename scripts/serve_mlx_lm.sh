#!/bin/bash
# Start mlx_lm server
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

VENV_DIR="$VENVS_DIR/mlx_lm"

if [ ! -d "$VENV_DIR" ]; then
    echo "Error: mlx_lm venv not found at $VENV_DIR. Run install_mlx_lm.sh first."
    exit 1
fi

source "$VENV_DIR/bin/activate"

echo "=== Starting mlx_lm server on port $MLX_LM_PORT ==="

python -m mlx_lm.server \
    --model "$MLX_MODEL" \
    --port "$MLX_LM_PORT" \
    &> "$PROJECT_DIR/.frameworks/mlx_lm_server.log" &

echo $! > "$PROJECT_DIR/.frameworks/mlx_lm_server.pid"
echo "PID: $(cat "$PROJECT_DIR/.frameworks/mlx_lm_server.pid")"

# Wait for server to be ready.
# Verify OUR pid is alive first: /v1/models answers from whatever holds the
# port, so a stale mlx_lm server left over from an earlier run makes a failed
# start look successful — and the benchmark then measures that older process,
# with whatever prompt cache it had already warmed. Same guard serve_omlx.sh
# got in 5ee128e; this script never had it.
MLX_LM_PID=$(cat "$PROJECT_DIR/.frameworks/mlx_lm_server.pid")
echo "Waiting for server to be ready..."
for i in $(seq 1 300); do
    if ! kill -0 "$MLX_LM_PID" 2>/dev/null; then
        echo "Error: mlx_lm server process $MLX_LM_PID died during startup"
        tail -20 "$PROJECT_DIR/.frameworks/mlx_lm_server.log"
        exit 1
    fi
    if curl -s "http://localhost:$MLX_LM_PORT/v1/models" > /dev/null 2>&1; then
        echo "mlx_lm server is ready on port $MLX_LM_PORT (pid $MLX_LM_PID)"
        exit 0
    fi
    sleep 1
done

echo "Error: Server failed to start within 300 seconds"
cat "$PROJECT_DIR/.frameworks/mlx_lm_server.log"
exit 1
