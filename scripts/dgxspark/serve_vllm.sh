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

# DGX Spark's "GPU memory" IS system memory: vllm sizes its budget from the
# whole 121 GB, so the default --gpu-memory-utilization 0.9 reserves ~109 GB and
# leaves the desktop nothing. Small models survive it (Qwen3.5-0.8B took a
# 102 GiB KV cache and still booted), but Qwen3.8-27B does not: 28.5 GiB of
# weights plus the KV pool exhausted the box, the driver returned
# NV_ERR_NO_MEMORY, and the login session died with it. Unset means "use vllm's
# own default", so runs made before this knob existed keep their exact meaning.
GPU_MEM_UTIL_ARG=""
if [ -n "${DGX_VLLM_GPU_MEM_UTIL:-}" ]; then
    GPU_MEM_UTIL_ARG="--gpu-memory-utilization $DGX_VLLM_GPU_MEM_UTIL"
fi

vllm serve "$HF_MODEL" \
    --port "$VLLM_PORT" \
    --host 0.0.0.0 \
    --max-model-len "${DGX_VLLM_MAX_MODEL_LEN:-4096}" \
    $GPU_MEM_UTIL_ARG \
    &> "$PROJECT_DIR/.frameworks/vllm_dgxspark_server.log" &

echo $! > "$PROJECT_DIR/.frameworks/vllm_dgxspark_server.pid"
echo "PID: $(cat "$PROJECT_DIR/.frameworks/vllm_dgxspark_server.pid")"

# Wait for server to be ready. 300s covers the small profiles, but a 27B needs
# far longer before it ever answers /v1/models: weight load alone ran 208s for
# the 29GB FP8 checkpoint, then torch.compile ~39s, then KV profiling and CUDA
# graph capture. Hitting the cap looks exactly like a crashed server, so the
# runner skips the framework and reports "No results found".
READY_TIMEOUT="${DGX_VLLM_READY_TIMEOUT:-300}"
echo "Waiting for server to be ready (timeout ${READY_TIMEOUT}s)..."
for i in $(seq 1 "$READY_TIMEOUT"); do
    if curl -s "http://localhost:$VLLM_PORT/v1/models" > /dev/null 2>&1; then
        echo "vllm server is ready on port $VLLM_PORT"
        exit 0
    fi
    sleep 1
done

echo "Error: Server failed to start within ${READY_TIMEOUT} seconds"
cat "$PROJECT_DIR/.frameworks/vllm_dgxspark_server.log"
exit 1
