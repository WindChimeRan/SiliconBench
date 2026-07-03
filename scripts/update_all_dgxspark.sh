#!/bin/bash
# SiliconBench — Update all DGX Spark frameworks to latest versions
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo " SiliconBench — Updating DGX Spark track"
echo " $(date)"
echo "========================================="
echo ""

for script in \
    dgxspark/update_llamacpp.sh \
    dgxspark/update_vllm.sh \
    dgxspark/update_sglang.sh; do
    echo "==========================================="
    echo " Running $script"
    echo "==========================================="
    bash "$SCRIPT_DIR/$script" || {
        echo "WARNING: $script failed, continuing..."
    }
    echo ""
done

echo "========================================="
echo " All DGX Spark updates complete!"
echo "========================================="
