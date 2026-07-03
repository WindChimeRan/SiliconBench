#!/bin/bash
# SiliconBench — Install DGX Spark frameworks, models, and benchmark deps
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo " SiliconBench — Installing DGX Spark track"
echo " $(date)"
echo "========================================="
echo ""

for script in \
    install_bench.sh \
    dgxspark/install_llamacpp.sh \
    dgxspark/install_vllm.sh \
    dgxspark/install_sglang.sh; do
    echo "==========================================="
    echo " Running $script"
    echo "==========================================="
    bash "$SCRIPT_DIR/$script"
    echo ""
done

echo "==========================================="
echo " Downloading models (GGUF + HF safetensors only — MLX unused on this platform)"
echo "==========================================="
bash "$SCRIPT_DIR/download_model.sh" --formats gguf,hf
echo ""

echo "========================================="
echo " All DGX Spark installations complete!"
echo "========================================="
