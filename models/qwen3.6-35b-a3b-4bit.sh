# Model profile: Qwen3.6-35B-A3B 4-bit — MoE arm, new for the blog post.
# Hybrid SDPA + GDN linear attention AND MoE (upstream supported_models.md:
# "Qwen3.5 / 3.6 / 3.8 ... (3.6 adds MoE)"), so it exercises the GDN path and
# the expert path at once. The post's paged-varlen section already claims
# padding wastes rows in "attention, MLP, and MoE" with no MoE arm behind it.
#
#   MLX  mlx-community/Qwen3.6-35B-A3B-4bit : total 19.001 GiB
#        experts (mlp.switch_mlp.*) 16.875 | attn/embed 1.274
#        | router 0.020 | vision 0.832  -> text 18.169
#   GGUF Qwen3.6-35B-A3B-UD-Q4_K_M          : 20.61 GiB (+13.4%)
# Experts are 93% of the text weight. UD-IQ4_NL_XL (18.16 GiB) matches the
# MLX text weight to within 0.05% if a footprint-matched arm is ever wanted.
MODEL_NAME="Qwen3.6-35B-A3B-4bit"
GGUF_REPO="unsloth/Qwen3.6-35B-A3B-GGUF"
GGUF_FILE="Qwen3.6-35B-A3B-UD-Q4_K_M.gguf"
MLX_REPO="mlx-community/Qwen3.6-35B-A3B-4bit"
MLX_DIR_NAME="Qwen3.6-35B-A3B-4bit-mlx"
HF_REPO="mlx-community/Qwen3.6-35B-A3B-4bit"
HF_DIR_NAME="Qwen3.6-35B-A3B-4bit-mlx"
