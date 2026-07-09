#!/bin/bash
# Install HuggingFace transformers (with serving extras) in its own venv
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

VENV_DIR="$VENVS_DIR/hf_transformers"

echo "=== Installing hf_transformers ==="

if [ -d "$VENV_DIR" ]; then
    echo "Venv already exists at $VENV_DIR"
else
    uv venv "$VENV_DIR" --python 3.12
fi

source "$VENV_DIR/bin/activate"
# pillow/torchvision: not needed for text-only inference, but AutoProcessor
# still imports the image-processor class for natively-multimodal checkpoints
# (Qwen3.5, Gemma-4) even when we never pass image inputs — without these,
# that import raises ImportError before the server ever comes up.
uv pip install "transformers[serving]" torch torchvision pillow requests

echo "=== hf_transformers installed ==="
