#!/bin/bash
# Install vllm from source for DGX Spark, built against nightly CUDA-13
# PyTorch — no stable CUDA-13 PyTorch wheel exists yet, so a plain
# `pip install vllm` does not work on GB10 (sm_121).
#
# This is the least stable part of the DGX Spark track: vllm has no merged
# upstream aarch64+sm121 wheel, and NVIDIA/community docs currently lean on
# Docker rather than source builds
# (https://discuss.vllm.ai/t/nvidia-dgx-spark-compatibility/1756). Treat this
# as a best-effort scaffold, not a verified recipe — expect to adjust the
# PyTorch nightly index / build flags after testing on real hardware.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

VENV_DIR="$VENVS_DIR/vllm_dgxspark"
REPO_DIR="$FRAMEWORKS_DIR/vllm_dgxspark"

echo "=== Installing vllm (CUDA source build) ==="

if [ -d "$REPO_DIR" ]; then
    echo "vllm repo already cloned at $REPO_DIR"
else
    git clone https://github.com/vllm-project/vllm.git "$REPO_DIR"
fi

if [ -d "$VENV_DIR" ]; then
    echo "Venv already exists at $VENV_DIR"
else
    uv venv "$VENV_DIR" --python 3.12
fi

source "$VENV_DIR/bin/activate"
uv pip install --upgrade pip

# Nightly PyTorch is required for CUDA 13 / sm_121 support.
uv pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/cu130

cd "$REPO_DIR"
TORCH_CUDA_ARCH_LIST="12.1" uv pip install --no-build-isolation -e .

echo "=== vllm installed ==="
