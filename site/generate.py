#!/usr/bin/env python3
"""
SiliconBench results page generator.

Reads committed benchmark data (results/**/comparison.json and
correctness/results/*_comparison.json) and emits ONE self-contained
static HTML page (inline CSS + ~40 lines of vanilla JS, no
dependencies). Deployed as a single passthrough file into the personal
website (ranranhaoranzhang.com/siliconbench/), auto-updated by GitHub
Actions whenever results change on main (.github/workflows/site.yml).

Design rules (mirrors the paper):
  - No speed-only leaderboard: the three lenses sit side by side. Tables
    default-sort by tok/s at SORT_LEVEL (c=16) for ergonomics, but the
    scopenote says plainly that this is a convenience and not a ranking,
    and memory and fidelity remain visible alongside it.
  - Failure vocabulary carried over: partial cells show n/100, crashed
    cells show a cross, budget-skips say "skip".
  - Run dates, per-framework timestamps, and harness commit are meta
    info in a muted footer block, not headline info.
  - Machines are a first-class dimension: adding a machine is one entry
    in MACHINES (M5 Pro is the paper's main audit platform).
  - Light and dark themes; system default plus a manual toggle.

Usage:
    python3 site/generate.py [--repo PATH] [--out PATH] [--commit SHA]
"""
import argparse
import html
import json
from datetime import date
from pathlib import Path

MODELS = ["Qwen3-0.6B", "Qwen3.5-0.8B", "Gemma-4-E4B-it", "Qwen3.8-27B",
          "Qwen3.6-35B-A3B-4bit"]
LEVELS = [1, 8, 16]

# Per-model overrides. A model benchmarked at different concurrency levels, or
# against a subset of the roster, declares it here rather than forcing the whole
# page onto one shape.
#   MODEL_LEVELS  - concurrency levels actually run for that model
#   MODEL_ROSTER  - engines to render. An EMPTY list means "show only engines
#                   with a result file", i.e. no "did not start" rows at all,
#                   for a model that was deliberately run against a subset.
#   MODEL_NOTE    - caveat shown above that model's tables.
MODEL_LEVELS = {"Qwen3.8-27B": [1, 2, 4], "Qwen3.6-35B-A3B-4bit": [1, 2, 4]}
MODEL_ROSTER = {"Qwen3.8-27B": [], "Qwen3.6-35B-A3B-4bit": []}
MODEL_NOTE = {
    "Qwen3.8-27B":
        "8-bit weights (GGUF Q8_0 for llama.cpp; the mlx-community affine-8bit "
        "conversion for vllm-metal and omlx) \u2014 BF16 does not fit this box. "
        "Run against three engines only, at concurrency 1/2/4; the other stacks "
        "were not attempted, so their absence is not a failure.",
    "Qwen3.6-35B-A3B-4bit":
        "4-bit MoE (35B total, ~3B active per token), agent split only, at "
        "concurrency 1/2/4. Four engines were attempted plus one oMLX variant; "
        "the rest of the roster was not run, so its absence is not a failure. "
        "mlx_lm is marked partial at every level \u2014 around six in ten "
        "requests came back OK with zero generated tokens, so its rates "
        "describe only the ~38 that completed and are not a like-for-like "
        "comparison with the engines that finished 99\u2013100. "
        "\u201comlx (RAM cache)\u201d is the same build with its prefix cache held "
        "in memory and nothing written to disk, which is what every other engine "
        "here does; the plain oMLX row keeps its own default, a prefix cache "
        "backed by SSD. "
        "No peak-memory column: the memory sidecar traced only the last "
        "concurrency level of each run, so this model's memory needs a "
        "re-measure.",
}
SPLITS = ["chat", "agent"]
SORT_LEVEL = LEVELS[-1]   # tables default-sort by tok/s at this concurrency
RETIRED = {"inferrs"}
PARTIAL_THRESHOLD = 90   # >=90/100 counts as a clean run (paper convention)
CRASH_THRESHOLD = 5      # <5/100 counts as crashed

# Full expected engine roster per hardware track. A roster framework with no
# result file for a split is rendered as an explicit "did not start" row, so a
# missing engine reads as a tested failure rather than as "never benchmarked".
APPLE_ROSTER = ["llamacpp", "mlx_lm", "mistralrs", "vllm_metal", "vllm_mlx",
                "omlx", "ollama", "sglang", "hf_transformers"]
DGX_ROSTER = ["llamacpp", "sglang", "vllm"]

MACHINES = [
    {
        "id": "m5pro",
        "label": "Apple M5 Pro",
        "spec": "18 cores · 64 GB unified memory · macOS 26.6 · Metal",
        "subdir": "m5pro",       # results/<MODEL>/m5pro/<split>/
        "status": "live",
        "note": "Main platform in the paper's audit. Run details and model coverage "
                "appear in the tables above.",
        "has_memory": True,
        "roster": APPLE_ROSTER,
    },
    {
        "id": "m2max",
        "label": "Apple M2 Max",
        "spec": "64 GB unified memory · macOS 26 · Metal",
        "subdir": None,          # legacy apple tree: results/<MODEL>/<split>/
        "status": "live",
        "note": "Earlier benchmark runs and maintenance case studies. The paper's "
                "main audit uses the M5 Pro.",
        "has_memory": True,
        "roster": APPLE_ROSTER,
    },
    {
        "id": "dgxspark",
        "label": "NVIDIA DGX Spark",
        "spec": "GB10 Grace-Blackwell · 128 GB unified · Linux / CUDA",
        "subdir": "dgxspark",
        "status": "live",
        "note": "Complementary serving-performance reference for three engine "
                "families shared with the Apple Silicon audit. Memory measurements "
                "are not included in this track.",
        "has_memory": False,
        "roster": DGX_ROSTER,
    },
]

NAMES = {
    "llamacpp": "llama.cpp", "mlx_lm": "mlx_lm", "mistralrs": "mistral.rs",
    "vllm_metal": "vllm-metal", "vllm_mlx": "vllm-mlx", "omlx": "omlx",
    "ollama": "ollama", "sglang": "sglang", "hf_transformers": "hf_transformers",
    "vllm": "vllm", "vllm-nvidia": "vllm-nvidia (ref)",
    # oMLX's prefix cache has two tiers and the harness can run either. Both
    # labels name the tier, so no row reads as plain "omlx" and leaves a reader
    # to assume the default.
    "omlx_ram": "omlx (RAM cache)",
    "omlx_bounded": "omlx (no cache)",
}


def esc(s):
    return html.escape(str(s), quote=True)


def flow(text):
    """Collapse source-wrapping whitespace so emitted prose is one line
    per paragraph (readable page source and diffs; rendering unchanged)."""
    return " ".join(text.split())


def norm_date(d):
    """Collapse the early-July-2026 run cluster to one representative date.

    The chat runs landed across 07-03..07-05 depending on model/engine; a
    two-day spread is the same batch, so every date in that window displays as
    2026-07-05. Dates outside it (e.g. the May agent runs) are left exactly as
    measured — this only touches presentation, never the raw result files."""
    return "2026-07-05" if "2026-07-01" <= d <= "2026-07-05" else d


def load_split(repo, model, machine, split):
    base = repo / "results" / model
    if machine["subdir"]:
        base = base / machine["subdir"]
    p = base / split / "comparison.json"
    if not p.exists():
        return None
    with p.open() as f:
        comp = json.load(f)
    rows = {}
    for fw, data in comp.get("results", {}).items():
        if fw in RETIRED:
            continue
        cells, ts = {}, data.get("timestamp")
        for lv in data.get("concurrency_results", []):
            cells[int(lv["concurrency"])] = lv
        rows[fw] = {"cells": cells, "timestamp": ts}
    return rows


def load_versions(repo, machine):
    """Structured per-framework versions, emitted by update_all (TODO E7).

    Expected schema: {"frameworks": {fw: {"version": str, "commit": str,
    "updated_at": "YYYY-MM-DD"}}} (a bare fw->info dict also accepted).
    Returns {} until the harness starts emitting it; every consumer of
    this data renders nothing in that case, so the page degrades cleanly.
    """
    base = repo / "results"
    if machine["subdir"]:
        base = base / machine["subdir"]
    p = base / "framework_versions.json"
    if not p.exists():
        return {}
    try:
        with p.open() as f:
            d = json.load(f)
    except Exception:
        return {}
    d = d.get("frameworks", d)
    return d if isinstance(d, dict) else {}


def version_tip(fw, versions):
    v = versions.get(fw) or {}
    bits = []
    if v.get("version"):
        bits.append(f"v{v['version']}")
    if v.get("commit"):
        bits.append(str(v["commit"])[:9])
    if v.get("updated_at"):
        bits.append(f"updated {v['updated_at']}")
    return " · ".join(bits)


def load_fidelity(repo, model):
    p = repo / "correctness" / "results" / f"{model}_comparison.json"
    if not p.exists():
        return None
    with p.open() as f:
        d = json.load(f)
    return {fw: v for fw, v in d.get("frameworks", {}).items()
            if fw not in RETIRED}


def classify(lv):
    if lv is None:
        return "missing"
    err = lv.get("error") or ""
    if "skip" in str(err).lower():
        return "skip"
    ok = lv.get("successful", 0)
    if ok < CRASH_THRESHOLD:
        return "crash"
    if ok < PARTIAL_THRESHOLD:
        return "partial"
    return "clean"


TIER = {"clean": 3, "partial": 2, "skip": 1, "crash": 0, "missing": 0}


def tput_cell(lv):
    cls = classify(lv)
    t = TIER[cls]
    if cls == "missing":
        return f'<td class="num muted" data-t="{t}" data-v="0">–</td>'
    if cls == "crash":
        return (f'<td class="num crash" data-t="{t}" data-v="0" '
                f'title="fewer than 5/100 requests succeeded">✕</td>')
    if cls == "skip":
        return (f'<td class="num muted" data-t="{t}" data-v="0" '
                f'title="budget-skipped: previous level too slow">skip</td>')
    v = lv.get("output_throughput_tps")
    num = v if isinstance(v, (int, float)) else 0
    txt = f"{v:.1f}" if isinstance(v, (int, float)) else "–"
    if cls == "partial":
        ok = lv.get("successful", 0)
        return (f'<td class="num partial" data-t="{t}" data-v="{num}" '
                f'title="partial run: throughput over '
                f'completed requests only">{txt}<sup>{ok}/100</sup></td>')
    return f'<td class="num" data-t="{t}" data-v="{num}">{txt}</td>'


def ms_cell(lv):
    cls = classify(lv)
    v = lv.get("ttft_p50_ms") if lv else None
    if cls not in ("clean", "partial") or not isinstance(v, (int, float)):
        return '<td class="num muted" data-t="0" data-v="0">–</td>'
    txt = f"{v/1000:.2f} s" if v >= 1000 else f"{v:.0f} ms"
    return f'<td class="num" data-t="{TIER[cls]}" data-v="{v}">{txt}</td>'


def mem_cell(row, has_memory):
    if not has_memory:
        return '<td class="num muted" data-t="0" data-v="0">–</td>'
    vals = [lv.get("mem_used_gb") for lv in row["cells"].values()
            if isinstance(lv.get("mem_used_gb"), (int, float))]
    if not vals:
        return '<td class="num muted" data-t="0" data-v="0">–</td>'
    return f'<td class="num" data-t="3" data-v="{max(vals)}">{max(vals):.1f}</td>'



import math


def spark_svg(cells, key, log=False, title="", levels=None):
    """Tiny inline 3-point trend line for one stack row.

    Per-row normalized (shape, not magnitude; magnitudes are the numeric
    columns). Clean levels are filled dots, partial levels hollow, crashed
    levels a small cross at the baseline; missing levels are skipped.
    """
    levels = levels or LEVELS
    W, H, PAD = 46, 18, 3.5
    n = max(len(levels) - 1, 1)
    xs = {c: PAD + i * (W - 2 * PAD) / n for i, c in enumerate(levels)}
    pts, marks = [], []
    vals = []
    for c in levels:
        lv = cells.get(c)
        cls = classify(lv)
        v = (lv or {}).get(key)
        if cls in ("clean", "partial") and isinstance(v, (int, float)) and v > 0:
            vals.append(math.log10(v) if log else v)
            marks.append((c, cls, v))
        elif cls == "crash":
            marks.append((c, "crash", None))
    if not vals:
        return '<td class="spark muted">–</td>'
    lo, hi = min(vals), max(vals)
    rng = (hi - lo) or 1.0
    def y(v):
        vv = math.log10(v) if log else v
        return H - PAD - (vv - lo) / rng * (H - 2 * PAD)
    line, dots, i = [], [], 0
    for c, cls, v in marks:
        x = xs[c]
        if cls == "crash":
            dots.append(f'<path d="M{x-2.4} {H-PAD-2.4} l4.8 4.8 M{x-2.4} '
                        f'{H-PAD+2.4} l4.8 -4.8" class="sx"/>')
            continue
        yy = y(v)
        line.append(f"{x:.1f},{yy:.1f}")
        fill = "currentColor" if cls == "clean" else "var(--bg)"
        dots.append(f'<circle cx="{x:.1f}" cy="{yy:.1f}" r="2.1" '
                    f'fill="{fill}" stroke="currentColor" stroke-width="1"/>')
    poly = (f'<polyline points="{" ".join(line)}" fill="none" '
            f'stroke="currentColor" stroke-width="1.3"/>'
            if len(line) >= 2 else "")
    return (f'<td class="spark"><svg width="{W}" height="{H}" '
            f'viewBox="0 0 {W} {H}" role="img"><title>{esc(title)}</title>'
            f'{poly}{"".join(dots)}</svg></td>')


def nostart_row(fw, levels=None):
    """A roster framework with no result file for this split: the server never
    launched. Rendered as an explicit, de-emphasized failure row (grey ✕) so it
    reads as 'tested, did not start' rather than a red 'ran and crashed' ✕ or a
    silently omitted engine. data-t=0 sinks it to the bottom when sorting."""
    name = NAMES.get(fw, fw)
    x = ('<td class="num nostart" data-t="0" data-v="0" '
         'title="server did not start this run — no result file">✕</td>')
    dash = '<td class="num muted" data-t="0" data-v="0">–</td>'
    spark = '<td class="spark muted">–</td>'
    return (f'<tr class="nostart-row"><td class="stack" '
            f'data-v="{esc(name.lower())}"><span class="prov" '
            f'title="did not start this run — no result file (server failed '
            f'to launch)">{esc(name)}</span></td>'
            + x * len(levels or LEVELS) + spark + dash + spark + dash + "</tr>")


def split_table(rows, has_memory, versions=None, roster=None, levels=None):
    levels = levels or LEVELS
    sort_level = levels[-1]
    head = ('<tr><th data-sort="text" data-dir="asc" '
            'title="click to sort">Stack</th>'
            + "".join(
                f'<th class="num" data-sort="num" data-dir="desc"'
                # Mark the column rows are already sorted by, using the same
                # markup the JS writes, so its cleanup finds and removes it.
                + (' data-active="desc"' if c == sort_level else '')
                + f' title="click to sort">tok/s c={c}'
                + ('<span class="arr">\u25bc</span>' if c == sort_level else '')
                + '</th>'
                for c in levels)
            + '<th class="spark">trend</th>'
            + '<th class="num" data-sort="num" data-dir="asc" '
              f'title="click to sort">TTFT p50 c={sort_level}</th>'
            + '<th class="spark">TTFT trend</th>'
            + '<th class="num" data-sort="num" data-dir="asc" '
              'title="click to sort">peak mem GB</th></tr>')
    body = []
    order = list(roster) if roster else []
    for fw in rows:                       # keep any present engine not in roster
        if fw not in order:
            order.append(fw)
    def sort_key(f):
        """Throughput at SORT_LEVEL, descending, failures last.

        Mirrors the JS comparator exactly (tier first, then value) so the
        server-rendered order matches what clicking that header produces —
        otherwise the first click would appear to do nothing. Sorting here
        rather than in JS avoids a flash of unsorted rows and keeps the order
        meaningful with JS disabled. Name breaks ties so the order is stable.
        """
        lv = rows.get(f, {}).get("cells", {}).get(sort_level)
        tier = TIER[classify(lv)]
        v = lv.get("output_throughput_tps") if lv else None
        return (-tier, -(v if isinstance(v, (int, float)) else 0.0),
                NAMES.get(f, f).lower())

    for fw in sorted(order, key=sort_key):
        if fw in RETIRED:
            continue
        if fw not in rows:                # roster engine with no result file
            body.append(nostart_row(fw, levels))
            continue
        row = rows[fw]
        tds = "".join(tput_cell(row["cells"].get(c)) for c in levels)
        name = NAMES.get(fw, fw)
        tip = []
        if row.get("timestamp"):
            tip.append(f"benchmarked {norm_date(row['timestamp'][:10])}")
        vt = version_tip(fw, versions or {})
        if vt:
            tip.append(vt)
        tipattr = f' title="{esc(" · ".join(tip))}"' if tip else ""
        body.append(
            f'<tr><td class="stack" data-v="{esc(name.lower())}">'
            f'<span class="prov"{tipattr}>{esc(name)}</span></td>{tds}'
            + spark_svg(row["cells"], "output_throughput_tps", levels=levels,
                        title=f"{name}: output tok/s across "
                              f"c={'/'.join(str(c) for c in levels)}")
            + ms_cell(row["cells"].get(sort_level))
            + spark_svg(row["cells"], "ttft_p50_ms", log=True, levels=levels,
                        title=f"{name}: TTFT p50 across "
                              f"c={'/'.join(str(c) for c in levels)} (log)")
            + mem_cell(row, has_memory) + "</tr>")
    return f'<table>{head}{"".join(body)}</table>'


def fidelity_table(fid):
    head = ('<tr><th data-sort="text" data-dir="asc" '
            'title="click to sort">Stack</th>'
            '<th class="num" data-sort="num" data-dir="desc" '
            'title="click to sort">0-shot F1</th>'
            '<th class="num" data-sort="num" data-dir="desc" '
            'title="click to sort">5-shot F1</th></tr>')
    ordered = sorted(fid, key=lambda f: (f != "vllm-nvidia",
                                         NAMES.get(f, f).lower()))
    body = []
    for fw in ordered:
        cells = []
        for shot in ("0shot", "5shot"):
            v = (fid[fw].get(shot) or {}).get("f1_weighted")
            cells.append(f'<td class="num" data-t="3" data-v="{v}">{v:.4f}</td>'
                         if isinstance(v, (int, float))
                         else '<td class="num muted" data-t="0" data-v="0">–</td>')
        cls = ' class="refrow"' if fw == "vllm-nvidia" else ""
        nm = NAMES.get(fw, fw)
        body.append(f'<tr{cls}><td class="stack" data-v="{esc(nm.lower())}">'
                    f'{esc(nm)}</td>{"".join(cells)}</tr>')
    return f'<table>{head}{"".join(body)}</table>'


def run_dates(machine_data):
    ts = []
    for splits in machine_data.values():
        for rows in splits.values():
            for row in rows.values():
                if row.get("timestamp"):
                    ts.append(norm_date(row["timestamp"][:10]))
    return (min(ts), max(ts)) if ts else (None, None)


def meta_block(machine, machine_data, commit, versions):
    lo, hi = run_dates(machine_data)
    when = "no runs yet" if lo is None else (lo if lo == hi else f"{lo} to {hi}")
    seen = {}   # fw -> split -> set(dates)
    for splits in machine_data.values():
        for split, rows in splits.items():
            for fw, row in rows.items():
                if row.get("timestamp"):
                    seen.setdefault(fw, {}).setdefault(split, set()).add(
                        norm_date(row["timestamp"][:10]))
    has_ver = bool(versions) and any(fw in versions for fw in seen)
    per_fw = []
    for fw in sorted(seen, key=lambda f: NAMES.get(f, f).lower()):
        bench = " · ".join(
            f"{split} {'/'.join(sorted(seen[fw][split]))}"
            for split in SPLITS if split in seen[fw])
        vcols = ""
        if has_ver:
            v = versions.get(fw) or {}
            ver = v.get("version") or "–"
            if v.get("commit"):
                ver += f" ({str(v['commit'])[:9]})"
            vcols = (f"<td>{esc(ver)}</td>"
                     f"<td>{esc(v.get('updated_at') or '–')}</td>")
        per_fw.append(f"<tr><td>{esc(NAMES.get(fw, fw))}</td>{vcols}"
                      f"<td>{esc(bench)}</td></tr>")
    details = ""
    if per_fw:
        vhead = "<th>version</th><th>updated</th>" if has_ver else ""
        details = ("<details><summary>per-framework provenance</summary>"
                   f"<table class='meta-table'><tr><th>framework</th>{vhead}"
                   f"<th>benchmarked</th></tr>{''.join(per_fw)}</table>"
                   "</details>")
    vnote = ("" if has_ver else flow("""Framework versions and update commits
      for each run are recorded in the
      <a href="https://github.com/WindChimeRan/SiliconBench/tree/main/results">
      maintenance journals</a>; structured version fields appear here once the
      harness emits them.""") + " ")
    return f"""
    <div class="meta">
      <p><span class="k">machine</span> {esc(machine['spec'])}
         <span class="k">run dates</span> {esc(when)}
         <span class="k">harness</span>
         <a href="https://github.com/WindChimeRan/SiliconBench/commit/{esc(commit)}">
         <code>{esc(commit[:9])}</code></a></p>
      <p class="note">{vnote}{esc(machine['note'])}</p>
      {details}
    </div>"""


CSS = """
:root { --bg:#ffffff; --ink:#1a1a1a; --muted:#6b6b6b; --hair:#d9d9d6;
        --band:#f2f2ef; --accent:#0f62fe; --crash:#a2191f; --partial:#8a6d00; }
:root[data-theme="dark"] { --bg:#161616; --ink:#e8e8e6; --muted:#9b9b98;
        --hair:#3a3a38; --band:#222220; --accent:#78a9ff; --crash:#ff8389;
        --partial:#d2b100; }
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) { --bg:#161616; --ink:#e8e8e6;
        --muted:#9b9b98; --hair:#3a3a38; --band:#222220; --accent:#78a9ff;
        --crash:#ff8389; --partial:#d2b100; }
}
* { box-sizing: border-box; }
html { font-size:17px; }
body { margin:0; background:var(--bg); color:var(--ink);
  font:1rem/1.55 -apple-system, "Segoe UI", Roboto, Helvetica, Arial,
  sans-serif; }
.wrap { max-width: 910px; margin: 0 auto; padding: 2.2rem 1.2rem 4rem; }
header h1 { margin:0 0 .2rem; font-size:1.9rem; letter-spacing:-.01em;
  line-height:1.25; }
header p.byline { margin:.3rem 0 .5rem; font-size:.92rem;
  color:var(--muted); }
header p.tag { margin:.1rem 0 .6rem; color:var(--muted); }
header .links a { margin-right:1rem; color:var(--accent);
  text-decoration:none; }
header .links a:hover { text-decoration:underline; }
.scopenote { font-size:.85rem; color:var(--muted); margin:.3rem 0 0; }
.about p { margin:.55rem 0; font-size:1.1rem; }
.snapshot { font-size:.88rem; color:var(--muted); margin:.2rem 0 .8rem; }
.controls { display:flex; flex-wrap:wrap; gap:.6rem 1.6rem;
  margin:1.6rem 0 1rem; align-items:center; }
.controls .group { display:flex; gap:.35rem; align-items:center;
  flex-wrap:wrap; }
.controls .lbl { font-size:.8rem; color:var(--muted);
  text-transform:uppercase; letter-spacing:.06em; margin-right:.2rem; }
.controls button { border:1px solid var(--hair); background:transparent;
  color:var(--ink); padding:.32rem .7rem; border-radius:.45rem;
  font-size:.9rem; cursor:pointer; }
.controls button[aria-pressed="true"] { border-color:var(--accent);
  color:var(--accent); font-weight:600; }
#themetoggle { margin-left:auto; }
h2 { font-size:1.15rem; margin:1.6rem 0 .5rem; }
h3 { font-size:.98rem; margin:1.2rem 0 .4rem; }
table { border-collapse:collapse; width:100%; font-size:.92rem;
  font-variant-numeric: tabular-nums; }
th { text-align:left; font-weight:600; border-bottom:1.5px solid var(--ink);
  padding:.35rem .55rem .3rem; white-space:nowrap; }
td { border-bottom:1px solid var(--hair); padding:.34rem .55rem; }
th.num, td.num { text-align:right; }
td.stack { font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size:.88rem; }
td.crash { color:var(--crash); }
td.nostart { color:var(--muted); }
tr.nostart-row td.stack { color:var(--muted); font-style:italic; }
td.partial sup { color:var(--partial); font-size:.68em; margin-left:.15rem; }
td.muted, .muted { color:var(--muted); }
th.spark, td.spark { text-align:center; width:54px; }
th[data-sort] { cursor:pointer; user-select:none; }
th[data-sort]:hover { color:var(--accent); }
th .arr { font-size:.68em; margin-left:.22rem; opacity:.75; }
td.spark svg { display:block; margin:0 auto; color:var(--accent); }
td.spark .sx { stroke:var(--crash); stroke-width:1.1; fill:none; }
tr.refrow td { background:var(--band); }
.tablewrap { overflow-x:auto; }
.tablewrap.fid { width:max-content; max-width:100%;
  margin-left:auto; margin-right:auto; }
.splits { display:grid; grid-template-columns:1fr; gap:1rem 2rem; }
.splits > div { min-width:0; }
.meta { border-top:1px solid var(--hair); margin-top:1.4rem;
  padding-top:.7rem; font-size:.84rem; color:var(--muted); }
.meta .k { text-transform:uppercase; font-size:.72rem; letter-spacing:.06em;
  margin:0 .35rem 0 1.1rem; }
.meta .k:first-child { margin-left:0; }
.meta a { color:var(--accent); text-decoration:none; }
.meta code { font-size:.9em; }
.meta-table td, .meta-table th { padding:.15rem .8rem .15rem 0;
  border:none; font-size:.82rem; text-align:left; }
.meta-table th { font-weight:600; border-bottom:1px solid var(--hair); }
.prov { border-bottom:1px dotted var(--muted); cursor:help; }
details summary { cursor:pointer; }
.placeholder { border:1px dashed var(--hair); border-radius:.6rem;
  padding:1.2rem; color:var(--muted); margin-top:1rem; }
.pagenav { margin:1.1rem 0 0; font-size:.9rem; }
.pagenav a { color:var(--accent); text-decoration:none; margin-right:1.2rem; }
.pagenav a:hover { text-decoration:underline; }
.sechead { font-size:1.35rem; margin:2.2rem 0 .6rem;
  border-top:1px solid var(--hair); padding-top:1.3rem; }
.sechint { font-size:.78rem; font-weight:400; color:var(--muted);
  margin-left:.6rem; }
section { scroll-margin-top:.8rem; }
.linksbox { margin-top:1.8rem; }
.linksbox a { color:var(--accent); }
pre.citation { white-space:pre-wrap; overflow-wrap:anywhere;
  padding:1rem; background:var(--band); border:1px solid var(--hair);
  border-radius:.4rem; font-size:.78rem; line-height:1.5; }
footer { margin-top:3rem; font-size:.8rem; color:var(--muted); }
footer a { color:var(--accent); text-decoration:none; }
"""

JS = """
function pick(group, id) {
  document.querySelectorAll('[data-' + group + ']').forEach(function (el) {
    el.hidden = el.getAttribute('data-' + group) !== id;
  });
  document.querySelectorAll('button[data-pick-' + group + ']')
    .forEach(function (b) {
      b.setAttribute('aria-pressed',
        String(b.getAttribute('data-pick-' + group) === id));
    });
}
document.querySelectorAll('button[data-pick-machine]').forEach(function (b) {
  b.addEventListener('click', function () {
    pick('machine', b.getAttribute('data-pick-machine')); });
});
document.querySelectorAll('button[data-pick-model]').forEach(function (b) {
  b.addEventListener('click', function () {
    pick('model', b.getAttribute('data-pick-model')); });
});
document.getElementById('themetoggle').addEventListener('click', function () {
  var r = document.documentElement;
  var dark = (r.getAttribute('data-theme') || (window.matchMedia &&
    window.matchMedia('(prefers-color-scheme: dark)').matches ?
    'dark' : 'light')) === 'dark';
  r.setAttribute('data-theme', dark ? 'light' : 'dark');
});
document.querySelectorAll('table').forEach(function (tb) {
  var ths = tb.querySelectorAll('th[data-sort]');
  ths.forEach(function (th) {
    th.addEventListener('click', function () {
      var idx = Array.prototype.indexOf.call(th.parentNode.children, th);
      var cur = th.getAttribute('data-active');
      var dir = cur === 'asc' ? 'desc'
              : cur === 'desc' ? 'asc' : th.getAttribute('data-dir');
      ths.forEach(function (o) {
        o.removeAttribute('data-active');
        var a = o.querySelector('.arr'); if (a) a.remove();
      });
      th.setAttribute('data-active', dir);
      var arr = document.createElement('span');
      arr.className = 'arr';
      arr.textContent = dir === 'asc' ? '\u25b2' : '\u25bc';
      th.appendChild(arr);
      var rows = Array.prototype.slice.call(tb.querySelectorAll('tr'))
        .filter(function (r) { return r.querySelector('td'); });
      var isText = th.getAttribute('data-sort') === 'text';
      rows.sort(function (a, b) {
        var ca = a.children[idx], cb = b.children[idx];
        var ta = +(ca.getAttribute('data-t') || 0);
        var tb2 = +(cb.getAttribute('data-t') || 0);
        if (ta !== tb2) return tb2 - ta;
        if (isText) {
          var sa = ca.getAttribute('data-v') || ca.textContent;
          var sb = cb.getAttribute('data-v') || cb.textContent;
          return dir === 'asc' ? sa.localeCompare(sb) : sb.localeCompare(sa);
        }
        var va = +(ca.getAttribute('data-v') || 0);
        var vb = +(cb.getAttribute('data-v') || 0);
        return dir === 'asc' ? va - vb : vb - va;
      });
      rows.forEach(function (r) { r.parentNode.appendChild(r); });
    });
  });
});
pick('machine', 'm5pro');
pick('model', 'Qwen3-0.6B');
"""


def snapshot_line(splits, roster=None):
    """One computed sentence about the latest data; regenerated on every
    build, so it cannot go stale the way hand-written findings would. Counts
    against the full roster so engines that never start are surfaced, not
    dropped from the denominator."""
    worst, dates = {}, []
    for rows in splits.values():
        for fw, row in rows.items():
            if row.get("timestamp"):
                dates.append(norm_date(row["timestamp"][:10]))
            for lv in row["cells"].values():
                t = TIER[classify(lv)]
                worst[fw] = min(worst.get(fw, 3), t)
    if not worst:
        return ""
    all_fw = (set(worst) | set(roster or [])) - RETIRED
    n = len(all_fw)
    nostart = sum(1 for fw in all_fw if fw not in worst)
    clean = sum(1 for t in worst.values() if t == 3)
    crash = sum(1 for t in worst.values() if t == 0)
    degrade = len(worst) - clean - crash
    lo, hi = (min(dates), max(dates)) if dates else ("?", "?")
    when = (f"Run {hi}" if lo == hi
            else f"Runs {lo} to {hi} (splits from different runs)")
    bits = [f"{clean} of {n} stacks complete every request at every level"]
    if degrade:
        bits.append(f"{degrade} degrade to partial or skip")
    if crash:
        bits.append(f"{crash} crash at least once")
    if nostart:
        bits.append(f"{nostart} never start")
    return (f'<p class="snapshot">{esc(when)}: '
            + "; ".join(bits) + ".</p>")


def machine_section(repo, machine, commit):
    versions = load_versions(repo, machine)
    data = {}   # model -> split -> rows
    for model in MODELS:
        splits = {}
        for split in SPLITS:
            rows = load_split(repo, model, machine, split)
            if rows:
                splits[split] = rows
        if splits:
            data[model] = splits

    blocks = []
    for model in MODELS:
        inner = []
        if machine["status"] == "planned" or model not in data:
            inner.append(f'<div class="placeholder">No runs for '
                         f'{esc(model)} on {esc(machine["label"])} yet.'
                         f' {esc(machine["note"])}</div>')
        else:
            splits = data[model]
            mlevels = MODEL_LEVELS.get(model, LEVELS)
            # An explicit [] roster means "only engines with a result file":
            # no "did not start" rows for a model run against a subset.
            mroster = (MODEL_ROSTER[model] if model in MODEL_ROSTER
                       else machine.get("roster"))
            if MODEL_NOTE.get(model):
                inner.append(f'<div class="placeholder">'
                             f'{esc(MODEL_NOTE[model])}</div>')
            cols = []
            for split in SPLITS:
                if split not in splits:
                    continue
                title = ("chat split" if split == "chat"
                         else "agent split (~4K-token prompts)")
                cols.append(f'<div><h3>{esc(title)}</h3><div class="tablewrap">'
                            + split_table(splits[split], machine["has_memory"],
                                          versions, mroster, mlevels)
                            + "</div></div>")
            inner.append(snapshot_line(splits, mroster))
            inner.append(f'<div class="splits">{"".join(cols)}</div>')
            fid = load_fidelity(repo, model)
            if machine["id"] != "dgxspark" and fid:
                inner.append(
                    "<h3>fidelity (weighted F1, GMRID, vs. one NVIDIA A100 "
                    'reference)</h3><div class="tablewrap fid">'
                    + fidelity_table(fid) + "</div>")
        blocks.append(f'<div data-model="{esc(model)}" hidden>'
                      + "".join(inner) + "</div>")

    meta = meta_block(machine, data, commit, versions)
    return (f'<section data-machine="{esc(machine["id"])}" hidden>'
            + "".join(blocks) + meta + "</section>")


PAPER_CITATION = r"""@misc{zhang2026siliconbench,
  title  = {{SiliconBench}: Speed, Memory, and Fidelity for {LLM} Serving on Unified-Memory Desktops},
  author = {Ranran Haoran Zhang and Aysa Xuemo Fan and David Munh{\'a} Correia and Alex Cheema and Rui Zhang},
  year   = {2026},
  note   = {Submitted to arXiv}
}"""


def paper_section():
    """Publication status, code link, and citation after the live tables."""
    links = flow(
        "The paper has been submitted to arXiv. A link will be added when "
        "available. Benchmark code, per-run results, and maintenance journals "
        "are available in the "
        "<a href='https://github.com/WindChimeRan/SiliconBench'>benchmark "
        "repository</a>.")
    return f"""
<section id="links" class="linksbox">
<h2 class="sechead">Paper &amp; code</h2>
<p>{links}</p>
<h3 id="citation">Citation</h3>
<pre class="citation"><code>{esc(PAPER_CITATION)}</code></pre>
</section>
"""


def build(repo, commit):
    machine_btns = "".join(
        f'<button data-pick-machine="{esc(m["id"])}" aria-pressed="false">'
        f'{esc(m["label"])}{" (planned)" if m["status"] == "planned" else ""}'
        f'</button>' for m in MACHINES)
    model_btns = "".join(
        f'<button data-pick-model="{esc(m)}" aria-pressed="false">{esc(m)}'
        f'</button>' for m in MODELS)
    sections = "".join(machine_section(repo, m, commit) for m in MACHINES)
    today = date.today().isoformat()
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>SiliconBench: Speed, Memory, and Fidelity for LLM Serving on Unified-Memory Desktops</title>
<meta name="description" content="Speed, memory, and fidelity for LLM serving
engines on unified-memory desktops, with live Apple Silicon results and a
complementary DGX Spark performance track.">
<style>{CSS}</style>
</head>
<body>
<div class="wrap">
<header>
  <h1>SiliconBench: Speed, Memory, and Fidelity for LLM Serving on Unified-Memory Desktops</h1>
  <p class="byline">Ranran Haoran Zhang, Aysa Xuemo Fan, David Munhá Correia, Alex Cheema, Rui Zhang</p>
  <p class="tag">{flow("""SiliconBench evaluates local LLM serving through
  speed, memory, and fidelity. Explore how engines handle concurrent
  workloads while preserving memory headroom and model quality.""")}</p>
  <p class="links">
    <a href="https://github.com/WindChimeRan/SiliconBench">GitHub</a>
    <a href="https://github.com/WindChimeRan/SiliconBench/tree/main/results">Maintenance journals</a>
    <a href="#citation">BibTeX</a>
    <span>Paper (arXiv pending)</span>
  </p>
  <div class="about">
  <p>{flow("""The main audit covers nine Apple Silicon serving engines
  on chat and agent workloads. A complementary NVIDIA DGX Spark track
  measures serving performance for three shared engine families.""")}</p>
  <p>{flow("""Speed captures throughput and latency under load; memory
  tracks the system footprint during serving; and fidelity uses a
  classification task to check for quality regressions against an NVIDIA
  reference.""")}</p>
  </div>
  <nav class="pagenav">
    <a href="#live">Live results</a>
    <a href="#links">Paper &amp; code</a>
  </nav>
</header>

<section id="live">
<h2 class="sechead">Live results
  <span class="sechint">rebuilt automatically from every merged
  benchmark run</span></h2>

<div class="controls">
  <span class="group"><span class="lbl">machine</span>{machine_btns}</span>
  <span class="group"><span class="lbl">model</span>{model_btns}</span>
  <button id="themetoggle" title="toggle light/dark">◐ theme</button>
</div>

<p class="scopenote">{flow("""Single-node serving. Select a machine and
model, then click a column header to sort. Read throughput alongside memory
and fidelity. ✕ = crashed (&lt;5/100 requests), <i>n</i>/100 = partial run,
– = not measured. Trend lines show each engine's change across the tested
concurrency levels; each row is scaled independently, with first-token
latency on a log scale. Hover an engine name for run details.""")}</p>

{sections}
</section>

{paper_section()}

<footer>
  Generated automatically from
  <a href="https://github.com/WindChimeRan/SiliconBench">committed benchmark
  results</a> on {today}. Page updates on every merge to main that changes
  results.
</footer>
</div>
<script>{JS}</script>
</body>
</html>
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=str(Path(__file__).resolve().parents[1]))
    ap.add_argument("--out", default=None)
    ap.add_argument("--commit", default="main")
    args = ap.parse_args()
    repo = Path(args.repo)
    out = Path(args.out) if args.out else repo / "site" / "out" / "index.html"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(build(repo, args.commit))
    print(f"wrote {out}")
    static = Path(__file__).resolve().parent / "static"
    if static.is_dir():
        import shutil
        for f in static.iterdir():
            if f.is_file() and not f.name.startswith("."):
                shutil.copy2(f, out.parent / f.name)
                print(f"copied {f.name}")


if __name__ == "__main__":
    main()
