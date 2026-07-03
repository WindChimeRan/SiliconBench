#!/bin/bash
# Update llama.cpp to latest and rebuild (CUDA, DGX Spark)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

REPO_DIR="$FRAMEWORKS_DIR/llama.cpp_dgxspark"

echo "=== Updating llama.cpp (CUDA) ==="

if [ ! -d "$REPO_DIR" ]; then
    echo "Repo not found — running install instead"
    bash "$SCRIPT_DIR/dgxspark/install_llamacpp.sh"
    exit 0
fi

cd "$REPO_DIR"
git pull
cmake -B build -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="$DGX_CUDA_ARCH"
cmake --build build --config Release -j$(nproc)

echo "=== llama.cpp updated ==="
