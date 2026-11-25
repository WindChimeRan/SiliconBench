#!/bin/bash
# Update ExecuTorch to latest main and rebuild
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

REPO_DIR="$FRAMEWORKS_DIR/executorch"

echo "=== Updating ExecuTorch ==="

if [ ! -d "$REPO_DIR" ]; then
    echo "ExecuTorch not found at $REPO_DIR — running install instead"
    bash "$SCRIPT_DIR/install_executorch.sh"
    exit 0
fi

cd "$REPO_DIR"
git fetch -q origin main
EXECUTORCH_COMMIT=origin/main bash "$SCRIPT_DIR/install_executorch.sh"
# A .pte must come from the same ExecuTorch as its runtime; serve re-exports.
rm -f "$MODELS_DIR"/executorch/*/model.pte

echo "=== ExecuTorch updated ==="
