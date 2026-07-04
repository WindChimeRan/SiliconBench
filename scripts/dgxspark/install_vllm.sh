#!/bin/bash
# Install vllm from source for DGX Spark (Grace CPU + Blackwell GB10, sm_121).
#
# The ONLY DGX-Spark-specific requirement is a CUDA-13 build of PyTorch. Get
# it from PyTorch's *stable* CUDA-13 wheel index
# (https://download.pytorch.org/whl/cu130), which serves torch 2.11.0+cu130 —
# already the exact version vllm pins in requirements/cuda.txt, just the
# +cu130 build instead of the generic PyPI one. That build has full sm_121
# support and every C++ API vllm's source expects, so vllm's own pinned
# torch/torchvision/torchaudio ARE the known-good set (this is the same combo
# a working local vllm dev checkout on the box uses).
#
# No nightly, no --overrides, no --no-deps: the earlier version of this script
# pulled torch from the *nightly* index and then had to fight vllm's stable
# pins with a stack of workarounds; pointing at the stable cu130 index removes
# the entire problem. ccache (if present) keeps rebuilds fast.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

VENV_DIR="$VENVS_DIR/vllm_dgxspark"
REPO_DIR="$FRAMEWORKS_DIR/vllm_dgxspark"
TORCH_CU13_INDEX="https://download.pytorch.org/whl/cu130"

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

cd "$REPO_DIR"

# 1. CUDA-13 torch stack, pinned to vllm's own versions but fetched as the
#    +cu130 builds. `==2.11.0` is satisfied by `2.11.0+cu130` (PEP 440 local
#    version), so these also satisfy every later torch requirement below —
#    nothing downstream can downgrade or replace them.
uv pip install \
    "torch==2.11.0" "torchvision==0.26.0" "torchaudio==2.11.0" \
    --index-url "$TORCH_CU13_INDEX"

# 2. vllm's build-time deps (setuptools-rust etc.). --no-build-isolation
#    below builds against this venv, so they must be present here; the torch
#    line in this file is already satisfied by step 1 and won't be refetched.
uv pip install -r requirements/build/cuda.txt

# 3. Build + install vllm against the installed torch.
TORCH_CUDA_ARCH_LIST="12.1" uv pip install --no-build-isolation -e .

echo "=== vllm installed ==="
