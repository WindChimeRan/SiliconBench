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
# labels in the cluster region; installed alongside matplotlib explicitly
# (not relying on a transitive pull) so this works the same regardless of
# whether metalstat is installed below.
uv pip install aiohttp adjustText matplotlib

# metalstat (Apple's Metal memory-sidecar tool, used only by
# run_all_apple.sh) depends on pyobjc-framework-metal, which requires macOS
# (`sw_vers`) to build — skip it on Linux, where there's no Metal to profile
# and run_all_dgxspark.sh never references APPLEBENCH_METALSTAT anyway.
if [ "$(uname -s)" = "Darwin" ]; then
    uv pip install metalstat
fi

echo "=== Benchmark environment installed ==="
