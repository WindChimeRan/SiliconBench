# Per-level probes — oMLX, 2026-09-01 evening

Hand-driven single-level runs, one file per concurrency, under the distinct
framework keys `omlx_pl` and `omlx_bounded_pl`. They were measuring how much of
oMLX's apparent scaling came from levels sharing a server and its on-disk
prefix cache rather than from the engine.

This model is where that answer came from. Against one shared server
(`../superseded_shared_server/omlx_20260901_105252.json`) oMLX reads 35.1 /
57.3 / 64.4 tok/s at c=1/2/4; measured cold, one server and one cache
directory per level, the same build reads 35.4 / 34.1 / 39.4. The c=4 pair
(64.4 vs 39.4) is the number quoted in 720b536, the commit that gave oMLX a
fresh cache directory on every server start. The per-level restart itself is
d0290bd; both landed a few hours after these probes.

Superseded by the published arms, measured 2026-09-02 with the harness doing
the restart. The subdirectory and the `_pl` keys both keep these out of
collect_results.py. Kept for provenance. Do not plot.
