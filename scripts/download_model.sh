#!/bin/bash
# Download model in the requested formats
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Accept --model and --formats flags
FORMATS="gguf,mlx,hf"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --model) export APPLEBENCH_MODEL="$2"; shift 2 ;;
        --formats) FORMATS="$2"; shift 2 ;;
        *) shift ;;
    esac
done

source "$SCRIPT_DIR/config.sh"

echo "=== Downloading $MODEL_NAME models ($FORMATS) ==="

# GGUF for llama.cpp / mistral.rs
if [[ ",$FORMATS," == *",gguf,"* ]]; then
    if [ ! -f "$GGUF_MODEL" ]; then
        echo "Downloading GGUF model from $GGUF_REPO..."
        hf download "$GGUF_REPO" "$GGUF_FILE" --local-dir "$MODELS_DIR"
        echo "GGUF model downloaded: $GGUF_MODEL"
    else
        echo "GGUF model already exists: $GGUF_MODEL"
    fi
fi

# MLX format for mlx_lm. No directory-existence pre-check here (unlike the
# single-file GGUF case above) — a multi-file download directory can exist
# yet be incomplete if a prior run was interrupted mid-download (e.g. a
# flaky network timeout after only the small metadata files landed), and a
# bare `[ -d ... ]` check would then permanently skip retrying the missing
# large files. `hf download` already does its own per-file existence/hash
# check and only fetches what's actually missing, so just always call it.
if [[ ",$FORMATS," == *",mlx,"* ]]; then
    echo "Downloading MLX model from $MLX_REPO..."
    hf download "$MLX_REPO" --local-dir "$MLX_MODEL"
    echo "MLX model ready: $MLX_MODEL"
fi

# Safetensors for vllm-metal / vllm / sglang — same reasoning as MLX above.
if [[ ",$FORMATS," == *",hf,"* ]]; then
    echo "Downloading HF model from $HF_REPO..."
    hf download "$HF_REPO" --local-dir "$HF_MODEL"
    echo "HF model ready: $HF_MODEL"
fi

echo "=== All models downloaded ==="
