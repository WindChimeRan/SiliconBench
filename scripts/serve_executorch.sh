#!/bin/bash
# Start ExecuTorch's OpenAI server, exporting the model to .pte on first use
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

REPO_DIR="$FRAMEWORKS_DIR/executorch"
VENV_DIR="$VENVS_DIR/executorch"
PTE="$ET_MODEL_DIR/model.pte"

if [ ! -d "$VENV_DIR" ]; then
    echo "Error: ExecuTorch venv not found. Run install_executorch.sh first."
    exit 1
fi

if [ "$ET_PIPELINE" = "muse_glimmer" ]; then
    SRC_WEIGHTS="$GGUF_MODEL"
else
    SRC_WEIGHTS="$HF_MODEL"
fi
if [ ! -f "$PTE" ] && [ ! -e "$SRC_WEIGHTS" ]; then
    echo "Error: $SRC_WEIGHTS not found. Run download_model.sh first."
    exit 1
fi

source "$VENV_DIR/bin/activate"
cd "$REPO_DIR"

# Export once per model; update_executorch.sh deletes stale exports, since a
# .pte must come from the same ExecuTorch as its runtime.
# ET_PIPELINE=muse_glimmer uses Muse Glimmer's own exporter and batching worker
# (examples/models/muse_glimmer) on the profile's GGUF, so ExecuTorch and
# llama.cpp run identical weights. Everything else: export_llm_hf on HF weights.
if [ ! -f "$PTE" ]; then
    echo "=== Exporting $MODEL_NAME to $ET_MODEL_DIR ==="
    mkdir -p "$ET_MODEL_DIR"
    if [ "$ET_PIPELINE" = "muse_glimmer" ]; then
        [ -x cmake-out/examples/models/muse-glimmer-batching/muse_glimmer_batching_worker ] \
            || make muse-glimmer-batching-mlx
        python -m executorch.examples.models.muse_glimmer.export.export_solo \
            --backend mlx \
            --gguf "$GGUF_MODEL" \
            --use-offgraph-kv-cache \
            --activation-dtype float16 \
            --max-prefill-chunk 512 \
            --output-dir "$ET_MODEL_DIR"
    else
        python -m executorch.backends.mlx.examples.llm.export_llm_hf \
            --model-id "$HF_MODEL" \
            --output "$PTE" \
            --use-offgraph-cache \
            --logits-to-keep selected \
            --max-ctx-len 16384 \
            --dtype bf16
    fi
    # The server reads the tokenizer and chat template from beside the .pte.
    for f in tokenizer.json tokenizer_config.json chat_template.jinja generation_config.json; do
        [ -f "$HF_MODEL/$f" ] && cp "$HF_MODEL/$f" "$ET_MODEL_DIR/"
    done
    # ExecuTorch's NFC normalizer drops combining marks ("Zürich" -> "Zurich");
    # every benchmark prompt is already NFC, so removing it keeps tokenization equal to HF's.
    python - "$ET_MODEL_DIR/tokenizer.json" <<'PY'
import json, sys
tok = json.load(open(sys.argv[1]))
if tok.get("normalizer") == {"type": "NFC"}:
    tok["normalizer"] = None
    json.dump(tok, open(sys.argv[1], "w"), ensure_ascii=False)
PY
fi

echo "=== Starting ExecuTorch server on port $EXECUTORCH_PORT ==="

COMMON_ARGS=(
    --model-path "$PTE"
    --model-id "$MODEL_NAME"
    --max-context "${EXECUTORCH_MAX_CTX:-16384}"
    --host 0.0.0.0
    --port "$EXECUTORCH_PORT"
)

if [ "$ET_PIPELINE" = "muse_glimmer" ]; then
    # The server rejects requests (429) once every session is busy instead of
    # queueing them. Muse's launcher defaults to 4 sessions, which would refuse
    # most of c8/c16, so give it the generic llm_server's defaults.
    python -m executorch.examples.models.muse_glimmer.serving.serve_batching \
        --worker-bin "$REPO_DIR/cmake-out/examples/models/muse-glimmer-batching/muse_glimmer_batching_worker" \
        --tokenizer-path "$ET_MODEL_DIR/tokenizer.json" \
        --hf-tokenizer "$ET_MODEL_DIR" \
        --backend mlx \
        --max-sessions 16 \
        --max-decode-sequences 8 \
        --max-inflight-requests 64 \
        "${COMMON_ARGS[@]}" \
        &> "$PROJECT_DIR/.frameworks/executorch_server.log" &
else
    case "$MODEL_NAME" in  # the chat template's generation header
        Gemma-4-*) HEADER=$'<|turn>model\n' ;;
        *) HEADER=$'<|im_start|>assistant\n' ;;
    esac
    # Requests without `tools` stop only at end-of-turn, as on the other engines,
    # instead of at the first special token: agent-split prompts replay tool-call
    # histories without `tools`, and Gemma 4's <|tool_call> is a special token.
    python -m executorch.examples.llm_server.python.serve \
        --worker-bin "$REPO_DIR/cmake-out/backends/mlx/examples/llm/llm_worker" \
        --tokenizer-path "$ET_MODEL_DIR" \
        --assistant-header "$HEADER" \
        --no-special-token-stops \
        "${COMMON_ARGS[@]}" \
        &> "$PROJECT_DIR/.frameworks/executorch_server.log" &
fi

echo $! > "$PROJECT_DIR/.frameworks/executorch_server.pid"
echo "PID: $(cat "$PROJECT_DIR/.frameworks/executorch_server.pid")"

# Wait for server to be ready (/health turns ok once the worker has loaded the model).
# Check our pid first: an ExecuTorch without --no-special-token-stops exits at once.
ET_PID=$(cat "$PROJECT_DIR/.frameworks/executorch_server.pid")
echo "Waiting for server to be ready..."
for i in $(seq 1 300); do
    if ! kill -0 "$ET_PID" 2>/dev/null; then
        echo "Error: ExecuTorch server process $ET_PID died during startup"
        tail -20 "$PROJECT_DIR/.frameworks/executorch_server.log"
        exit 1
    fi
    if curl -sf "http://localhost:$EXECUTORCH_PORT/health" 2>/dev/null | grep -q '"ok"' 2>/dev/null; then
        echo "ExecuTorch server is ready on port $EXECUTORCH_PORT"
        exit 0
    fi
    sleep 1
done

echo "Error: Server failed to start within 300 seconds"
cat "$PROJECT_DIR/.frameworks/executorch_server.log"
exit 1
