#!/bin/bash
# Install vllm from source for DGX Spark, built against nightly CUDA-13
# PyTorch — no stable CUDA-13 PyTorch wheel exists yet, so a plain
# `pip install vllm` does not work on GB10 (sm_121).
#
# vllm has no merged upstream aarch64+sm121 wheel, and NVIDIA/community docs
# currently lean on Docker rather than source builds
# (https://discuss.vllm.ai/t/nvidia-dgx-spark-compatibility/1756), so this
# script is the least stable part of the DGX Spark track — but it has been
# verified end-to-end on real GB10 hardware (installed, served, benchmarked;
# see CLAUDE.md's "DGX Spark Notes" for what broke and why). The most likely
# thing to need adjustment over time is the torch nightly date pin below, as
# both vllm's `main` and torch's nightly builds keep moving.
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

# Nightly PyTorch is required for CUDA 13 / sm_121 support — but pinned to a
# specific known-good date rather than "whatever's newest", since vllm's C++
# source (csrc/cpu/utils.hpp, part of the _C extension built regardless of
# CUDA target) calls torch APIs that can be renamed/removed in a newer
# nightly faster than vllm's `main` adapts. Confirmed by testing directly:
# `at::cpu::get_cpu_capabilities()` (added to torch's headers well before
# this date) was present in the 2026-06-26 nightly but gone by 2026-07-03,
# breaking the build with "not a member of at::cpu". Bump
# VLLM_TORCH_NIGHTLY_DATE once a newer pairing is verified to work again.
VLLM_TORCH_NIGHTLY_DATE="${VLLM_TORCH_NIGHTLY_DATE:-20260626}"
TORCH_PIN="2.14.0.dev${VLLM_TORCH_NIGHTLY_DATE}+cu130"
# torchvision/torchaudio must be pinned to a matching nightly too — their
# native extensions are ABI-linked to whichever torch they were built
# against ("operator torchvision::nms does not exist" is the exact failure
# if a stable torchvision ends up paired with our nightly torch instead).
TORCHVISION_PIN="0.29.0.dev${VLLM_TORCH_NIGHTLY_DATE}+cu130"
TORCHAUDIO_PIN="2.11.0.dev${VLLM_TORCH_NIGHTLY_DATE}+cu130"

# vllm's own requirements pin stable torch==2.11.0/torchvision==0.26.0/
# torchaudio==2.11.0 in TWO places (pyproject.toml's [build-system] AND
# requirements/cuda.txt's regular runtime deps) — installing either file
# normally silently replaces our nightly pins the moment uv resolves them
# (stable torch has no CUDA-13/sm_121 support at all, and a stable "torch"
# requirement doesn't even see our nightly as satisfying it, since
# nightlies are pre-releases excluded from normal resolution). The result
# is either an outright downgrade or an ABI-mismatched, un-importable
# extension. `--overrides` forces our pins to win regardless of what any
# requirements file or transitive dependency asks for, so the rest of this
# script can install vllm's declared requirements files as-is without
# fragile line-filtering.
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

cd "$REPO_DIR"

# --no-build-isolation means uv builds against the venv above (with our
# nightly torch) instead of installing pyproject.toml's [build-system]
# requires into an isolated env. But that also means those OTHER
# build-time deps (setuptools-rust etc.) never get installed anywhere —
# install them explicitly from vllm's own declared build requirements.
uv pip install -r requirements/build/cuda.txt

# Same for vllm's regular runtime dependencies.
(cd requirements && uv pip install -r common.txt)
uv pip install -r requirements/cuda.txt

TORCH_CUDA_ARCH_LIST="12.1" uv pip install --no-build-isolation --no-deps -e .

echo "=== vllm installed ==="
