#!/bin/bash
# Install sglang from source with CUDA support for DGX Spark. Unlike the
# Apple MPS build (which swaps in an alternate pyproject.toml), CUDA is
# sglang's default upstream build target — no swap needed.
#
# DGX Spark (GB10, sm_121a) support is tracked as an open, actively-changing
# effort upstream: https://github.com/sgl-project/sglang/issues/11658 — this
# script has been verified end-to-end on real GB10 hardware (installed,
# served, benchmarked with no fixes needed), but re-check that issue before
# assuming a future run will go as smoothly.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

VENV_DIR="$VENVS_DIR/sglang_dgxspark"
REPO_DIR="$FRAMEWORKS_DIR/sglang_dgxspark"

echo "=== Installing sglang (CUDA) ==="

if [ -d "$REPO_DIR" ]; then
    echo "sglang repo already cloned at $REPO_DIR"
else
    git clone https://github.com/sgl-project/sglang.git "$REPO_DIR"
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
uv pip install -e "$REPO_DIR/python[all]"

echo "=== sglang installed ==="
