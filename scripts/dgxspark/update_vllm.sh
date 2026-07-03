#!/bin/bash
# Update vllm to latest and rebuild (CUDA source build, DGX Spark)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

VENV_DIR="$VENVS_DIR/vllm_dgxspark"
REPO_DIR="$FRAMEWORKS_DIR/vllm_dgxspark"

echo "=== Updating vllm (CUDA source build) ==="

if [ ! -d "$VENV_DIR" ] || [ ! -d "$REPO_DIR" ]; then
    echo "Venv or repo not found — running install instead"
    bash "$SCRIPT_DIR/dgxspark/install_vllm.sh"
    exit 0
fi

cd "$REPO_DIR"
git pull

source "$VENV_DIR/bin/activate"
uv pip install --upgrade --pre torch --index-url https://download.pytorch.org/whl/nightly/cu130
TORCH_CUDA_ARCH_LIST="12.1" uv pip install --no-build-isolation --upgrade -e .

echo "=== vllm updated ==="
