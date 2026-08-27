# Model profile: Qwen3.8-27B FP8 — the DGX Spark (CUDA) counterpart to
# models/qwen3.8-27b.sh.
#
# Why a separate profile instead of a platform branch inside qwen3.8-27b.sh:
# HF_REPO means different things on the two tracks. On Apple it names the MLX
# 8-bit conversion that vllm_metal/mlx_lm/omlx all serve; on CUDA it has to
# name a real safetensors checkpoint vllm can load. One variable cannot be
# both, and editing the Apple profile to suit CUDA would silently repoint
# every Mac engine at a checkpoint MLX cannot read.
#
# MODEL_NAME is deliberately identical to the Apple profile's, so results land
# in results/Qwen3.8-27B/dgxspark/<split>/ — a sibling of the existing
# m5pro/<split>/ tree rather than a new top-level model. That is what makes the
# two machines directly comparable in one results tree.
#
# Precision parity with the Mac: the 64 GB M5 Pro cannot hold this model in
# BF16 (55.6 GB exceeds its Metal working-set cap), so every Apple engine runs
# an 8-bit build — mlx-community's 8-bit conversion, or GGUF Q8_0. FP8 e4m3
# (Qwen's own quantization, dynamic activation scheme) is the CUDA analogue and
# is native on GB10, holding weight precision roughly constant across the two
# machines so the comparison isolates the hardware and the serving stack.
# BF16 would fit the Spark's 121 GB, but has no Mac counterpart to compare to.
MODEL_NAME="Qwen3.8-27B"
GGUF_REPO="unsloth/Qwen3.8-27B-GGUF"
GGUF_FILE="Qwen3.8-27B-Q8_0.gguf"
# MLX fields are unused on this track — config.sh derives MLX_MODEL from them
# unconditionally, so they are set to the Apple profile's values rather than
# left unset.
MLX_REPO="mlx-community/Qwen3.8-27B-8bit"
MLX_DIR_NAME="Qwen3.8-27B-8bit-mlx"
HF_REPO="Qwen/Qwen3.8-27B-FP8"
HF_DIR_NAME="Qwen3.8-27B-FP8"
# Scope: vllm only. Concurrency must mirror the Mac's 27B sweep exactly —
#   CONCURRENCY_LEVELS="1 2 4" scripts/run_all.sh --model qwen3.8-27b-fp8 \
#       --split agent vllm
# The Mac stopped at 4 because it ran out of headroom, not because 4 is
# interesting; every Spark point above 4 would have no counterpart to compare
# against, so this profile does not sweep past it.
