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
  # No shared cache dir pinned here: that used to hand every concurrency level
  # one oMLX cache directory, which defeated the per-level isolation this script
  # was relying on. OMLX_CACHE_MODE says what the arm is and serve_omlx.sh gives
  # each level its own cache.
  CONCURRENCY_LEVELS="$levels" \
  FRAMEWORK_TIMEOUT_SECONDS="$cap" BENCHMARK_MAX_WALL_TIME="$cap" \
  OMLX_CACHE_MODE="${OMLX_CACHE_MODE:-ssd}" \
    bash scripts/run_all.sh --model "$profile" --split agent \
      llamacpp mlx_lm omlx vllm_metal 2>&1 | sed "s/^/  [$profile] /"
  log "=== $profile : standard arms finished (exit ${PIPESTATUS[0]}) ==="
}

# ---- variant arm: explicit serve + labelled benchmark ----
# One server per concurrency level, same as run_all_apple.sh. A single server
# for the whole sweep let level 1 warm a prefix cache the later levels then hit,
# so a variant arm measured that way was not comparable with the standard arms
# it was drawn against — which is the mistake this whole matrix exists to avoid.
run_variant(){
  local profile=$1 label=$2 port=$3 levels=$4 cap=$5 serve=$6 stop=$7 model_kind=${8:-}
  log "--- $profile : $label (c=$levels) ---"
  export APPLEBENCH_MODEL="$profile"
  export VLLM_METAL_MAX_MODEL_LEN=16384 LLAMACPP_CTX_SIZE=65536
  # Pass the served model id explicitly for oMLX. Without --model, benchmark.py
  # falls back to /v1/models[0], and oMLX advertises the whole HF cache beside
  # its --model-dir: for gemma-4-e4b-it-4bit-mlx, whose lowercase name sorts
  # after RedHatAI--Qwen3-8B-speculator.dflash, [0] is a stray speculator and
  # every request 409s. run_all_apple.sh has passed this override since 81851ee;
  # run_variant never did, so a variant arm was one directory listing away from
  # silently benchmarking the wrong checkpoint.
  local model_flag=""
  if [ "$model_kind" = "mlx" ]; then
    local mlx_path
    mlx_path=$(APPLEBENCH_MODEL=$profile bash -c 'source scripts/config.sh >/dev/null 2>&1; echo "$MLX_MODEL"')
    model_flag="--model $(basename "$mlx_path")"
  fi
  local out ts; out=$(outdir_for "$profile"); ts=$(date +%Y%m%d_%H%M%S)
  mkdir -p "$out" "$out/.levels"
  local parts=() lvl part rc=0
  for lvl in $levels; do
    part="$out/.levels/${label}_${ts}_level_${lvl}.json"
    if ! bash "scripts/$serve" > "$out/../${label}_serve_${ts}_c${lvl}.log" 2>&1; then
       log "!! $label c=$lvl server failed to start — stopping this arm"
       bash "scripts/$stop" >/dev/null 2>&1
       break
    fi
    $BENCH_PY scripts/benchmark.py \
        --framework "$label" --port "$port" \
        --concurrency "$lvl" \
        --requests 100 --warmup 3 --split agent \
        --max-wall-time "$cap" \
        --output "$part" \
        --outputs "$out/${label}_${ts}_outputs.jsonl" \
        $model_flag 2>&1 | sed "s/^/  [$label c=$lvl] /"
    rc=${PIPESTATUS[0]}
    bash "scripts/$stop" >/dev/null 2>&1
    sleep 20
    [ -s "$part" ] && parts+=("$part")
  done
  if [ ${#parts[@]} -eq 0 ]; then
    log "--- $label produced no levels ---"
    return 1
  fi
  $BENCH_PY scripts/merge_levels.py --output "$out/${label}_${ts}.json" "${parts[@]}" \
    | sed "s/^/  [$label] /"
  rm -f "${parts[@]}"
  log "--- $label done (${#parts[@]}/$(echo $levels | wc -w | tr -d ' ') levels, rc=$rc) ---"
}

# ---- re-measure only the oMLX RAM-cache arm ----
# The blog's second oMLX series was measured with --no-cache, which is no prefix
# reuse at all, not the bounded in-memory cache its label claimed: oMLX ignores
# --hot-cache-max-size when no cache directory is set. OMLX_CACHE_MODE=ram is
# the real thing — prefix reuse in memory, nothing on disk — and it is what the
# other engines in the figure do. Labelled omlx_ram so it sits alongside the
# SSD arm rather than replacing it.
if [ "${1:-}" = "--omlx-ram" ]; then
  export OMLX_CACHE_MODE=ram
  # An optional second argument limits the re-measure to one profile, so a
  # single arm can be redone without paying for the other two.
  only="${2:-}"
  log "=== re-measuring the oMLX RAM-cache arm${only:+ ($only only)} ==="
  if [ -z "$only" ] || [ "$only" = "qwen3.8-27b-4bit" ]; then
    run_variant qwen3.8-27b-4bit     omlx_ram 8005 "1 2 4"  9000 serve_omlx.sh stop_omlx.sh mlx
  fi
  if [ -z "$only" ] || [ "$only" = "gemma-4-e4b-it-4bit" ]; then
    run_variant gemma-4-e4b-it-4bit  omlx_ram 8005 "1 8 16" 5400 serve_omlx.sh stop_omlx.sh mlx
  fi
  if [ -z "$only" ] || [ "$only" = "qwen3.6-35b-a3b-4bit" ]; then
    run_variant qwen3.6-35b-a3b-4bit omlx_ram 8005 "1 2 4"  9000 serve_omlx.sh stop_omlx.sh mlx
  fi
  log "=== omlx_ram re-measure complete ==="
  exit 0
fi

MTP_BASE='{"method":"mtp","model":"mlx-community/gemma-4-E4B-it-assistant-bf16","num_speculative_tokens":%d}'

# ---- re-measure the MTP draft-depth arms at concurrency 8 ----
# The post compares output throughput across draft depths at c=8. Depth 1 is
# measured as part of the Gemma arm above; depths 2 and 3 exist only here.
if [ "${1:-}" = "--mtp-depth" ]; then
  log "=== re-measuring MTP draft depths 2 and 3 at c=8 ==="
  for n in 2 3; do
    export VLLM_METAL_SERVE_EXTRA_ARGS="--no-async-scheduling --speculative-config $(printf "$MTP_BASE" $n)"
    run_variant gemma-4-e4b-it-4bit "vllm_metal_mtp_n$n" 8004 "8" 5400 serve_vllm_metal.sh stop_vllm_metal.sh
    unset VLLM_METAL_SERVE_EXTRA_ARGS
  done
  log "=== MTP draft-depth re-measure complete ==="
  exit 0
fi

########## 1. Qwen3.8-27B (priority) ##########
run_standard qwen3.8-27b-4bit "1 2 4" 9000
export OMLX_SERVE_EXTRA_ARGS="--no-cache --hot-cache-max-size 8GB"
run_variant qwen3.8-27b-4bit omlx_bounded 8005 "1 2 4" 9000 serve_omlx.sh stop_omlx.sh mlx
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
