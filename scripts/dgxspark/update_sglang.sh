#!/bin/bash
# Update sglang to latest (CUDA, DGX Spark)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/config_dgxspark.sh"

VENV_DIR="$VENVS_DIR/sglang_dgxspark"
REPO_DIR="$FRAMEWORKS_DIR/sglang_dgxspark"

echo "=== Updating sglang (CUDA) ==="

if [ ! -d "$VENV_DIR" ] || [ ! -d "$REPO_DIR" ]; then
    echo "Venv or repo not found — running install instead"
    bash "$SCRIPT_DIR/dgxspark/install_sglang.sh"
    exit 0
fi

cd "$REPO_DIR"
git pull

source "$VENV_DIR/bin/activate"
uv pip install --upgrade --pre torch --index-url https://download.pytorch.org/whl/nightly/cu130
uv pip install --upgrade -e "$REPO_DIR/python[all]"

echo "=== sglang updated ==="
