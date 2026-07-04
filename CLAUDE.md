# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

SiliconBench benchmarks local LLM inference frameworks side-by-side across two hardware platforms. **Apple Silicon** (primary track) covers 9 frameworks: llama.cpp, mlx_lm, mistral.rs, vllm-metal, vllm-mlx, omlx, ollama, hf_transformers, sglang. **NVIDIA DGX Spark** (secondary track, Grace CPU + Blackwell GB10 GPU, Linux) covers the 3 frameworks common to both hardware families: llama.cpp, vllm, sglang. All frameworks serve an OpenAI-compatible API; the benchmark hits `/v1/chat/completions` with streaming and measures TTFT, throughput, ITL, and latency at concurrency levels 1/8/16. See "Platform Dispatch" below for how the two tracks stay independent, and "DGX Spark Notes" for platform-specific caveats.

## Key Commands

```bash
# Full benchmark (one split at a time; default: chat, Qwen3-0.6B)
scripts/run_all.sh

# Agent split (multi-turn, ~4K input tokens, prefill-heavy)
scripts/run_all.sh --split agent

# Resume an interrupted run (skip frameworks with results <24h old, scoped to the split)
scripts/run_all.sh --skip-existing

# Specific model
scripts/run_all.sh --model qwen3-30b-a3b

# Specific frameworks
scripts/run_all.sh llamacpp omlx
scripts/run_all.sh --split agent --model qwen3-30b-a3b llamacpp

# Unattended weekly run — runs BOTH splits (chat then agent) by default,
# wraps update → run (×2) → sync under caffeinate + logging
scripts/weekly_bench.sh
scripts/weekly_bench.sh --split chat                     # constrain to one split
scripts/weekly_bench.sh --skip-update --skip-existing    # resume-only mode

# Install / update everything
scripts/install_all.sh
scripts/update_all.sh

# Download model files for a specific profile
scripts/download_model.sh --model qwen3-30b-a3b

# Manual single-framework test
scripts/serve_llamacpp.sh
scripts/stop_llamacpp.sh

# DGX Spark track — auto-detected via uname on Linux, or force explicitly:
scripts/run_all.sh --platform dgxspark
scripts/install_all.sh --platform dgxspark
```

## Architecture

**Platform dispatch:** `run_all.sh`, `install_all.sh`, `update_all.sh`, and `env_check.sh` are thin (~20-line) dispatchers with no business logic — each picks a platform (`--platform apple|dgxspark`, or `$APPLEBENCH_PLATFORM`, or `uname`-based auto-detect: Linux → dgxspark, else apple) and `exec`s the matching `<name>_apple.sh` / `<name>_dgxspark.sh`. Those two variants share no function bodies or control flow — each is a complete, independent script, so a change or a platform-only feature (e.g. Apple's `metalstat` memory sidecar) on one side literally cannot affect the other. `weekly_bench.sh` is the one exception: it stays a single shared file since its own logic (update → run chat → run agent → sync) never varies by platform — it just forwards `--platform` down to the dispatchers.

**Config chain:** `config.sh` sources a model profile from `models/<name>.sh`, which sets repo URLs and filenames. All other scripts source `config.sh` to get derived paths (`$GGUF_MODEL`, `$MLX_MODEL`, `$HF_MODEL`, `$RESULTS_DIR`). The active model is controlled by `APPLEBENCH_MODEL` env var or `--model` CLI flag (default: `qwen3-0.6b`). `config.sh` has no knowledge of the DGX Spark platform at all — the `_dgxspark`/`dgxspark/*` scripts additionally source `config_dgxspark.sh` *after* `config.sh`, which overrides `RESULTS_DIR` and adds `VLLM_PORT`/`DGX_CUDA_ARCH`.

**Model tiers:** the **primary** benchmark target is **Qwen3-0.6B** (`qwen3-0.6b`) — every weekly run targets it and the headline results are Qwen3-0.6B. **Also benchmarked** periodically: **Qwen3.5-0.8B** (`qwen3.5-0.8b`) and **Gemma-4-E4B-it** (`gemma-4-e4b-it`) — both downloaded in all three formats. **Additional profiles** (`qwen3-8b`, `qwen3-30b-a3b`) exist for heavier spot checks but are downloaded on demand and not part of the routine weekly.

**Per-framework scripts** follow a strict pattern — each framework has exactly 4 scripts:
- `install_<fw>.sh` — first-time setup (clone/brew/venv)
- `serve_<fw>.sh` — start server in background, save PID, poll `/v1/models` for readiness
- `stop_<fw>.sh` — kill by PID with SIGTERM→wait→SIGKILL fallback
- `update_<fw>.sh` — pull latest + rebuild/reinstall

**Benchmark pipeline** (`run_all_apple.sh` / `run_all_dgxspark.sh`): one split per invocation. For each framework → serve → `benchmark.py` → stop → cleanup → cooldown. Results go to `results/<MODEL_NAME>/<split>/<framework>_<timestamp>.json` (apple) or `results/<MODEL_NAME>/dgxspark/<split>/<framework>_<timestamp>.json` (dgxspark). Then `collect_results.py` picks the latest per framework (by mtime, scoped to the split's subdir) into `<split>/comparison.json`, and `generate_report.py` renders `<split>/REPORT.md`. `sync_github.sh` commits and pushes the whole `results/` tree regardless of platform. `--skip-existing` makes the pipeline resumable per-split: frameworks with result files newer than 24h in the active split's subdir are skipped, and old results are preserved rather than deleted at startup. `collect_results.py` infers `model_name` from the results-dir path (one level up from a `chat`/`agent` leaf) unless `run_all_dgxspark.sh` overrides it explicitly with `--model-name` — needed since its results dir has an extra `dgxspark` segment the inference logic doesn't know about; `run_all_apple.sh` never passes the flag, so its behavior is untouched. `generate_report.py` needs no platform awareness — it only reads fields out of `comparison.json`.

**Results layout** (per model):
```
results/<MODEL_NAME>/
├── chat/{<fw>_<ts>.json, comparison.json, REPORT.md}       # apple
├── agent/{<fw>_<ts>.json, comparison.json, REPORT.md}       # apple
├── dgxspark/
│   ├── chat/{<fw>_<ts>.json, comparison.json, REPORT.md}
│   ├── agent/{<fw>_<ts>.json, comparison.json, REPORT.md}
│   └── weekly_<DATE>.log
├── weekly_<DATE>.log
└── weekly_<DATE>.journal.md
```
`comparison.json` and `REPORT.md` are per-split — there is no model-level or cross-platform aggregate. Weekly logs/journals stay at the model level for apple (a single weekly run covers both splits) and under `dgxspark/` for that platform, so the two never collide if both machines push into the same tree on the same date.

**Weekly workflow:** `scripts/weekly_bench.sh` is the unattended wrapper — it runs `update_all.sh → run_all.sh --split chat → run_all.sh --split agent → sync_github.sh` under `caffeinate -i -m` (prevents Mac sleep; no-ops if `caffeinate` is absent, e.g. on the DGX Spark box) and tees all output to a dated log. Both splits run by default; pass `--split chat` or `--split agent` to constrain to one. `--platform apple|dgxspark` forwards to the dispatchers (auto-detects via `uname` if omitted). It continues past per-framework failures so a single broken cell doesn't block the rest, and chat failures don't stop agent from running. Intelligent recovery (diagnose failures per `(framework, split)` cell, apply scoped fixes, verify against the matching split, retry with `--skip-existing`) lives in the `.claude/skills/weekly-bench/` skill, invoked as `/weekly-bench` — **currently apple-only**; it isn't yet platform-aware (a known follow-up, not implemented). The skill commits auto-fixes to a `weekly/<date>` branch (never main) and produces a structured journal with separate per-split status tables.

**Benchmark defaults** (in `config.sh`, shared by both platforms): `CONCURRENCY_LEVELS="1 8 16"`, `BENCHMARK_REQUESTS=100` per level, `WARMUP_REQUESTS=3`, `COOLDOWN_SECONDS=60` between frameworks. Override via `benchmark.py` flags (`--concurrency`, `--requests`, `--warmup`) when running a single framework manually.

**Cache layout** (all gitignored):
- `.frameworks/` — cloned source trees (llama.cpp, mistral.rs, etc.). DGX Spark's shared-name frameworks use a `_dgxspark` suffix (`llama.cpp_dgxspark`, `vllm_dgxspark`, `sglang_dgxspark`) so they never collide with the apple-side dirs of the same framework.
- `.venvs/` — per-framework Python venvs plus the shared `bench/` venv used by `benchmark.py`, `collect_results.py`, `generate_report.py` (pure Python HTTP clients — no platform-specific code, so this venv and those 3 scripts are identical on both tracks). `run_all_apple.sh`/`run_all_dgxspark.sh` both auto-create `bench/` via `install_bench.sh` on first run. DGX Spark's venvs are also `_dgxspark`-suffixed (`vllm_dgxspark`, `sglang_dgxspark`).
- `.models/` — downloaded model files (GGUF, MLX, Safetensors); shared across frameworks *and* platforms (DGX Spark just never touches the MLX ones — see `download_model.sh --formats`).
- Exception: **vllm-metal** uses `~/.venv-vllm-metal` (global), not `.venvs/`.

**Prompt splits:** Two datasets live in `prompts/`, selected via `--split` (default `chat`):
- `chat_benchmark_prompts.json` — 100 single-turn prompts from OpenOrca + CNN/DailyMail (generated by `prepare_dataset.py`)
- `agent_benchmark_prompts.json` — 100 multi-turn agentic prompts composed from BFCL V3 multi-turn (35), Hermes Agent Reasoning Traces (35), and ClawsBench (30) via `compose_agent_prompts.py`. Tool calls and tool responses are baked into the conversation history, so no agent runtime is needed — the model just generates the next assistant turn. Avg ~4K input tokens, ~12 messages per prompt.

**Model formats:** Three formats are downloaded per model profile (`download_model.sh --formats gguf,mlx,hf`, default all three). GGUF (llama.cpp, mistral.rs, ollama), MLX (mlx_lm, omlx — apple-only), Safetensors/HF (vllm-metal, and on DGX Spark: vllm, sglang). All use BF16 for fair comparison. `install_all_dgxspark.sh` passes `--formats gguf,hf` since none of its 3 frameworks use MLX.

**Ports:** 8001-8010 (gap at 8007, retired with inferrs), one per apple framework, defined in `config.sh`. DGX Spark reuses `LLAMACPP_PORT`/`SGLANG_PORT` from `config.sh` (different physical machine, no real collision) and adds `VLLM_PORT=8011` in `config_dgxspark.sh`.

## Adding a New Framework

For the apple track (add the same steps under the dgxspark equivalents below if the framework belongs on both):

1. Create `scripts/install_<fw>.sh`, `serve_<fw>.sh`, `stop_<fw>.sh`, `update_<fw>.sh`
2. Add port in `config.sh`
3. Add entry to `FRAMEWORKS` array in `run_all_apple.sh` and its `cleanup()` function
4. Add check in `env_check_apple.sh`
5. Add to `install_all_apple.sh` and `update_all_apple.sh` loops

No changes needed to `benchmark.py`, `collect_results.py`, or `generate_report.py` — they are framework-agnostic.

## Adding a New Model

Create `models/<name>.sh` with: `MODEL_NAME`, `GGUF_REPO`, `GGUF_FILE`, `MLX_REPO`, `MLX_DIR_NAME`, `HF_REPO`, `HF_DIR_NAME`. Then `scripts/download_model.sh --model <name>`.

## Adding a New Platform

Follow the `dgxspark` track as the template — nothing in `config.sh`, the `_apple` scripts, or `scripts/dgxspark/` gets touched:

1. For each of `run_all`, `install_all`, `update_all`, `env_check`, add a `<script>_<platform>.sh` (a full, independent script — no shared function bodies with the other platform's variant)
2. Add a `scripts/config_<platform>.sh`, sourced only by that platform's scripts *after* `config.sh` — put platform-only ports/paths/dirs here (e.g. `RESULTS_DIR` override, new ports)
3. Add `scripts/<platform>/` for any framework whose install/serve/stop/update differs from its apple counterpart (same 4-script-per-framework convention)
4. Extend the 4 dispatchers' platform-detection branch (`--platform` flag / `uname` fallback) to recognize the new name
5. `weekly_bench.sh` needs no change beyond passing `--platform` through — it has no platform-specific control flow

The `.claude/skills/weekly-bench/` intelligent-recovery skill and the `metalstat`-style memory sidecar are both apple-only today; making either platform-aware is a separate follow-up, not a required step here.

## Benchmark Safeguards

- **Silent failure detection:** requests returning 0-1 tokens raise `RuntimeError` (counted as failures)
- **Sanity checks:** warns if avg tokens/request < 10% of max_tokens, or throughput/ITL are inconsistent
- **Adaptive skip:** if a concurrency level exceeds `--max-wall-time` (default 2400s), remaining levels are auto-skipped
- **Stale result cleanup:** `run_all_apple.sh`/`run_all_dgxspark.sh` delete old result files in the active split's results directory before starting

## Known Framework Quirks

- **ollama:** Needs launchctl service stopped before custom-port serve. Model imported via Modelfile pointing to shared GGUF.
- **mistral.rs:** Crashes at concurrency 16. Requires `cargo` for build.
- **vllm-metal:** Uses global venv at `~/.venv-vllm-metal` (not in project `.venvs/`). Update script backs up before reinstalling.
- **omlx:** Multi-model server; uses symlink in `.models/omlx/` pointing to the shared MLX model directory.

## DGX Spark Notes

All 3 frameworks (llama.cpp, vllm, sglang) have been validated end-to-end on real GB10 hardware: installed, served, and benchmarked with real results (`results/<MODEL>/dgxspark/chat/`).

- **llama.cpp**: mature, well-documented path — `-DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=121` (GB10 is compute capability sm_121) plus a CUDA 13.x toolkit. Worked as originally written, no fixes needed. See [Arm Learning Paths](https://learn.arm.com/learning-paths/laptops-and-desktops/dgx_spark_llamacpp/2_gb10_llamacpp_gpu/) and [ggml-org/llama.cpp#20405](https://github.com/ggml-org/llama.cpp/discussions/20405).
- **vllm**: builds from source against a torch nightly **pinned to a specific date** (`VLLM_TORCH_NIGHTLY_DATE`, default `20260626`), not "whatever's newest" — vllm's `main` calls torch C++ APIs (e.g. `at::cpu::get_cpu_capabilities`) that get renamed/removed in newer nightlies faster than vllm adapts; verified directly that this exact API existed in the `20260626` nightly but was gone by `20260703`. torchvision/torchaudio are pinned to the *same* nightly date too (mismatched native-extension ABI otherwise fails with `operator torchvision::nms does not exist`). All three pins are enforced via `uv pip install --overrides <file>` for the whole install, because vllm's own `requirements/cuda.txt` pins stable `torch==2.11.0` as a regular runtime dependency (not just a build-time one) and would otherwise silently swap our nightly back out — `--no-deps` on the final editable install closes the same door for that last step. Bump `VLLM_TORCH_NIGHTLY_DATE` (and the matching torchvision/torchaudio versions in the script) once a newer pairing is verified.
- **sglang**: builds from source cleanly against the same nightly-PyTorch approach, no fixes needed beyond that. DGX Spark support is tracked as an open, actively-changing upstream effort: [sgl-project/sglang#11658](https://github.com/sgl-project/sglang/issues/11658) — re-check it before assuming today's script still reflects the easiest path.
- **`install_bench.sh`** (shared by both platforms) used to hard-fail on Linux: it unconditionally installed `metalstat`, whose `pyobjc-framework-metal` dependency requires macOS's `sw_vers` to build. Fixed to only install `metalstat` when `uname -s = Darwin`; `matplotlib`/`adjustText` are now installed explicitly rather than relying on metalstat pulling matplotlib in transitively.
- **No memory-utilization sidecar** (Apple's `metalstat` has no DGX Spark equivalent yet — an `nvidia-smi`-based one would be a natural addition to `run_all_dgxspark.sh` only). Its absence causes no crash: the sidecar code doesn't exist in `run_all_dgxspark.sh` at all, so there's no guard to get wrong.
- **`.claude/skills/weekly-bench/` is apple-only** — it hasn't been made platform-aware.
