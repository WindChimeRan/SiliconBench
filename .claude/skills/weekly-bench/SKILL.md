---
name: weekly-bench
description: Run the weekly SiliconBench pipeline unattended — update frameworks, benchmark all 9, diagnose and fix per-framework failures, commit fixes as separate commits, sync results. Use this when the user says "run the weekly benchmark" or similar.
---

# Weekly Bench Orchestrator

You are orchestrating SiliconBench's weekly benchmark run. Your job is to execute the full pipeline (`update_all.sh` → `run_all.sh` for each split → `sync_github.sh`) unattended, recover from per-framework failures with targeted fixes when you can, and produce a structured journal so the user can review what happened on Monday morning.

This skill is for this repo only. It assumes `caffeinate`, bash, and all the scripts in `scripts/` exist. It targets the **Apple Silicon** track: `run_all.sh` / `update_all.sh` / `env_check.sh` are thin platform dispatchers that `exec` into the `*_apple.sh` variants on macOS, where all the real logic lives — so `run_all.sh` invocations below still work unchanged, but the running process shows up as `run_all_apple.sh`.

## Splits

The benchmark runs over **two prompt splits** by default: `chat` (single-turn) and `agent` (multi-turn, ~4K input tokens, prefill-heavy). Each split lives in its own results subdirectory and produces its own `comparison.json` + `REPORT.md`:

```
results/<MODEL>/
├── chat/{<fw>_<ts>.json, comparison.json, REPORT.md}
├── agent/{<fw>_<ts>.json, comparison.json, REPORT.md}
├── weekly_<DATE>.log
└── weekly_<DATE>.journal.md
```

Treat the unit of success as the **(framework, split) cell**, not the framework. A framework can pass chat and fail agent — both must be tracked independently.

## Goal

Finish the weekly run with as many (framework, split) cells benchmarked as possible, leaving behind:
1. Updated `results/<MODEL>/<split>/comparison.json` and `REPORT.md` for each split
2. A structured journal at `results/<MODEL>/weekly_<YYYY-MM-DD>.journal.md`
3. Any auto-fix commits pushed to a `weekly/<YYYY-MM-DD>` branch (never main directly)

It is **not** your job to heroically fix every failure. A clear failure report is more valuable than a silent over-fix that hides a real regression.

## Phases

### Phase 0 — Set up

1. Determine today's date: `DATE=$(date +%Y-%m-%d)`
2. Read the model name from `scripts/config.sh` (or let the user specify). Default: whatever `APPLEBENCH_MODEL` resolves to.
3. **Identify the machine before anything writes.** `sysctl -n machdep.cpu.brand_string`.
   The Apple track is no longer single-machine: the legacy tree
   `results/<MODEL>/<split>/` belongs to the **M2 Max**, and a second machine must
   scope itself with `APPLEBENCH_RESULTS_SUBDIR` (e.g. `m5pro` →
   `results/<MODEL>/m5pro/<split>/`). Getting this wrong is destructive, not
   cosmetic — `run_all_apple.sh` deletes stale results in the active split dir at
   startup, and an unscoped run on a second machine once wiped 40 of the first
   machine's result files. A guard now refuses to delete results whose recorded
   `machine.chip` differs, but it can only see files that carry the `machine` field
   (added 2026-08-16); anything older is invisible to it.
   Set the subdir **before** the first run, and confirm `$RESULTS_DIR` points where
   you intend.
4. `RESULTS_DIR=results/<MODEL_NAME>${APPLEBENCH_RESULTS_SUBDIR:+/$APPLEBENCH_RESULTS_SUBDIR}`
5. `JOURNAL=$RESULTS_DIR/weekly_$DATE.journal.md`
6. Check for prior journals in `$RESULTS_DIR/weekly_*.journal.md`. Read the most recent 1-2 to learn:
   - Which frameworks were skipped and why (don't re-fight the same battles)
   - What auto-fixes were applied previously (you may need to re-apply or roll forward)
7. Create a fresh `weekly/<DATE>` git branch. All auto-fix commits land here, not on main.
8. Initialize the journal with a preamble (see Journal Format below).

### Phase 1 — Kick off the happy path in background

Run `scripts/weekly_bench.sh` as a background process:

```bash
bash scripts/weekly_bench.sh 2>&1
```

Use `run_in_background: true`. Capture the bash job ID. Then use the `Monitor` tool to stream output. The wrapper runs **two full passes** of `run_all.sh` — one per split (chat, then agent) — so expect ~18 framework cycles total (9 frameworks × 2 splits) before `Weekly run finished`.

While monitoring, watch for these patterns:
- `"run_all.sh --split chat"` / `"run_all.sh --split agent"` — split boundary
- `" Benchmarking: <name>"` — a framework run is starting
- `" SiliconBench complete!"` — one split finished cleanly
- Framework-level errors (non-zero exits from serve/benchmark — `run_all.sh` uses `|| true` per framework, so it will continue past failures)
- `"Weekly run finished"` — wrapper finished

**Do not intervene on normal failures** — let `run_all.sh` pass through all frameworks once, even if some fail. Recovery happens in Phase 2.

**Track the active split** so you know which subdirectory the current framework's results land in (`results/<MODEL>/chat/` vs `results/<MODEL>/agent/`).

**But do detect hangs.** Per-framework wall-time budget depends on the split:
- **chat split**: a single framework should complete in ~20-40 minutes. Hang threshold: 45 minutes for the same framework, or 30 minutes of unchanged log.
- **agent split**: prompts are ~4K input tokens — both prefill and decode are slower, and KV cache pressure at concurrency 16 is much higher. Allow up to ~60-90 minutes per framework before declaring a hang. Hang threshold: 90 minutes for the same framework, or 45 minutes of unchanged log.

Use `ScheduleWakeup` to check the log every 30 minutes. On each check, tail the log and compare to the previous check:
- If a new framework has started or completed → progress is normal, continue waiting.
- If the log is unchanged past the threshold for the active split → it is hung. Kill the `benchmark.py` process for that framework (`kill <PID>`), which will unblock the orchestrator to continue. Do **not** kill the orchestrator itself (`weekly_bench.sh`, or `run_all_apple.sh` — the `run_all.sh` dispatcher `exec`s into it, so in `ps` it appears as `run_all_apple.sh`, not `run_all.sh`).
- If the whole run has been silent for >20 minutes with no output, tail the log file (`results/<MODEL>/weekly_<DATE>.log`) via Read to check state. If truly hung (no process activity), fall back to Phase 3 (post-mortem).

### Phase 2 — Identify failures

When Phase 1 finishes, inventory what succeeded and what didn't, **per (framework, split)**:

**File presence is not success.** A framework can serve, answer every request with
an error, and still write a complete, well-formed result file. Judging by
`find`-and-exists alone has already produced false `ok`s for six cells in one run:
four where ollama 404'd on all 300 requests, and two where omlx served an entirely
different model. Inventory on **three** signals — the file exists, its failure rate
is sane, and it served the model you asked for:

```bash
# Inventory each (framework, split) cell on existence + failure rate + served model.
# $RESULTS_DIR is the model's results dir (add /m5pro or /dgxspark when scoped).
for split in chat agent; do
    for fw in llamacpp mlx_lm mistralrs vllm_metal vllm_mlx omlx ollama hf_transformers sglang; do
        recent=$(find "$RESULTS_DIR/$split" -maxdepth 1 -name "${fw}_*.json" \
                     ! -name '*_metalstat*' -mtime -1 2>/dev/null | head -1)
        if [ -z "$recent" ]; then
            # No file is ambiguous: a cell killed by the 1h cap is SIGTERMed
            # before benchmark.py writes its JSON, so it looks identical to a
            # serve failure. The run log is the only place they differ.
            if grep -q "⚠ $fw exceeded .* wall time" "$RESULTS_DIR/weekly_$DATE.log" 2>/dev/null; then
                echo "CAPPED  $split $fw  (hit the 1h wall-time cap)"
            else
                echo "FAILED  $split $fw"
            fi
            continue
        fi
        python - "$recent" "$fw" "$split" <<'PY'
import json, sys
path, fw, split = sys.argv[1:4]
d = json.load(open(path))
rows = d["concurrency_results"]
tot  = sum(r["successful"] + r["failed"] for r in rows)
fail = sum(r["failed"] for r in rows)
pct  = 100.0 * fail / tot if tot else 100.0
served  = str(d.get("model", ""))
machine = (d.get("machine") or {}).get("chip", "unknown")
status = "ok"
if pct >= 99.9: status = "ALL-FAILED"
elif pct >= 20: status = "DEGRADED"
print(f"{status:<10} {split} {fw}  fail={pct:.0f}%  served={served}  machine={machine}")
PY
    done
done
```

Classify each cell as:
- **ok** — recent file, low failure rate, and the served model is the one you asked for
- **degraded** — a result exists but a meaningful share of requests failed; usable only
  with a caveat, and never comparable to a clean cell without one
- **all-failed** — a result file full of failures. Treat as **failed**, not ok. Check
  the `error_samples`: an HTTP 404/409 means the server never had your model loaded
- **wrong-model** — `served` doesn't match the profile. The most dangerous outcome in
  the suite: a complete, plausible result file for a model that was never benchmarked.
  Always eyeball `served`
- **capped** — killed at `FRAMEWORK_TIMEOUT_SECONDS`; **no JSON exists**, so it is only
  distinguishable from a failure via the run log
- **failed** — no recent result file and no cap line

A framework can be `ok` in chat and `failed` in agent (or vice versa). Treat these as independent diagnoses — the agent split's larger context (~4K input tokens) exposes failure modes (KV cache OOM, prompt-length limits, tokenizer bugs on multi-turn payloads) that chat doesn't.

For each failed cell, gather evidence before deciding:

```bash
# 1. The framework's serve log (if the serve script captures it)
find . -name "*<fw>*.log" -mtime -1

# 2. The weekly log tail
tail -200 results/<MODEL>/weekly_<DATE>.log

# 3. Upstream changelog since the last successful run
cd .frameworks/<fw>
git log --oneline -30
git diff HEAD~10..HEAD -- CHANGELOG.md RELEASE_NOTES.md 2>/dev/null

# 4. What local script changes were made since the last successful run
git log --oneline scripts/*<fw>*.sh

# 5. Prior journal notes (already loaded in Phase 0)

# 6. Jetsam kills (macOS memory-pressure terminations). A jetsam'd process
#    looks identical to a plain crash in our logs, but the fix is different:
#    it's OOM, not a bug. Correlate any hits below by timestamp with when
#    this framework ran. Process names to grep for: python (mlx_lm, omlx,
#    vllm_metal, vllm_mlx, hf_transformers, sglang), llama-server (llamacpp),
#    ollama, mistralrs.
log show --last 24h --predicate 'eventMessage CONTAINS "jetsam"' 2>/dev/null | head -50

# 7. Metalstat sidecar artifacts for this (framework, split) cell, if the run had
#    APPLEBENCH_METALSTAT=1 (default for weekly_bench.sh). Paths:
#      results/<MODEL>/<split>/<fw>_<ts>_metalstat.jsonl   (per-second metrics)
#      results/<MODEL>/<split>/<fw>_<ts>_metalstat.meta.json
#    Read the jsonl to inspect gpu_util, gpu_freq_mhz, mem_used_gb, mem_pressure_level,
#    gpu_mem_allocated_gb, gpu_w. Useful for distinguishing "server crashed mid-benchmark"
#    (util drops to 0) vs "throttled hard" (freq drops, util stays high) vs "OOM-adjacent"
#    (mem_pressure_level=warn/critical, compressed grows). Complements step 6: jetsam
#    tells you the kernel killed the process; metalstat shows the pressure trajectory
#    that led up to it.
```

### Phase 3 — Diagnose and decide (per failed framework)

This is the judgment phase. You have the error, the upstream history, and the local script history. Decide one of three actions.

**OOM pre-check.** Before applying (A)/(B)/(C), re-read Phase 2 step 6. If the jetsam log shows a kill for this framework's process during its run window, short-circuit: classify the cell as **oom** in the journal (a distinct status, not `skipped`). The framework code is probably fine; the machine just did not have RAM for (model × concurrency × prompt length). Auto-fixing a jetsam'd cell would chase a ghost regression. Do not retry, do not edit scripts, and record the jetsam log line plus timestamps in the OOM Cells section of the journal.

#### (A) Auto-fix — you're confident about the root cause and the fix

Apply only when **all** of these are true:
- You can point at a specific upstream commit, changelog entry, or diff that explains the failure
- The fix is local to an adapter script (not changing benchmark logic)
- You can verify the fix works in isolation (see Phase 4)

**Scope of writes** — you may freely edit:
- `scripts/serve_<fw>.sh`
- `scripts/install_<fw>.sh`
- `scripts/update_<fw>.sh`
- `scripts/stop_<fw>.sh`
- `models/<profile>.sh`

**Do not edit**:
- `scripts/benchmark.py`, `scripts/collect_results.py`, `scripts/generate_report.py` (framework-agnostic, load-bearing)
- `scripts/config.sh` (shared config, high blast radius)
- `scripts/run_all.sh` / `scripts/run_all_apple.sh` (the dispatcher and its Apple variant), `scripts/weekly_bench.sh` (orchestration)
- Anything inside `.frameworks/` (upstream source trees)
- `prompts/` (dataset — unrelated to framework fixes)

If a fix would require editing one of the forbidden files, escalate — go to (C).

#### (B) Retry — you believe it's transient

Apply when:
- The error looks transient (network, OOM, port collision, thermal)
- You have no reason to believe a second attempt will fail the same way

Do not retry more than once. If the retry fails, fall through to (C).

#### (C) Skip — you're unsure, or the fix is out of scope

Apply when:
- The error is unfamiliar and you can't confidently diagnose
- The root cause is in the framework itself (not the adapter)
- The fix would require editing a forbidden file
- This framework was also skipped last week for the same reason (don't loop)
- You see "suspicious success" — the server ran but produced tokens/sec 10x off from last week (log prominently, don't fix, continue)

Skipping is a valid outcome. It's not failure — it's a clear signal for the user to triage.

### Phase 4 — Verify the fix (for Action A only)

Before re-running the full benchmark, verify in isolation. **Use the same split that failed** — a chat-only verify will not catch agent-specific regressions (longer context, multi-turn payloads).

```bash
# 1. Start the server manually
bash scripts/serve_<fw>.sh

# 2. Wait for readiness, then hit /v1/models
sleep 10
curl -s http://localhost:<port>/v1/models

# 3. Run a handful of quick requests via benchmark.py against the failing split.
# (use --requests 3 --concurrency 1 --warmup 0 to make it fast)
source .venvs/bench/bin/activate
python scripts/benchmark.py --framework <fw> --port <port> \
    --requests 3 --concurrency 1 --warmup 0 \
    --results-dir /tmp/fix_verify_$$ --split <chat|agent> || echo "verify failed"

# 4. Stop the server
bash scripts/stop_<fw>.sh

# 5. Clean up the verify results directory
rm -rf /tmp/fix_verify_$$
```

If the fix is supposed to repair both splits (e.g., a server-side flag change), verify both — run step 3 twice, once with `--split chat` and once with `--split agent`.

If verification fails:
- Revert the fix: `git checkout -- <files>`
- Fall through to Action (C), skip.

If verification succeeds:
- Commit the fix: `git add <files> && git commit -m "auto-fix(<fw>, <split>): <what changed> <why>"` — clear, specific messages. Mention which split(s) the fix is verified against. Reference the upstream commit or changelog entry if you have one.
- Continue to Phase 5.

### Phase 5 — Retry the failed/fixed cells

For each (framework, split) cell that (a) had a fix applied and verified, or (b) is being retried once for transient reasons, relaunch `run_all.sh` **targeted at one split**, listing only the frameworks that need to retry on that split:

```bash
# Retry chat-only failures
bash scripts/run_all.sh --split chat --skip-existing <fw1> <fw2> ...

# Retry agent-only failures (separate invocation)
bash scripts/run_all.sh --split agent --skip-existing <fw3> <fw4> ...
```

The `--skip-existing` flag ensures successful cells from Phase 1 (within that split's subdirectory) are preserved. Note that `--skip-existing` is per-split — it looks at `results/<MODEL>/<split>/`, so a chat retry will not touch agent results and vice versa.

**Scope the resume to the model that was actually interrupted.** `--skip-existing`
does two things at once: it skips frameworks with recent results, *and* it suppresses
the startup cleanup that would otherwise clear the directory. That second effect
applies to **every** model the resumed command covers — so pointing a resume at
models that have not run yet leaves their old files in place. Those files then compete
in `collect_results.py`'s **latest-by-mtime** selection, and a git operation touching
them is enough to make a months-old result outrank a fresh one.

This is not theoretical. A resumed 3-model sweep preserved a result from a *different
machine* (`/Users/haorzhang/...`, dated 2026-07-09), which then won the mtime race and
was published as a success for a cell that in fact segfaults on the current host.
After any resume, verify provenance before trusting the report:

```bash
python - "$RESULTS_DIR/<split>/comparison.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
for fw, v in d["results"].items():
    print(f"{fw:<18} {v.get('timestamp','?')}  {v.get('model','?')}")
PY
```
Every timestamp should be from this run, and every model path should be this
machine's. Anything else means a stale file won — remove it and regenerate.

After this retry pass, re-inventory all 18 cells. Update the journal with final status.

### Phase 6 — Finalize

1. Regenerate `comparison.json` and `REPORT.md` **per split** (the final `run_all.sh` call already does this for any split it ran, but re-run for any split you retried anything in):
   ```bash
   source .venvs/bench/bin/activate
   for split in chat agent; do
       if [ -d "$RESULTS_DIR/$split" ] && ls "$RESULTS_DIR/$split"/*_*.json &>/dev/null; then
           python scripts/collect_results.py --results-dir "$RESULTS_DIR/$split"
           python scripts/generate_report.py --results-dir "$RESULTS_DIR/$split"
       fi
   done
   ```

2. Write the final journal (see format below). One journal covers both splits.

3. Commit + push:
   - `git add $RESULTS_DIR && git commit -m "results: weekly run <DATE> (chat + agent)"` on the `weekly/<DATE>` branch (omit the part in parens if you only ran one split)
   - `git push -u origin weekly/<DATE>`
   - Do **not** merge to main automatically. The user reviews the branch.

4. Summary to user: how many cells ok / fixed / skipped per split, where the two REPORT.md files live, where the journal lives, what they should review.

## Journal Format

Write to `$RESULTS_DIR/weekly_<DATE>.journal.md` (one journal at the model level — covers both splits). Structure:

```markdown
# Weekly Bench Run — <DATE>

## Summary
- Started: <ISO timestamp>
- Finished: <ISO timestamp>
- Model: <MODEL_NAME>
- Splits run: <chat, agent | chat | agent>
- Status: <completed|completed_with_fixes|completed_with_skips|completed_with_oom|partial>
- Branch: weekly/<DATE>
- Reports: results/<MODEL>/chat/REPORT.md, results/<MODEL>/agent/REPORT.md

Cell status values: `ok` (benchmarked, low failure rate, correct model), `fixed` (auto-fix applied and verified), `degraded` (result exists but a meaningful share of requests failed — usable only with a caveat), `all-failed` (result file exists but ~100% of requests failed; treat as failed, and record the HTTP status from `error_samples`), `wrong-model` (the server answered as a *different* model than the profile — a complete, plausible file for something never benchmarked), `capped` (killed at `FRAMEWORK_TIMEOUT_SECONDS`; **no JSON exists**, so the run log is the only evidence), `skipped` (diagnosed but not fixed), `oom` (macOS jetsam killed the serving process during the run; distinct from `skipped` because the framework code is likely fine).

Record the machine for every run — `machine.chip` from any result file, or
`sysctl -n machdep.cpu.brand_string`. Results from different Apple machines are not
comparable, and the tree no longer implies which one produced them.

## Frameworks — chat split
| Framework | Status | Notes |
|-----------|--------|-------|
| llamacpp | ok | — |
| mlx_lm | ok | — |
| mistralrs | fixed | <short note, commit SHA> |
| vllm_metal | skipped | <short reason> |
| vllm_mlx | ok | — |
| omlx | ok | — |
| ollama | ok | — |
| sglang | ok | — |
| hf_transformers | ok | — |

## Frameworks — agent split
| Framework | Status | Notes |
|-----------|--------|-------|
| llamacpp | ok | — |
| mlx_lm | ok | — |
| mistralrs | oom | jetsam killed mistralrs at 02:14 during agent concurrency 16 |
| vllm_metal | ok | — |
| vllm_mlx | ok | — |
| omlx | ok | — |
| ollama | ok | — |
| sglang | ok | — |
| hf_transformers | ok | — |

## Fixes Applied

### <framework> (<split>)
- **Error**: <first ~5 lines of error>
- **Diagnosis**: <your reasoning, 1-3 sentences>
- **Reference**: <upstream commit URL, changelog link, or "none found">
- **Fix**: <file path + brief description>
- **Verification**: <what tests passed, which split(s)>
- **Commit**: <SHA and message>

## Skipped Cells

### <framework> (<split>)
- **Error**: <first ~5 lines of error>
- **Why skipped**: <your reasoning>
- **Prior occurrences**: <if this also happened in previous weeks, in the same split>
- **Relevant logs**: <file paths + key excerpts>

## OOM Cells

(Cells where macOS jetsam terminated the serving process. Not auto-fixed. The framework code is likely fine; the machine ran out of memory. Mitigation usually means reducing concurrency, picking a smaller model, or upgrading the host.)

### <framework> (<split>)
- **Jetsam line**: <raw `log show` line with process name, pid, and timestamp>
- **Run window**: <when the framework started vs. when it died>
- **Likely cause**: <one-sentence hypothesis, e.g. weights + KV cache at concurrency 16 exceeded free RAM>
- **Prior OOMs**: <if this cell OOM'd in previous weeks>

## Suspicious Successes

(Cells that ran but produced unusual numbers — flag for human review. Always compare chat-to-chat and agent-to-agent only — never cross-compare splits.)

### <framework> (<split>)
- **Observation**: <metric>: this week <N>, last week <M> (<X>x change)
- **Note**: Not auto-fixed. Please review.

### Two artifacts that masquerade as framework differences

Check both before reporting a framework as unreliable or slow.

**1. The agent split penalizes structured tool-call parsing.** `benchmark.py` counts
any response with ≤1 generated token as a silent failure, but agent prompts (BFCL V3 /
Hermes) frequently elicit a *tool call* as the correct next turn. Frameworks that parse
it into a structured field leave `content` empty and score 0 tokens → "failure";
frameworks that pass the raw `<tool_call>...` text through score tokens → "success".
Same model, same prompt, opposite verdicts. Observed: mlx_lm at 30/100 "failed" while
llamacpp and vllm_metal sat at 0/100 — the difference was serialization, not
reliability. **Do not report agent-split failure counts as reliability** without
checking `finish_reason` in `error_samples`:
- `tool_calls`, 0 tokens → **artifact**, not a failure
- `error`, 0 tokens → real server error
- `None`, 0 tokens → real silent failure

**2. Chunk-bundled streaming makes ITL unreliable.** When the run warns
`N/100 requests had server completion_tokens diverging >5% from SSE chunk count`,
per-request `throughput_avg_tps` and `itl_avg_ms` are chunk-derived and therefore
suspect for that framework. This has fired across llamacpp, mlx_lm and sglang
simultaneously (~1.2x), so it is not a per-framework signal. TTFT and aggregate token
counts are unaffected. Note it before publishing any cross-framework ITL ranking.

## Timeline
- HH:MM:SS — <event>
- HH:MM:SS — <event>
...
```

Keep the journal terse. It's a log for the user (and future Claude), not an essay.

## Principles

- **Finish the run, even if imperfect.** Don't let one broken cell block the others. A chat failure does not stop agent from running, and vice versa.
- **One fix attempt per (framework, split) cell per run.** No loops.
- **The unit of success is the cell, not the framework.** Track and report each (framework, split) independently — chat success doesn't excuse agent failure.
- **Never modify forbidden files** even if it would fix the issue. Escalate instead.
- **Branch, don't push to main.** All auto-fix commits land on `weekly/<DATE>` for user review.
- **Log everything.** If it's not in the journal, it didn't happen.
- **Suspicious success ≠ success.** Tokens/sec 10x off from last week is a signal, not a fix target. Compare chat-to-chat and agent-to-agent only — never cross-compare splits, since prefill-heavy agent prompts produce systematically different numbers. When metalstat sidecar data is present, cross-check: GPU-util at 100% with throughput down suggests a real regression; GPU-util near-idle suggests a serving-side bug (batching broken, client-side bottleneck, etc.); GPU freq dropping mid-run suggests thermal throttling.
- **Prior skips matter.** If a (framework, split) cell was skipped last week for reason Y and reason Y still holds, skip again silently (one line in the journal). Don't re-diagnose from scratch.

## When to bail out completely

Stop the whole workflow and surface a clear message to the user if:
- You cannot create the `weekly/<DATE>` branch (uncommitted changes on main, etc.)
- The bench venv is broken and `install_bench.sh` fails
- `caffeinate` is not available (running on non-macOS)
- `weekly_bench.sh` fails to start at all (script permissions, missing file, etc.)
- All 9 frameworks fail in Phase 1 (something systemic is wrong — maybe the model download, maybe a shared dep)

In these cases, the right answer is to stop and tell the user what's wrong, not to keep trying.
