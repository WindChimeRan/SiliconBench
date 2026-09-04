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

# OMLX_CACHE_MODE picks how oMLX reuses repeated prompt prefixes. It is one
# word instead of a combination of flags because the flags interact in ways
# that are easy to get wrong (see below), and because run_all_apple.sh exports
# it, so benchmark.py records it in every result's run_config.serve_env — the
# setting a reader needs to know is then in the file, not just in this script.
#
#   ram   (default) Prefix reuse in memory, nothing written to disk. This is
#         the comparable setting: every other engine in the roster reuses
#         prefixes from RAM and none has a disk tier — llama.cpp per slot,
#         vllm-metal's automatic prefix caching, sglang's RadixAttention.
#   ssd   Prefix reuse backed by disk, memory tier off. This is oMLX's own
#         shape and the protocol every published result before 2026-09-03 used,
#         so it reproduces them. A capability nothing else here has.
#   none  No prefix reuse at all. oMLX then does strictly less than the others.
#
# Mechanics, all read from omlx dc312e6e:
#   * OMLX_HOT_CACHE_ONLY=true skips directory init, the writer thread and all
#     SSD I/O (cache/paged_ssd_cache.py). There is no CLI flag for it; it is
#     read from the environment at settings.py:1134.
#   * --paged-ssd-cache-dir is required even in ram mode, because
#     cache/factory.py builds no cache at all when the dir is None. In ram mode
#     the directory stays empty.
#   * --hot-cache-max-size is honoured by cli.py ONLY when a cache dir is set,
#     and forced to 0 otherwise — so --no-cache silently ignores it. That is
#     why "none" passes no size: a recorded setting that never applied is worse
#     than no setting.
#   * The dir is a fresh mktemp per start in both caching modes. In ssd mode
#     that is what stops one concurrency level inheriting the previous level's
#     cache; in ram mode nothing is written there, but a fresh dir keeps that
#     protection if hot-cache-only ever stops applying.
#   * omlx persists CLI args to ~/.omlx/settings.json (cli.py lists the
#     persistable fields), so a flag passed once becomes the default for every
#     later run. Everything is therefore passed explicitly on every start.
#
# OMLX_SERVE_EXTRA_ARGS still passes flags through. If it names any cache flag,
# this script adds none of its own and the caller owns the whole configuration.
OMLX_CACHE_MODE="${OMLX_CACHE_MODE:-ram}"
OMLX_HOT_CACHE_SIZE="${OMLX_HOT_CACHE_SIZE:-8GB}"
OMLX_CACHE_ARGS=""

case "${OMLX_SERVE_EXTRA_ARGS:-}" in
    *--no-cache*|*--paged-ssd-cache-dir*|*--hot-cache-max-size*)
        echo "omlx: cache flags supplied by OMLX_SERVE_EXTRA_ARGS; OMLX_CACHE_MODE ignored"
        ;;
    *)
        case "$OMLX_CACHE_MODE" in
            ram)
                OMLX_FRESH_CACHE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/omlx-cache-XXXXXX")"
                OMLX_CACHE_ARGS="--paged-ssd-cache-dir $OMLX_FRESH_CACHE_DIR --paged-ssd-cache-max-size 100GB --hot-cache-max-size $OMLX_HOT_CACHE_SIZE"
                export OMLX_HOT_CACHE_ONLY=true
                echo "omlx: cache mode ram — prefix reuse in memory ($OMLX_HOT_CACHE_SIZE), nothing on disk"
                ;;
            ssd)
                OMLX_FRESH_CACHE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/omlx-cache-XXXXXX")"
                # Two deliberate departures from a stock install, both forced:
                #   * the cache directory. oMLX defaults to ~/.omlx/cache, which
                #     persists across restarts and models — exactly what let one
                #     concurrency level inherit the previous level's cache.
                #   * the size cap. oMLX's own default is "auto" (10% of SSD
                #     capacity, settings.py CacheSettings.ssd_cache_max_size),
                #     but "auto" is only understood on the settings path:
                #     parse_size() raises ValueError on it, so passing it as a
                #     CLI flag fails at startup. 100GB is stated explicitly and
                #     is what "auto" resolves to on this 1 TB machine anyway.
                #     The cap never binds either way — these runs write under 1 GB.
                # The hot tier stays at 0, which IS oMLX's shipped default.
                OMLX_CACHE_ARGS="--paged-ssd-cache-dir $OMLX_FRESH_CACHE_DIR --paged-ssd-cache-max-size 100GB --hot-cache-max-size 0"
                export OMLX_HOT_CACHE_ONLY=false
                echo "omlx: cache mode ssd — oMLX's own default (disk cache, no memory tier), fresh dir per start"
                ;;
            none)
                OMLX_CACHE_ARGS="--no-cache"
                echo "omlx: cache mode none — no prefix reuse"
                ;;
            *)
                echo "Error: OMLX_CACHE_MODE must be ram, ssd or none (got '$OMLX_CACHE_MODE')"
                exit 1
                ;;
        esac
        ;;
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
