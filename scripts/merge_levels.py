#!/usr/bin/env python3
"""Merge per-level benchmark JSONs into one result file.

With a restart per concurrency level, each level is a separate benchmark.py
invocation and a separate file. Everything downstream (collect_results,
comparison.json, the figure scripts) expects one file per framework with a
concurrency_results list, so stitch them back into that shape.

The merged run_config says levels_share_server=false and lists every level, so
the result records that these levels were measured independently.
"""
import argparse
import json
import sys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", required=True)
    ap.add_argument("parts", nargs="+")
    args = ap.parse_args()

    # Every part must load. Skipping an unreadable one would emit an arm that
    # is silently missing a concurrency level — the same class of bug this
    # change exists to prevent.
    parts = [json.load(open(path)) for path in args.parts]

    parts.sort(key=lambda d: d["concurrency_results"][0]["concurrency"])
    merged = dict(parts[0])
    merged["concurrency_results"] = [
        cr for p in parts for cr in p["concurrency_results"]
    ]
    merged["total_duration_s"] = sum(p.get("total_duration_s") or 0 for p in parts)

    rc = dict(merged.get("run_config") or {})
    rc["concurrency_levels"] = [
        cr["concurrency"] for cr in merged["concurrency_results"]
    ]
    # the whole point: each level got its own server
    rc["levels_share_server"] = False
    merged["run_config"] = rc

    with open(args.output, "w") as fh:
        json.dump(merged, fh, indent=2)
    print(f"  merged {len(parts)} levels -> {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
