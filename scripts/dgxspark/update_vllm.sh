#!/bin/bash
# Update vllm to latest and rebuild (CUDA source build, DGX Spark).
# See install_vllm.sh for why the torch stack comes from the stable cu130
# wheel index and needs no nightly pin / overrides.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

VENV_DIR="$VENVS_DIR/vllm_dgxspark"
REPO_DIR="$FRAMEWORKS_DIR/vllm_dgxspark"
TORCH_CU13_INDEX="https://download.pytorch.org/whl/cu130"

echo "=== Updating vllm (CUDA source build) ==="

if [ ! -d "$VENV_DIR" ] || [ ! -d "$REPO_DIR" ]; then
    echo "Venv or repo not found — running install instead"
    bash "$SCRIPT_DIR/dgxspark/install_vllm.sh"
    exit 0
fi

cd "$REPO_DIR"
git pull

source "$VENV_DIR/bin/activate"

# Refresh the torch stack from the stable cu130 index in case vllm bumped its
# pins, then rebuild (ccache keeps this fast).
uv pip install --upgrade \
    "torch==2.11.0" "torchvision==0.26.0" "torchaudio==2.11.0" \
    --index-url "$TORCH_CU13_INDEX"
uv pip install -r requirements/build/cuda.txt

TORCH_CUDA_ARCH_LIST="12.1" uv pip install --no-build-isolation --upgrade -e .

echo "=== vllm updated ==="
