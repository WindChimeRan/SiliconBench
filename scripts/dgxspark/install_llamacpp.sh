#!/bin/bash
# Install llama.cpp from source with CUDA support for DGX Spark (Grace CPU +
# Blackwell GB10 GPU).
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

REPO_DIR="$FRAMEWORKS_DIR/llama.cpp_dgxspark"

echo "=== Installing llama.cpp (CUDA) ==="

if [ -d "$REPO_DIR" ]; then
    echo "llama.cpp already cloned, run update_llamacpp.sh to update"
else
    git clone https://github.com/ggerganov/llama.cpp.git "$REPO_DIR"
fi

cd "$REPO_DIR"
# GB10 is compute capability sm_121; recognizing it requires a CUDA 13.x
# toolkit. https://learn.arm.com/learning-paths/laptops-and-desktops/dgx_spark_llamacpp/2_gb10_llamacpp_gpu/
cmake -B build -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="$DGX_CUDA_ARCH"
cmake --build build --config Release -j$(nproc)

echo "=== llama.cpp installed ==="
echo "Server binary: $REPO_DIR/build/bin/llama-server"
