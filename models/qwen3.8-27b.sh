# Model profile: Qwen3.8-27B (8-bit — BF16 at 55.6GB exceeds the 64GB box's
# Metal working-set cap, so every engine runs an 8-bit build: GGUF Q8_0 for
# llama.cpp, the mlx-community 8-bit conversion for the MLX engines.
#
# Hybrid GDN + full-attention reasoning model (16 of 64 layers are full
# attention; the rest are GDN) shipping an MTP head. Verified from the file
# headers, because the two checkpoints differ in OPPOSITE directions:
#   - the mlx-community conversion KEEPS vision (0.86 GiB of vision_tower.*,
#     language_model_only=false) and strips MTP
#   - the GGUF has NO vision tensors but carries 15 MTP tensors (blk.64.*,
#     0.42 GiB) that llama.cpp discards at load as "unused"
# Net text weights match almost exactly: 26.6 GiB either side. No engine here
# exploits the MTP head. vllm-metal serves the same MLX 8-bit directory
# (HF_REPO below), so the MLX-side engines share one on-disk copy.
MODEL_NAME="Qwen3.8-27B"
GGUF_REPO="unsloth/Qwen3.8-27B-GGUF"
GGUF_FILE="Qwen3.8-27B-Q8_0.gguf"
MLX_REPO="mlx-community/Qwen3.8-27B-8bit"
MLX_DIR_NAME="Qwen3.8-27B-8bit-mlx"
HF_REPO="mlx-community/Qwen3.8-27B-8bit"
HF_DIR_NAME="Qwen3.8-27B-8bit-mlx"
# Four fast Mac engines only (llamacpp, mlx_lm, omlx, vllm_metal); the slow
# engines and ollama are out of scope for this profile.
