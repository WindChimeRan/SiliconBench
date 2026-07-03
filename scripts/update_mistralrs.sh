#!/bin/bash
# Update mistral.rs to latest and rebuild
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

REPO_DIR="$FRAMEWORKS_DIR/mistral.rs"

# Ensure cargo is on PATH (rustup installs to ~/.cargo/bin but unattended /
# nohup'd shells don't source ~/.zshrc). Same cargo-PATH fix used by other
# cargo-based frameworks' update scripts.
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

echo "=== Updating mistral.rs ==="

cd "$REPO_DIR"
git pull
MISTRALRS_METAL_PRECOMPILE=0 cargo build --release --features "metal accelerate"

echo "=== mistral.rs updated ==="
