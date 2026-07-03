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


def _peak_memory_per_level(result_path, concurrency_results):
    """Peak ``mem_used_gb`` per concurrency from the result's metalstat sidecar.

    Phases are laid out contiguously from the start of the trace in concurrency
    order, each taking its recorded ``wall_time_s`` (same approximation as
    draw/parse.py). Returns {concurrency: peak_gb}; empty if no sidecar so the
    field is simply omitted (loaders treat it as missing).
    """
    sidecar = result_path.with_name(result_path.stem + "_metalstat.jsonl")
    if not sidecar.exists():
        return {}
    rows = []
    for line in sidecar.read_text().splitlines():
        if line.strip():
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    if not rows:
        return {}
    walls = {c["concurrency"]: (c.get("wall_time_s") or 0.0)
             for c in concurrency_results if c.get("concurrency") is not None}
    offset, bounds = 0.0, {}
    for c in sorted(walls):
        bounds[c] = (offset, offset + walls[c])
        offset += walls[c]
    elapsed = [r.get("elapsed_s") for r in rows]
    mem = [r.get("mem_used_gb") for r in rows]
    out = {}
    for c, (start, end) in bounds.items():
        if end - start < 1.0:
            continue
        vals = [mem[i] for i, e in enumerate(elapsed)
                if e is not None and start <= e < end and mem[i] is not None]
        if vals:
            out[c] = max(vals)
    return out


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", default=None, help="Results directory")
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
    if results_dir.name in ("chat", "agent"):
        model_name = results_dir.parent.name
        split = results_dir.name
    else:
        model_name = results_dir.name
        split = None

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
