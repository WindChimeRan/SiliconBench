# Superseded — oMLX SSD arm run with --hot-cache-max-size 8GB

These arms were run 2026-09-01 with an 8 GB in-memory hot cache on top of
oMLX's SSD prefix cache. oMLX's documented default for --hot-cache-max-size
is 0 (disabled), and serve_omlx.sh warns that omlx persists CLI args to
~/.omlx/settings.json, so the flag must be passed explicitly either way.

The 8 GB hot cache made TTFT FALL as concurrency rose (27B: 7.39s at c=1 ->
4.24s at c=2), which is cache warming across sequential levels rather than
scheduling behaviour. Replaced by arms run with --hot-cache-max-size 0.

Kept for provenance. Do not plot.
