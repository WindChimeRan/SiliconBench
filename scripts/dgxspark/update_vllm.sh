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

# See install_vllm.sh for the full rationale on all three of: the pinned
# nightly date (+ matching torchvision/torchaudio), the --overrides
# mechanism, and --no-deps on the final step.
VLLM_TORCH_NIGHTLY_DATE="${VLLM_TORCH_NIGHTLY_DATE:-20260626}"
TORCH_PIN="2.14.0.dev${VLLM_TORCH_NIGHTLY_DATE}+cu130"
TORCHVISION_PIN="0.29.0.dev${VLLM_TORCH_NIGHTLY_DATE}+cu130"
TORCHAUDIO_PIN="2.11.0.dev${VLLM_TORCH_NIGHTLY_DATE}+cu130"

OVERRIDES_FILE="$(mktemp)"
trap 'rm -f "$OVERRIDES_FILE"' EXIT
{
    echo "torch==${TORCH_PIN}"
    echo "torchvision==${TORCHVISION_PIN}"
    echo "torchaudio==${TORCHAUDIO_PIN}"
} > "$OVERRIDES_FILE"
export UV_OVERRIDE="$OVERRIDES_FILE"

uv pip install \
    "torch==${TORCH_PIN}" \
    "torchvision==${TORCHVISION_PIN}" \
    "torchaudio==${TORCHAUDIO_PIN}" \
    --index-url https://download.pytorch.org/whl/nightly/cu130
uv pip install -r requirements/build/cuda.txt
(cd requirements && uv pip install -r common.txt)
uv pip install -r requirements/cuda.txt

TORCH_CUDA_ARCH_LIST="12.1" uv pip install --no-build-isolation --no-deps --upgrade -e .

echo "=== vllm updated ==="
