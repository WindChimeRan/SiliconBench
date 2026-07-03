#!/bin/bash
# Start mistral.rs server
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

SERVER="$FRAMEWORKS_DIR/mistral.rs/target/release/mistralrs"

if [ ! -f "$SERVER" ]; then
    echo "Error: mistralrs binary not found. Run install_mistralrs.sh first."
    exit 1
fi

if [ ! -f "$GGUF_MODEL" ]; then
    echo "Error: GGUF model not found. Run download_model.sh first."
    exit 1
fi

echo "=== Starting mistral.rs server on port $MISTRALRS_PORT ==="

# -m points at the local HF-format snapshot directory (not the bare HF_REPO
# id string) so mistral.rs resolves tokenizer/chat-template files from disk.
# Passing the repo id makes it hit the HF Hub API for a directory listing on
# every launch; that call can fail (e.g. a stale bundled CA root in a Rust
# TLS crate rejecting HF's current cert with "UnknownIssuer") and take the
# server down before it ever binds the port, taking the whole run with it.
"$SERVER" serve \
    -p "$MISTRALRS_PORT" \
    -m "$HF_MODEL" \
    --format gguf \
    -f "$GGUF_MODEL" \
    &> "$PROJECT_DIR/.frameworks/mistralrs_server.log" &

MISTRALRS_PID=$!
echo $MISTRALRS_PID > "$PROJECT_DIR/.frameworks/mistralrs_server.pid"
echo "PID: $(cat "$PROJECT_DIR/.frameworks/mistralrs_server.pid")"

# Wait for server to be ready. Bail out immediately if the process has
# already died (e.g. panics on an unsupported GGUF architecture in ~2s)
# instead of polling a dead port for the full 300s.
echo "Waiting for server to be ready..."
for i in $(seq 1 300); do
    if curl -s "http://localhost:$MISTRALRS_PORT/v1/models" > /dev/null 2>&1; then
        echo "mistral.rs server is ready on port $MISTRALRS_PORT"
        exit 0
    fi
    if ! kill -0 "$MISTRALRS_PID" 2>/dev/null; then
        echo "Error: mistral.rs process exited before becoming ready"
        cat "$PROJECT_DIR/.frameworks/mistralrs_server.log"
        exit 1
    fi
    sleep 1
done

echo "Error: Server failed to start within 300 seconds"
cat "$PROJECT_DIR/.frameworks/mistralrs_server.log"
exit 1
