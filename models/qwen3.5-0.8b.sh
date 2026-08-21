# Model profile: Qwen3.5-0.8B (BF16, dense, hybrid Gated-DeltaNet attention)
#
# Multimodal (text/image/video, Qwen3_5ForConditionalGeneration) but we
# benchmark text-only — the framework serve scripts don't load the vision
# projector, so the *.gguf is enough; mmproj-*.gguf in the unsloth repo is
# not fetched.
MODEL_NAME="Qwen3.5-0.8B"
GGUF_REPO="unsloth/Qwen3.5-0.8B-GGUF"
GGUF_FILE="Qwen3.5-0.8B-BF16.gguf"
MLX_REPO="mlx-community/Qwen3.5-0.8B-bf16"
MLX_DIR_NAME="Qwen3.5-0.8B-bf16-mlx"
HF_REPO="Qwen/Qwen3.5-0.8B"
HF_DIR_NAME="Qwen3.5-0.8B"
# The mlx-community port is a multimodal mlx-vlm package (vision_tower,
# language_model.* keys). mlx_lm handles it natively — models/qwen3_5.py
# sanitize() drops the vision tower and keeps the language_model.* keys —
# so the mlx_lm slot serves it with mlx_lm, like every other profile.
# Scope: the fast Mac engines — llamacpp, mlx_lm, omlx, vllm_metal, vllm_mlx.
# vllm_mlx was previously grouped here as a "slow engine" and excluded; the
# 2026-08-15 run contradicts that outright — it is the *fastest* stack in this
# cell at concurrency (agent c16 261.8 tok/s vs llamacpp 157.5, omlx 146.8,
# mlx_lm 106.2, vllm_metal 62.2; chat c16 390.3 vs llamacpp 320.8), 100/100 at
# every level on both splits. mistralrs really is slow (chat 70.1/19.4/8.7
# tok/s, 79/100 at c16) and stays out, as do ollama and hf_transformers.
#
# Nothing here enforces that scope. run_all_apple.sh selects only via explicit
# framework arguments; a profile cannot exclude a framework. In particular this
# profile sets no OLLAMA_MODEL_NAME, but config.sh:52 fills in a fallback
# ("<model>-bf16"), so ollama is not self-skipping either — name the engines on
# the command line to hold this scope:
#   scripts/run_all.sh --model qwen3.5-0.8b --split <split> \
#       llamacpp mlx_lm omlx vllm_metal vllm_mlx
