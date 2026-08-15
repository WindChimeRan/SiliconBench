#!/bin/bash
# Install sglang from source with the MLX backend (Apple Silicon).
# Follows docs/platforms/apple_metal.md: swap pyproject_other.toml in for the
# default (CUDA) pyproject.toml, then `uv pip install -e python[all_mps]`.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

VENV_DIR="$VENVS_DIR/sglang"
REPO_DIR="$FRAMEWORKS_DIR/sglang"

echo "=== Installing sglang ==="

# Clone repo
if [ -d "$REPO_DIR" ]; then
    echo "sglang repo already cloned at $REPO_DIR"
else
    git clone https://github.com/sgl-project/sglang.git "$REPO_DIR"
fi

# Swap in the MPS pyproject.toml. Idempotent: only acts if pyproject_other.toml
# is still present (a fresh clone has it; a subsequent install_*.sh re-run does not).
if [ -f "$REPO_DIR/python/pyproject_other.toml" ]; then
    rm -f "$REPO_DIR/python/pyproject.toml"
    mv "$REPO_DIR/python/pyproject_other.toml" "$REPO_DIR/python/pyproject.toml"
    echo "Swapped pyproject_other.toml -> pyproject.toml (MPS build)"
fi

# Python 3.11 — issue #19137 explicitly notes other versions are known-broken.
if [ -d "$VENV_DIR" ]; then
    echo "Venv already exists at $VENV_DIR"
else
    uv venv "$VENV_DIR" --python 3.11
fi

source "$VENV_DIR/bin/activate"
uv pip install --upgrade pip
uv pip install -e "$REPO_DIR/python[all_mps]"

# Belt-and-suspenders: the MLX backend tracks fast-moving mlx/mlx-lm releases
# and the pinned versions in pyproject often lag what actually works.
uv pip install --upgrade mlx mlx-lm

# ...but that --upgrade resolves mlx-lm's own deps too, which drags transformers
# past the version sglang pins. sglang registers configs that newer transformers
# now ships natively, so AutoConfig.register() aborts server startup with
# "ValueError: 'qwen3_asr' is already used by a Transformers config" — the import
# chain is server_args.py -> configs/__init__.py -> qwen3_asr.py. Restore sglang's
# own pin, read from pyproject so it rolls forward when upstream bumps it.
TRANSFORMERS_PIN=$(grep -oE '"transformers==[^"]+"' "$REPO_DIR/python/pyproject.toml" | head -1 | tr -d '"')
if [ -n "$TRANSFORMERS_PIN" ]; then
    echo "Restoring sglang's transformers pin: $TRANSFORMERS_PIN"
    uv pip install "$TRANSFORMERS_PIN"
else
    echo "WARNING: no transformers== pin found in sglang pyproject.toml — skipping restore"
fi

echo "=== sglang installed ==="
