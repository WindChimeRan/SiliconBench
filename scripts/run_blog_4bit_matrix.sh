#!/bin/bash
# 4-bit blog matrix. Priority: 27B -> Gemma -> MoE. Never aborts on one arm.
cd /Users/ranzhang/workspace/applebench
export APPLEBENCH_METALSTAT=1
export PYTHONUNBUFFERED=1
BENCH_PY=.venvs/bench/bin/python
log(){ echo "[$(date '+%m-%d %H:%M:%S')] $*"; }

log "waiting for downloads + framework upgrades to finish"
while pgrep -f "dl2.sh" >/dev/null || pgrep -f "upgrade.sh" >/dev/null; do sleep 60; done
log "prerequisites done"
$BENCH_PY scripts/framework_version.py --all 2>/dev/null | head -30

outdir_for(){ APPLEBENCH_MODEL=$1 bash -c 'source scripts/config.sh >/dev/null 2>&1; echo "$RESULTS_DIR/agent"'; }

# ---- standard 4 engines via run_all (oMLX in its default SSD-offload mode) ----
run_standard(){
  local profile=$1 levels=$2 cap=$3
  log "=== $profile : standard arms (c=$levels, cap=${cap}s) ==="
  local ssd; ssd=$(mktemp -d /tmp/omlx-ssd-XXXXXX)
  CONCURRENCY_LEVELS="$levels" \
  FRAMEWORK_TIMEOUT_SECONDS="$cap" BENCHMARK_MAX_WALL_TIME="$cap" \
  OMLX_SERVE_EXTRA_ARGS="--paged-ssd-cache-dir $ssd --paged-ssd-cache-max-size 100GB --hot-cache-max-size 8GB" \
    bash scripts/run_all.sh --model "$profile" --split agent \
      llamacpp mlx_lm omlx vllm_metal 2>&1 | sed "s/^/  [$profile] /"
  rm -rf "$ssd"
  log "=== $profile : standard arms finished (exit ${PIPESTATUS[0]}) ==="
}

# ---- variant arm: explicit serve + labelled benchmark ----
run_variant(){
  local profile=$1 label=$2 port=$3 levels=$4 cap=$5 serve=$6 stop=$7
  log "--- $profile : $label (c=$levels) ---"
  export APPLEBENCH_MODEL="$profile"
  export VLLM_METAL_MAX_MODEL_LEN=16384 LLAMACPP_CTX_SIZE=65536
  local out ts; out=$(outdir_for "$profile"); ts=$(date +%Y%m%d_%H%M%S)
  mkdir -p "$out"
  if ! bash "scripts/$serve" > "$out/../${label}_serve_${ts}.log" 2>&1; then
     log "!! $label server failed to start — skipping"; bash "scripts/$stop" >/dev/null 2>&1; return 1
  fi
  $BENCH_PY scripts/benchmark.py \
      --framework "$label" --port "$port" \
      --concurrency "$(echo $levels | tr ' ' ',')" \
      --requests 100 --warmup 3 --split agent \
      --max-wall-time "$cap" \
      --output "$out/${label}_${ts}.json" \
      --outputs "$out/${label}_${ts}_outputs.jsonl" 2>&1 | sed "s/^/  [$label] /"
  local rc=${PIPESTATUS[0]}
  bash "scripts/$stop" >/dev/null 2>&1
  sleep 20
  log "--- $label done (rc=$rc) ---"
}

MTP_BASE='{"method":"mtp","model":"mlx-community/gemma-4-E4B-it-assistant-bf16","num_speculative_tokens":%d}'

########## 1. Qwen3.8-27B (priority) ##########
run_standard qwen3.8-27b-4bit "1 2 4" 9000
export OMLX_SERVE_EXTRA_ARGS="--no-cache --hot-cache-max-size 8GB"
run_variant qwen3.8-27b-4bit omlx_bounded 8005 "1 2 4" 9000 serve_omlx.sh stop_omlx.sh
unset OMLX_SERVE_EXTRA_ARGS
touch /tmp/matrix_done_27b

########## 2. Gemma 4 E4B ##########
run_standard gemma-4-e4b-it-4bit "1 8 16" 5400
for n in 1 2 3; do
  lv="1 8 16"; lbl="vllm_metal_mtp"
  [ "$n" != "1" ] && { lv="8"; lbl="vllm_metal_mtp_n$n"; }
  export VLLM_METAL_SERVE_EXTRA_ARGS="--no-async-scheduling --speculative-config $(printf "$MTP_BASE" $n)"
  run_variant gemma-4-e4b-it-4bit "$lbl" 8004 "$lv" 5400 serve_vllm_metal.sh stop_vllm_metal.sh
  unset VLLM_METAL_SERVE_EXTRA_ARGS
done
touch /tmp/matrix_done_gemma

########## 3. Qwen3.6-35B-A3B MoE ##########
run_standard qwen3.6-35b-a3b-4bit "1 2 4" 9000
touch /tmp/matrix_done_moe

log "ALL DONE"
for m in Qwen3.8-27B-4bit Gemma-4-E4B-it-4bit Qwen3.6-35B-A3B-4bit; do
  echo "  $m: $(ls results/$m/m5pro/agent/*.json 2>/dev/null | grep -vc metalstat) result files"
done
