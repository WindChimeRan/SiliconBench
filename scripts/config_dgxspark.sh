#!/bin/bash
# SiliconBench — DGX Spark platform config. Sourced by dgxspark orchestrator
# scripts AFTER config.sh; never sourced (and never referenced) by any apple
# script or by config.sh itself.

# GB10's compute capability (Grace-Blackwell). Override if the toolchain's
# target arch ever changes.
DGX_CUDA_ARCH="${DGX_CUDA_ARCH:-121}"

# Apple has VLLM_METAL_PORT/VLLM_MLX_PORT; DGX Spark's vllm needs its own.
VLLM_PORT=8011

# Results live under a dgxspark/ subdir, parallel to (never mixed with) the
# apple results tree: results/<MODEL_NAME>/dgxspark/{chat,agent}/...
RESULTS_DIR="$RESULTS_BASE_DIR/$MODEL_NAME/dgxspark"
mkdir -p "$RESULTS_DIR"
