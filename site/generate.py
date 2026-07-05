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
  - No speed-only leaderboard: the three lenses sit side by side and
    rows are in a FIXED alphabetical order, never sorted by a metric.
  - Failure vocabulary carried over: partial cells show n/100, crashed
    cells show a cross, budget-skips say "skip".
  - Run dates, per-framework timestamps, and harness commit are meta
    info in a muted footer block, not headline info.
  - Machines are a first-class dimension: adding a machine is one entry
    in MACHINES (M5 Pro ships as a planned/empty tab today).
  - Light and dark themes; system default plus a manual toggle.

Usage:
    python3 site/generate.py [--repo PATH] [--out PATH] [--commit SHA]
"""
import argparse
import html
import json
from datetime import date
from pathlib import Path

MODELS = ["Qwen3-0.6B", "Qwen3.5-0.8B", "Gemma-4-E4B-it"]
LEVELS = [1, 8, 16]
SPLITS = ["chat", "agent"]
RETIRED = {"inferrs"}
PARTIAL_THRESHOLD = 90   # >=90/100 counts as a clean run (paper convention)
CRASH_THRESHOLD = 5      # <5/100 counts as crashed

MACHINES = [
    {
        "id": "m2max",
        "label": "Apple M2 Max",
        "spec": "64 GB unified memory · macOS 26 · Metal",
        "subdir": None,          # legacy apple tree: results/<MODEL>/<split>/
        "status": "live",
        "note": "Primary audited track (nine stacks).",
        "has_memory": True,
    },
    {
        "id": "m5pro",
        "label": "Apple M5 Pro",
        "spec": "Apple Silicon · macOS · Metal",
        "subdir": "m5pro",       # future: results/<MODEL>/m5pro/<split>/
        "status": "planned",
        "note": "No runs yet. Results will appear here automatically "
                "once the first run lands in the repository.",
        "has_memory": True,
    },
    {
        "id": "dgxspark",
        "label": "NVIDIA DGX Spark",
        "spec": "GB10 Grace-Blackwell · 128 GB unified · Linux / CUDA",
        "subdir": "dgxspark",
        "status": "live",
        "note": "CUDA-native reference track: the three engines with "
                "upstream siblings in the Apple roster. Memory is not "
                "measured on this track yet.",
        "has_memory": False,
    },
]

NAMES = {
    "llamacpp": "llama.cpp", "mlx_lm": "mlx_lm", "mistralrs": "mistral.rs",
    "vllm_metal": "vllm-metal", "vllm_mlx": "vllm-mlx", "omlx": "omlx",
    "ollama": "ollama", "sglang": "sglang", "hf_transformers": "hf_transformers",
    "vllm": "vllm", "vllm-nvidia": "vllm-nvidia (ref)",
}


def esc(s):
    return html.escape(str(s), quote=True)


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


def spark_svg(cells, key, log=False, title=""):
    """Tiny inline 3-point trend line for one stack row.

    Per-row normalized (shape, not magnitude; magnitudes are the numeric
    columns). Clean levels are filled dots, partial levels hollow, crashed
    levels a small cross at the baseline; missing levels are skipped.
    """
    W, H, PAD = 46, 18, 3.5
    xs = {c: PAD + i * (W - 2 * PAD) / 2 for i, c in enumerate(LEVELS)}
    pts, marks = [], []
    vals = []
    for c in LEVELS:
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


def split_table(rows, has_memory):
    head = ('<tr><th data-sort="text" data-dir="asc" '
            'title="click to sort">Stack</th>'
            + "".join(f'<th class="num" data-sort="num" data-dir="desc" '
                      f'title="click to sort">tok/s c={c}</th>'
                      for c in LEVELS)
            + '<th class="spark">trend</th>'
            + '<th class="num" data-sort="num" data-dir="asc" '
              'title="click to sort">TTFT p50 c=16</th>'
            + '<th class="spark">TTFT trend</th>'
            + '<th class="num" data-sort="num" data-dir="asc" '
              'title="click to sort">peak mem GB</th></tr>')
    body = []
    for fw in sorted(rows, key=lambda f: NAMES.get(f, f).lower()):
        row = rows[fw]
        tds = "".join(tput_cell(row["cells"].get(c)) for c in LEVELS)
        name = NAMES.get(fw, fw)
        body.append(
            f'<tr><td class="stack" data-v="{esc(name.lower())}">{esc(name)}</td>{tds}'
            + spark_svg(row["cells"], "output_throughput_tps",
                        title=f"{name}: output tok/s across c=1/8/16")
            + ms_cell(row["cells"].get(16))
            + spark_svg(row["cells"], "ttft_p50_ms", log=True,
                        title=f"{name}: TTFT p50 across c=1/8/16 (log)")
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
                    ts.append(row["timestamp"][:10])
    return (min(ts), max(ts)) if ts else (None, None)


def meta_block(machine, machine_data, commit):
    lo, hi = run_dates(machine_data)
    when = "no runs yet" if lo is None else (lo if lo == hi else f"{lo} to {hi}")
    per_fw = []
    seen = {}
    for splits in machine_data.values():
        for split, rows in splits.items():
            for fw, row in rows.items():
                if row.get("timestamp"):
                    seen.setdefault(NAMES.get(fw, fw), set()).add(
                        row["timestamp"][:10])
    for fw in sorted(seen, key=str.lower):
        per_fw.append(f"<tr><td>{esc(fw)}</td>"
                      f"<td>{esc(', '.join(sorted(seen[fw])))}</td></tr>")
    details = ""
    if per_fw:
        details = ("<details><summary>per-framework run dates</summary>"
                   f"<table class='meta-table'>{''.join(per_fw)}</table>"
                   "</details>")
    return f"""
    <div class="meta">
      <p><span class="k">machine</span> {esc(machine['spec'])}
         <span class="k">run dates</span> {esc(when)}
         <span class="k">harness</span>
         <a href="https://github.com/WindChimeRan/applebench/commit/{esc(commit)}">
         <code>{esc(commit[:9])}</code></a></p>
      <p class="note">Framework versions and update commits for each run are
      recorded in the
      <a href="https://github.com/WindChimeRan/applebench/tree/main/results">
      weekly journals</a>. {esc(machine['note'])}</p>
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
body { margin:0; background:var(--bg); color:var(--ink);
  font:16px/1.55 -apple-system, "Segoe UI", Roboto, Helvetica, Arial,
  sans-serif; }
.wrap { max-width: 1000px; margin: 0 auto; padding: 2.2rem 1.2rem 4rem; }
header h1 { margin:0 0 .2rem; font-size:1.9rem; letter-spacing:-.01em; }
header p.tag { margin:.1rem 0 .6rem; color:var(--muted); }
header .links a { margin-right:1rem; color:var(--accent);
  text-decoration:none; }
header .links a:hover { text-decoration:underline; }
.scopenote { font-size:.85rem; color:var(--muted); margin:.3rem 0 0; }
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
.splits { display:grid; grid-template-columns:1fr; gap:1rem 2rem; }
.splits > div { min-width:0; }
.meta { border-top:1px solid var(--hair); margin-top:1.4rem;
  padding-top:.7rem; font-size:.84rem; color:var(--muted); }
.meta .k { text-transform:uppercase; font-size:.72rem; letter-spacing:.06em;
  margin:0 .35rem 0 1.1rem; }
.meta .k:first-child { margin-left:0; }
.meta a { color:var(--accent); text-decoration:none; }
.meta code { font-size:.9em; }
.meta-table td { padding:.15rem .6rem .15rem 0; border:none;
  font-size:.82rem; }
details summary { cursor:pointer; }
.placeholder { border:1px dashed var(--hair); border-radius:.6rem;
  padding:1.2rem; color:var(--muted); margin-top:1rem; }
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
pick('machine', 'm2max');
pick('model', 'Qwen3-0.6B');
"""


def machine_section(repo, machine, commit):
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
            cols = []
            for split in SPLITS:
                if split not in splits:
                    continue
                title = ("chat split" if split == "chat"
                         else "agent split (~4K-token prompts)")
                cols.append(f'<div><h3>{esc(title)}</h3><div class="tablewrap">'
                            + split_table(splits[split], machine["has_memory"])
                            + "</div></div>")
            inner.append(f'<div class="splits">{"".join(cols)}</div>')
            fid = load_fidelity(repo, model)
            if machine["id"] != "dgxspark" and fid:
                inner.append(
                    "<h3>fidelity (weighted F1, GMRID, vs. one NVIDIA A100 "
                    'reference)</h3><div class="tablewrap" style="max-width:26rem">'
                    + fidelity_table(fid) + "</div>")
        blocks.append(f'<div data-model="{esc(model)}" hidden>'
                      + "".join(inner) + "</div>")

    meta = meta_block(machine, data, commit)
    return (f'<section data-machine="{esc(machine["id"])}" hidden>'
            + "".join(blocks) + meta + "</section>")


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
<title>SiliconBench — LLM serving on unified-memory desktops</title>
<meta name="description" content="Speed, memory, and fidelity for LLM serving
engines on unified-memory desktops (Apple Silicon, DGX Spark). Updated
automatically from weekly benchmark runs.">
<style>{CSS}</style>
</head>
<body>
<div class="wrap">
<header>
  <h1>SiliconBench</h1>
  <p class="tag">Speed, memory, and fidelity for LLM serving on
  unified-memory desktops. All requests hit an OpenAI-compatible endpoint at
  concurrency 1 / 8 / 16, BF16 weights, n=100 per level.</p>
  <p class="links">
    <a href="https://github.com/WindChimeRan/applebench">benchmark repo</a>
    <a href="https://github.com/WindChimeRan/applebench/tree/main/results">weekly journals</a>
    <a href="#" title="paper link coming">paper (soon)</a>
  </p>
  <p class="scopenote">Single-node serving only. Stacks are listed
  alphabetically by default; click a column header to sort (failed runs
  always sink to the bottom); no default ranking is implied; the paper's central
  finding is that speed-only orderings mislead. ✕ = crashed
  (&lt;5/100 requests), <i>n</i>/100 = partial run, – = not measured. Trend sparklines show
  each stack's own shape across c=1/8/16 (per-row normalized; TTFT on a
  log scale); magnitudes are in the numbers.</p>
</header>

<div class="controls">
  <span class="group"><span class="lbl">machine</span>{machine_btns}</span>
  <span class="group"><span class="lbl">model</span>{model_btns}</span>
  <button id="themetoggle" title="toggle light/dark">◐ theme</button>
</div>

{sections}

<footer>
  Generated automatically from
  <a href="https://github.com/WindChimeRan/applebench">committed benchmark
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


if __name__ == "__main__":
    main()
