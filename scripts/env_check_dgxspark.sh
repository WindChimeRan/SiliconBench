#!/bin/bash
# SiliconBench — Verify DGX Spark system prerequisites and framework readiness
# Exit 1 on hard errors (missing system tools), 0 otherwise.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

ERRORS=0
WARNINGS=0

ok()   { echo "  [ok]   $1"; }
fail() { echo "  [FAIL] $1"; echo "         $2"; ERRORS=$((ERRORS + 1)); }
warn() { echo "  [warn] $1"; echo "         $2"; WARNINGS=$((WARNINGS + 1)); }

check_cmd() {
    local label="$1" cmd="$2" hint="$3"
    if command -v "$cmd" &>/dev/null; then
        ok "$label"
    else
        fail "$label not found" "Install: $hint"
    fi
}

echo "=== SiliconBench Environment Check (DGX Spark) ==="
echo ""

# --- Platform ---
echo "Platform:"
if [ "$(uname -s)" = "Linux" ]; then
    ok "Linux ($(uname -s))"
else
    fail "Requires Linux (found: $(uname -s))" ""
fi

ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
    ok "Grace ARM64 ($ARCH)"
else
    warn "Not aarch64 (found: $ARCH)" "DGX_CUDA_ARCH=$DGX_CUDA_ARCH assumes GB10 (sm_121) — override if this is a different CUDA card"
fi

if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    ok "nvidia-smi"
else
    fail "nvidia-smi not found or GPU not visible" "Check NVIDIA driver install"
fi

if command -v nvcc &>/dev/null; then
    NVCC_VERSION=$(nvcc --version | grep -oP 'release \K[0-9]+' | head -1)
    if [ -n "$NVCC_VERSION" ] && [ "$NVCC_VERSION" -ge 13 ]; then
        ok "CUDA toolkit ($(nvcc --version | grep -oP 'release \K[0-9.]+' | head -1))"
    else
        warn "CUDA toolkit found but not 13.x" "GB10 (sm_121) requires CUDA 13.x to build llama.cpp/vllm/sglang"
    fi
elif [ -f "$FRAMEWORKS_DIR/llama.cpp_dgxspark/build/bin/llama-server" ]; then
    warn "nvcc not found (llama.cpp already built)" "Install CUDA 13.x toolkit for rebuilds"
else
    fail "nvcc not found" "Install CUDA 13.x toolkit"
fi
echo ""

# --- System tools ---
echo "Required tools:"
check_cmd "uv"  "uv"  "curl -LsSf https://astral.sh/uv/install.sh | sh"

if command -v cmake &>/dev/null; then
    ok "cmake"
elif [ -f "$FRAMEWORKS_DIR/llama.cpp_dgxspark/build/bin/llama-server" ]; then
    warn "cmake not found (llama.cpp already built)" "apt install cmake"
else
    fail "cmake not found" "Install: apt install cmake"
fi

if command -v gcc &>/dev/null; then
    ok "gcc"
else
    fail "gcc not found" "Install: apt install build-essential"
fi

check_cmd "huggingface-cli (hf)" "hf" "uv tool install huggingface_hub"
echo ""

# --- Python 3.12 ---
echo "Python:"
if command -v uv &>/dev/null && uv python find 3.12 &>/dev/null 2>&1; then
    ok "Python 3.12 ($(uv python find 3.12 2>/dev/null))"
elif command -v python3.12 &>/dev/null; then
    ok "Python 3.12 ($(python3.12 --version 2>&1))"
else
    fail "Python 3.12 not found" "Install: uv python install 3.12"
fi
echo ""

# --- Framework installs ---
echo "Frameworks (run install scripts if missing):"

if [ -f "$FRAMEWORKS_DIR/llama.cpp_dgxspark/build/bin/llama-server" ]; then
    ok "llama.cpp"
else
    warn "llama.cpp not built" "Run: scripts/dgxspark/install_llamacpp.sh"
fi

if [ -d "$VENVS_DIR/vllm_dgxspark" ]; then
    ok "vllm"
else
    warn "vllm venv not found" "Run: scripts/dgxspark/install_vllm.sh"
fi

if [ -d "$VENVS_DIR/sglang_dgxspark" ]; then
    ok "sglang"
else
    warn "sglang venv not found" "Run: scripts/dgxspark/install_sglang.sh"
fi
echo ""

# --- Models ---
echo "Models (run scripts/download_model.sh --formats gguf,hf if missing):"

if [ -f "$GGUF_MODEL" ]; then
    ok "GGUF: $GGUF_FILE"
else
    warn "GGUF model missing" "$GGUF_MODEL"
fi

if [ -d "$HF_MODEL" ]; then
    ok "HF: $(basename "$HF_MODEL")"
else
    warn "HF model missing" "$HF_MODEL"
fi
echo ""

# --- Benchmark venv ---
echo "Benchmark:"
if [ -d "$VENVS_DIR/bench" ]; then
    ok "bench venv"
else
    warn "bench venv not found" "Run: scripts/install_bench.sh"
fi
echo ""

# --- Summary ---
echo "==========================================="
if [ $ERRORS -gt 0 ]; then
    echo " $ERRORS error(s), $WARNINGS warning(s)"
    echo " Fix errors before proceeding."
    echo "==========================================="
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo " All prerequisites met, $WARNINGS warning(s)"
    echo "==========================================="
    exit 0
else
    echo " All checks passed"
    echo "==========================================="
    exit 0
fi
