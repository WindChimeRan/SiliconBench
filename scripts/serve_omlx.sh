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

# OMLX_SERVE_EXTRA_ARGS passes extra flags to `omlx serve`.
#
# oMLX is the only engine in this roster with a DISK-backed prefix cache
# (~/.omlx/cache, 100 GB by default, survives restarts, spans models). Every
# other engine reuses repeated prompt prefixes from memory and nothing else:
# llama.cpp per slot, vllm-metal's automatic prefix caching, sglang's
# RadixAttention. Comparing oMLX with its SSD tier on is comparing it against a
# capability nobody else has.
#
# So the default here is a bounded IN-MEMORY prefix cache with no SSD tier —
# oMLX reuses prefixes like everyone else, and writes nothing to disk. Three
# settings are needed together, all verified against omlx dc312e6e:
#   * OMLX_HOT_CACHE_ONLY=true — skips directory init, the writer thread and
#     every SSD read/write (omlx/cache/paged_ssd_cache.py); read from the
#     environment at omlx/settings.py:1134, there is no CLI flag for it.
#   * --paged-ssd-cache-dir — still required, because omlx/cache/factory.py
#     builds no cache at all when the dir is None. In this mode it stays empty.
#   * --hot-cache-max-size > 0 — omlx/cli.py honours it ONLY when a cache dir
#     is set, and forces it to 0 otherwise, so the two go together.
#
# --no-cache is NOT this. It disables prefix reuse entirely and silently
# ignores --hot-cache-max-size (same cli.py gate), which leaves oMLX the only
# engine in the comparison with no prefix reuse at all — unfair in the other
# direction. It stays available through OMLX_SERVE_EXTRA_ARGS as a deliberate
# "no reuse" arm.
#
# The dir is a fresh mktemp per start even though nothing should be written to
# it: if hot-cache-only ever stops applying, a fresh dir still stops one
# concurrency level from inheriting the previous level's cache.
#
# omlx persists CLI args to ~/.omlx/settings.json (omlx/cli.py lists the
# persistable fields), so a flag passed once silently becomes the default for
# every later run. That is why these are passed explicitly on every start.
OMLX_HOT_CACHE_SIZE="${OMLX_HOT_CACHE_SIZE:-8GB}"
OMLX_CACHE_ARGS=""
case "${OMLX_SERVE_EXTRA_ARGS:-}" in
    *--no-cache*)
        echo "omlx: prefix reuse disabled entirely (--no-cache from OMLX_SERVE_EXTRA_ARGS)"
        ;;
    *--paged-ssd-cache-dir*)
        echo "omlx: cache dir supplied by OMLX_SERVE_EXTRA_ARGS"
        ;;
    *)
        OMLX_FRESH_CACHE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/omlx-cache-XXXXXX")"
        OMLX_CACHE_ARGS="--paged-ssd-cache-dir $OMLX_FRESH_CACHE_DIR --paged-ssd-cache-max-size 100GB"
        export OMLX_HOT_CACHE_ONLY=true
        echo "omlx: in-memory prefix cache ($OMLX_HOT_CACHE_SIZE), no SSD tier"
        ;;
esac
case "${OMLX_SERVE_EXTRA_ARGS:-}" in
    # Adding a hot-cache size next to --no-cache would be inert and would put a
    # setting into the recorded serve_env that never applied.
    *--no-cache*|*--hot-cache-max-size*) ;;
    *) OMLX_CACHE_ARGS="$OMLX_CACHE_ARGS --hot-cache-max-size $OMLX_HOT_CACHE_SIZE" ;;
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
