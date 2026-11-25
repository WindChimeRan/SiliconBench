# Model profile: Muse Glimmer 30B 4-bit (dense, 52 layers). BF16 (~52 GB) exceeds
# a 64 GB Mac's Metal working-set cap, so this model runs in 4-bit only.
#
#   GGUF meta-models Muse-Glimmer-30B-KQuant-17GB-Q4_K_M : 15.6 GiB (Q4_K + Q6_K mix)
#   MLX  mlx-community/Muse-Glimmer-30B-4bit             : 18.1 GiB, affine, group 64
# HF_* points at the MLX build, as in the other 4-bit profiles. Its tokenizer
# equals meta-models', and its chat template renders all 200 benchmark prompts
# identically to the canonical one.
#
# The chat template always reasons ("Reasoning strength: high" by default) and
# has no enable_thinking switch, so outputs include reasoning tokens. The
# correctness eval passes reasoning_strength=low, the lowest available.
MODEL_NAME="Muse-Glimmer-30B-4bit"
GGUF_REPO="meta-models/Muse-Glimmer-30B-GGUF"
GGUF_FILE="Muse-Glimmer-30B-KQuant-17GB-Q4_K_M.gguf"
MLX_REPO="mlx-community/Muse-Glimmer-30B-4bit"
MLX_DIR_NAME="Muse-Glimmer-30B-4bit-mlx"
HF_REPO="mlx-community/Muse-Glimmer-30B-4bit"
HF_DIR_NAME="Muse-Glimmer-30B-4bit-mlx"
# Read by the ExecuTorch scripts (separate PR) to use Muse Glimmer's own
# exporter and server; ignored by every other framework.
ET_PIPELINE="muse_glimmer"
