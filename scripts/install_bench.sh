#!/bin/bash
# Install benchmark dependencies in its own venv
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

VENV_DIR="$VENVS_DIR/bench"

echo "=== Installing benchmark environment ==="

if [ -d "$VENV_DIR" ]; then
    echo "Venv already exists at $VENV_DIR"
else
    uv venv "$VENV_DIR" --python 3.12
fi

source "$VENV_DIR/bin/activate"
# adjustText is used by draw/plot_pareto.py to repel overlapping framework
# labels in the cluster region; matplotlib comes in transitively via metalstat.
uv pip install aiohttp metalstat adjustText

echo "=== Benchmark environment installed ==="
