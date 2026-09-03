#!/usr/bin/env python3
"""
Collect individual benchmark results into a single comparison JSON.
"""

import argparse
import json
import sys
from pathlib import Path

# Frameworks dropped from the active roster. Their historical result files
# stay on disk untouched for provenance, but aggregation skips them here so
# comparison.json and REPORT.md never resurface a framework that has stopped
# being run. inferrs was removed 2026-07-03 after 69 days with no upstream
# commits or releases and an unanswered maintainer ping.
RETIRED_FRAMEWORKS = {"inferrs"}


def _read_mem_trace(path):
    """Rows of a metalstat JSONL trace, skipping anything unparseable."""
    rows = []
    for line in path.read_text().splitlines():
        if line.strip():
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return rows


def _peak_memory_per_level(result_path, concurrency_results):
    """Peak ``mem_used_gb`` per concurrency from the result's metalstat sidecars.

    Preferred shape is one trace per level, ``<stem>_metalstat_c<N>.jsonl``,
    written by a run that restarts the server for every level: the trace *is*
    the level, so its peak needs no time arithmetic to attribute.

    Legacy runs shared one server across levels and wrote a single
    ``<stem>_metalstat.jsonl`` spanning the whole sweep. Those are still read,
    with the levels laid out contiguously from the start of the trace in
    concurrency order, each taking its recorded ``wall_time_s`` (same
    approximation as draw/parse.py) — but only when the trace is actually long
    enough to span the levels it is being cut into. A trace that falls short
    is not a whole-run trace, and slicing it anyway reports the level it does
    cover as whichever level happens to sit at that offset.

    Returns {concurrency: peak_gb}, empty when there is nothing trustworthy to
    report, so the field is simply omitted (loaders treat it as missing).
    """
    walls = {c["concurrency"]: (c.get("wall_time_s") or 0.0)
             for c in concurrency_results if c.get("concurrency") is not None}

    out = {}
    for c in sorted(walls):
        sidecar = result_path.with_name(f"{result_path.stem}_metalstat_c{c}.jsonl")
        if not sidecar.exists():
            continue
        vals = [r.get("mem_used_gb") for r in _read_mem_trace(sidecar)]
        vals = [v for v in vals if v is not None]
        if vals:
            out[c] = max(vals)
    if out:
        return out

    sidecar = result_path.with_name(result_path.stem + "_metalstat.jsonl")
    if not sidecar.exists():
        return {}
    rows = _read_mem_trace(sidecar)
    if not rows:
        return {}
    elapsed = [r.get("elapsed_s") for r in rows]
    mem = [r.get("mem_used_gb") for r in rows]

    # A genuine whole-sweep trace runs slightly longer than the benchmark it
    # wraps (started before the first level, killed after the last): observed
    # ratios are 1.02-1.03. One that covers a third of the run is a per-level
    # trace that was written to the shared path and truncated by its
    # successors. Report nothing rather than the wrong level.
    span = max((e for e in elapsed if e is not None), default=0.0)
    total_wall = sum(walls.values())
    if total_wall > 0 and span < 0.9 * total_wall:
        print(f"Warning: {sidecar.name} spans {span:.0f}s of a {total_wall:.0f}s "
              f"run — cannot attribute memory to levels, omitting")
        return {}

    offset, bounds = 0.0, {}
    for c in sorted(walls):
        bounds[c] = (offset, offset + walls[c])
        offset += walls[c]
    for c, (start, end) in bounds.items():
        if end - start < 1.0:
            continue
        vals = [mem[i] for i, e in enumerate(elapsed)
                if e is not None and start <= e < end and mem[i] is not None]
        if vals:
            out[c] = max(vals)
    return out



def _warn_on_methodology_mismatch(frameworks, paths):
    """Shout when arms about to share axes were not measured the same way.

    Diffs the whole run_config rather than named fields, so a knob added later
    is covered without touching this function. Warns rather than fails: a mixed
    set is sometimes deliberate, and refusing would strand results on disk.
    """
    configs = {fw: d.get("run_config") for fw, d in frameworks.items()}
    missing = sorted(fw for fw, c in configs.items() if not c)
    known = {fw: c for fw, c in configs.items() if c}

    lines = []
    for key in sorted({k for c in known.values() for k in c}):
        vals = {fw: json.dumps(c.get(key), sort_keys=True) for fw, c in known.items()}
        if len(set(vals.values())) > 1:
            lines.append(f"{key} differs:")
            lines += [f"    {fw}: {v}" for fw, v in sorted(vals.items())]
    if missing:
        lines.append("no run_config (measured before provenance was added): "
                     + ", ".join(missing))

    if lines:
        print("=" * 72)
        print("WARNING: these arms were not measured identically; sharing axes "
              "may mislead.")
        for line in lines:
            print("  " + line)
        print("=" * 72)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", default=None, help="Results directory")
    parser.add_argument("--model-name", default=None,
                         help="Explicit model name, overriding directory-name inference "
                              "(needed when results-dir has an extra platform-name segment, "
                              "e.g. results/<MODEL>/dgxspark/<split>)")
    args = parser.parse_args()

    if args.results_dir:
        results_dir = Path(args.results_dir)
    else:
        results_dir = Path(__file__).parent.parent / "results"

    # Find the latest result for each framework (by file modification time)
    frameworks = {}
    latest_mtime = {}
    frameworks_path = {}
    for f in results_dir.glob("*.json"):
        if f.name == "comparison.json":
            continue
        try:
            with open(f) as fh:
                data = json.load(fh)
        except json.JSONDecodeError as e:
            print(f"Warning: skipping corrupted file {f.name}: {e}")
            continue
        # Skip sidecar artifacts (e.g., *_metalstat.meta.json) that happen to
        # land in the same directory — they don't carry benchmark results.
        if "framework" not in data or "concurrency_results" not in data:
            continue
        fw = data["framework"]
        if fw in RETIRED_FRAMEWORKS:
            continue
        mtime = f.stat().st_mtime
        if fw not in frameworks or mtime > latest_mtime[fw]:
            frameworks[fw] = data
            latest_mtime[fw] = mtime
            frameworks_path[fw] = f

    if not frameworks:
        print("No results found")
        sys.exit(1)

    _warn_on_methodology_mismatch(frameworks, frameworks_path)

    # Enrich each cell with peak memory (GB) from the metalstat sidecar, so
    # comparison.json is a self-contained, tracked source for memory-axis
    # figures — no dependency on the gitignored sidecars at figure time.
    for fw, data in frameworks.items():
        peaks = _peak_memory_per_level(frameworks_path[fw],
                                       data.get("concurrency_results", []))
        for cr in data.get("concurrency_results", []):
            c = cr.get("concurrency")
            if c in peaks:
                cr["mem_used_gb"] = round(peaks[c], 2)

    # If results_dir is a split subdir (results/<MODEL>/<split>), the model
    # name lives one level up. Otherwise the dir name is the model name.
    # --model-name overrides this inference entirely (needed when an extra
    # platform-name segment sits between model and split).
    split = results_dir.name if results_dir.name in ("chat", "agent") else None
    if args.model_name:
        model_name = args.model_name
    elif results_dir.name in ("chat", "agent"):
        model_name = results_dir.parent.name
    else:
        model_name = results_dir.name

    comparison = {
        "model_name": model_name,
        "split": split,
        "frameworks": list(frameworks.keys()),
        "results": frameworks,
    }

    output = results_dir / "comparison.json"
    with open(output, "w") as f:
        json.dump(comparison, f, indent=2)

    print(f"Comparison saved to: {output}")
    print(f"Frameworks: {', '.join(frameworks.keys())}")


if __name__ == "__main__":
    main()
