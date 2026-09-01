# Model profile: Qwen3.8-27B 4-bit — the blog-post counterpart to
# qwen3.8-27b.sh (8-bit). Distinct MODEL_NAME on purpose: run_all deletes
# stale results in the active split dir at startup and its provenance guard
# only blocks a KNOWN-DIFFERENT chip, so reusing "Qwen3.8-27B" on this same
# M5 Pro would silently wipe the published 8-bit baseline. Results land in
# results/Qwen3.8-27B-4bit/ and never mix with the paper tree.
#
# Formats are NOT footprint-matched, unlike the 8-bit profile (26.6 GiB
# either side). Measured from the safetensors headers / HF blob sizes:
#   MLX  mlx-community/Qwen3.8-27B-4bit : text 14.094 GiB + vision 0.858
#                                         (uniform 4-bit, group_size 64)
#   GGUF Qwen3.8-27B-UD-Q4_K_M          : 15.33 GiB, no vision tensors
# The GGUF runs ~8.8% heavier because K-quants are mixed precision. That is
# deliberate: this figure reports what users actually deploy, so it does not
# support causal claims about the serving layer in the way the 8-bit one did.
# UD-Q4_K_S (14.30 GiB, +1.5%) is the matched alternative if that changes.
MODEL_NAME="Qwen3.8-27B-4bit"
GGUF_REPO="unsloth/Qwen3.8-27B-GGUF"
GGUF_FILE="Qwen3.8-27B-UD-Q4_K_M.gguf"
MLX_REPO="mlx-community/Qwen3.8-27B-4bit"
MLX_DIR_NAME="Qwen3.8-27B-4bit-mlx"
HF_REPO="mlx-community/Qwen3.8-27B-4bit"
HF_DIR_NAME="Qwen3.8-27B-4bit-mlx"
# Four fast Mac engines only (llamacpp, mlx_lm, omlx, vllm_metal).
