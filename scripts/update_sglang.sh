#!/bin/bash
# Update sglang to latest
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

VENV_DIR="$VENVS_DIR/sglang"
REPO_DIR="$FRAMEWORKS_DIR/sglang"

echo "=== Updating sglang ==="

if [ ! -d "$VENV_DIR" ] || [ ! -d "$REPO_DIR" ]; then
    echo "Venv or repo not found — running install instead"
    bash "$SCRIPT_DIR/install_sglang.sh"
    exit 0
fi

cd "$REPO_DIR"
# Install-time swap leaves the working tree in a state `git pull --ff-only`
# refuses: pyproject.toml is modified (the upstream CUDA variant was replaced
# with the Apple MPS one) AND pyproject_other.toml is deleted (it was mv'd onto
# pyproject.toml). Restore both from HEAD so the merge is clean; the swap is
# re-applied right after the pull (lines below). Idempotent: `git checkout --`
# is a no-op when the file already matches HEAD.
git checkout -- python/pyproject.toml 2>/dev/null || true
git checkout -- python/pyproject_other.toml 2>/dev/null || true
git pull --ff-only

# Re-apply the MPS pyproject swap.
if [ -f "$REPO_DIR/python/pyproject_other.toml" ]; then
    rm -f "$REPO_DIR/python/pyproject.toml"
    mv "$REPO_DIR/python/pyproject_other.toml" "$REPO_DIR/python/pyproject.toml"
fi

source "$VENV_DIR/bin/activate"
uv pip install --upgrade -e "$REPO_DIR/python[all_mps]"
uv pip install --upgrade mlx mlx-lm

echo "=== sglang updated ==="
