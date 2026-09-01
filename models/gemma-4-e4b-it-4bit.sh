# Model profile: Gemma-4-E4B-it 4-bit — blog-post counterpart to
# gemma-4-e4b-it.sh, which runs BF16 on every engine. This is a bigger jump
# than the 27B's 8->4, since that arm was never quantized before.
#
# Footprint gap is the widest in the matrix:
#   MLX  mlx-community/gemma-4-e4b-it-4bit : text 3.910 GiB
#        (+ vision 0.313, audio 0.570; full multimodal mlx-vlm package)
#   GGUF gemma-4-E4B-it-Q4_K_M             : 4.64 GiB, text only
# ~18.7% heavier on the GGUF side, and NO available Q4 GGUF gets closer than
# IQ4_XS at 4.39 GiB (+12.3%) — so this arm cannot be footprint-matched at
# 4-bit at all. Report descriptively.
#
# The MTP drafter stays bf16 (mlx-community/gemma-4-E4B-it-assistant-bf16,
# 0.148 GiB): there is no non-QAT 4-bit assistant, quantizing saves ~0.1 GiB,
# and a QAT drafter against a non-QAT target would move acceptance for
# reasons unrelated to batching.
MODEL_NAME="Gemma-4-E4B-it-4bit"
GGUF_REPO="unsloth/gemma-4-E4B-it-GGUF"
GGUF_FILE="gemma-4-E4B-it-Q4_K_M.gguf"
MLX_REPO="mlx-community/gemma-4-e4b-it-4bit"
MLX_DIR_NAME="gemma-4-e4b-it-4bit-mlx"
HF_REPO="mlx-community/gemma-4-e4b-it-4bit"
HF_DIR_NAME="gemma-4-e4b-it-4bit-mlx"
