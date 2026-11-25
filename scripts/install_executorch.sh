#!/bin/bash
# Install ExecuTorch (MLX backend) from source and build the worker behind its OpenAI server
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

REPO_DIR="$FRAMEWORKS_DIR/executorch"
VENV_DIR="$VENVS_DIR/executorch"

# After an OS upgrade the Command Line Tools SDK can be newer than Xcode's linker.
XCODE_SDK="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
[ -d "$XCODE_SDK" ] && export SDKROOT="$XCODE_SDK"

echo "=== Installing ExecuTorch ==="

if [ -d "$REPO_DIR" ]; then
    echo "ExecuTorch already cloned, run update_executorch.sh to update"
else
    git clone https://github.com/pytorch/executorch.git "$REPO_DIR"
fi

cd "$REPO_DIR"
# EXECUTORCH_COMMIT pins a commit; update_executorch.sh passes origin/main.
[ -n "$EXECUTORCH_COMMIT" ] && git checkout -q "$EXECUTORCH_COMMIT"
git submodule update --init --recursive -q

if [ -d "$VENV_DIR" ]; then
    echo "Venv already exists at $VENV_DIR"
else
    uv venv --seed "$VENV_DIR" --python 3.12
fi

source "$VENV_DIR/bin/activate"
./install_executorch.sh --editable
# ExecuTorch pins transformers 5.0.0rc1; Gemma 4 needs >= 5.10.
uv pip install "transformers==5.19.0" -r examples/llm_server/python/requirements.txt

rm -rf cmake-out/include  # headers from an older install shadow the new sources
cmake --preset mlx-release
cmake --build cmake-out --target install -j$(sysctl -n hw.ncpu)
cmake -S backends/mlx/examples/llm -B cmake-out/backends/mlx/examples/llm -DCMAKE_BUILD_TYPE=Release
cmake --build cmake-out/backends/mlx/examples/llm --target llm_worker -j$(sysctl -n hw.ncpu)

echo "=== ExecuTorch installed ==="
echo "Models are exported to .pte on first serve_executorch.sh"
