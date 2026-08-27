# Unpublished arms — Qwen3.8-27B, m5pro, agent split

`collect_results.py` globs `*.json` in the parent directory only (non-recursive)
and keeps the newest file per `framework` key. The run here carries
`framework: "omlx"`, the same key as the published `omlx_20260825_002656.json`
(SSD offload). Moving it up one level would replace that arm in `comparison.json`
and `REPORT.md`, so it stays here until the harness can express engine *modes*
as distinct keys.

## `omlx_bounded_20260824_202439.*`

oMLX in bounded in-memory mode (no SSD KV offload). Was
`unpublished_ramcache_omlx_20260824_202439.*`; stem renamed across the whole
matched set, contents byte-identical.

| c | ok | TTFT avg | output tok/s | ITL avg |
|---|---|---|---|---|
| 1 | 100/100 | 10.62 s | 3.98 | 100.9 ms |
| 2 | 99/100 | 16.92 s | 4.56 | 200.9 ms |
| 4 | 63/100 | 26.22 s | 5.21 | 281.6 ms |

At c=4 its admission guard rejected 37 of 100 requests. That point is reported
as a failure count rather than a latency: the 63 survivors average 81.0 output
tokens against ~70 for every other arm, so they are not a comparable population.

Plotted (c=1 and c=2 only) as the solid "oMLX" series in the vLLM blog post
*Announcing vllm-metal: Concurrent Serving on Apple Silicon*.
