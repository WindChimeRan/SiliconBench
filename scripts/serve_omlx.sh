#!/bin/bash
# Start omlx server
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

VENV_DIR="$VENVS_DIR/omlx"
OMLX_MODEL_DIR="$MODELS_DIR/omlx"

if [ ! -d "$VENV_DIR" ]; then
    echo "Error: omlx venv not found. Run install_omlx.sh first."
    exit 1
fi

source "$VENV_DIR/bin/activate"

# omlx is a multi-model server that auto-discovers every subdir/symlink
# in --model-dir. Run_all_mac.sh picks `/v1/models data[0]` for the API
# `model` field, so a stale extra symlink (e.g. Qwen3-0.6B left from a
# prior profile) silently wins on alphabetical/discovery order and the
# benchmark scores the wrong model. Make the dir contain ONLY the active
# model so discovery is unambiguous.
mkdir -p "$OMLX_MODEL_DIR"
ACTIVE_NAME="$(basename "$MLX_MODEL")"
for entry in "$OMLX_MODEL_DIR"/*; do
    [ -e "$entry" ] || continue
    [ "$(basename "$entry")" = "$ACTIVE_NAME" ] && continue
    rm -rf "$entry"
done
ln -snf "$MLX_MODEL" "$OMLX_MODEL_DIR/$ACTIVE_NAME"
echo "omlx model dir reset to single entry: $ACTIVE_NAME -> $MLX_MODEL"

echo "=== Starting omlx server on port $OMLX_PORT ==="

# OMLX_SERVE_EXTRA_ARGS passes extra flags to `omlx serve`. omlx enables a
# persistent SSD-backed prefix cache by default (~/.omlx/cache, 100GB) that no
# other framework here has: it survives restarts and spans models, so it both
# inflates results once warm and depresses them once saturated.
#
# Default to a fresh cache directory per server start. Restarting the server
# between concurrency levels is not enough on its own for omlx: its cache is on
# disk and outlives the process, so without a new directory each level would
# still inherit the one before it. Pass --hot-cache-max-size explicitly too,
# because omlx persists CLI args to ~/.omlx/settings.json and its documented
# defaults are not what you actually get. Override either by naming them in
# OMLX_SERVE_EXTRA_ARGS.
OMLX_CACHE_ARGS=""
case "${OMLX_SERVE_EXTRA_ARGS:-}" in
    *--paged-ssd-cache-dir*|*--no-cache*) ;;
    *)
        OMLX_FRESH_CACHE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/omlx-ssd-XXXXXX")"
        OMLX_CACHE_ARGS="--paged-ssd-cache-dir $OMLX_FRESH_CACHE_DIR --paged-ssd-cache-max-size 100GB"
        echo "omlx: fresh SSD cache dir $OMLX_FRESH_CACHE_DIR"
        ;;
esac
case "${OMLX_SERVE_EXTRA_ARGS:-}" in
    *--hot-cache-max-size*) ;;
    *) OMLX_CACHE_ARGS="$OMLX_CACHE_ARGS --hot-cache-max-size 0" ;;
esac

omlx serve \
    --model-dir "$OMLX_MODEL_DIR" \
    --port "$OMLX_PORT" \
    --host 0.0.0.0 \
    ${OMLX_CACHE_ARGS} \
    ${OMLX_SERVE_EXTRA_ARGS:-} \
    &> "$PROJECT_DIR/.frameworks/omlx_server.log" &

echo $! > "$PROJECT_DIR/.frameworks/omlx_server.pid"
echo "PID: $(cat "$PROJECT_DIR/.frameworks/omlx_server.pid")"

# Wait for server to be ready.
# Verify OUR pid is alive first: /v1/models answers from whatever holds the
# port, so a stale omlx-server from an earlier run makes a failed start
# ("Address already in use") look successful.
OMLX_PID=$(cat "$PROJECT_DIR/.frameworks/omlx_server.pid")
echo "Waiting for server to be ready..."
for i in $(seq 1 300); do
    if ! kill -0 "$OMLX_PID" 2>/dev/null; then
        echo "Error: omlx server process $OMLX_PID died during startup"
        tail -20 "$PROJECT_DIR/.frameworks/omlx_server.log"
        exit 1
    fi
    if curl -s "http://localhost:$OMLX_PORT/v1/models" > /dev/null 2>&1; then
        echo "omlx server is ready on port $OMLX_PORT (pid $OMLX_PID)"
        exit 0
    fi
    sleep 1
done

echo "Error: Server failed to start within 300 seconds"
cat "$PROJECT_DIR/.frameworks/omlx_server.log"
exit 1
