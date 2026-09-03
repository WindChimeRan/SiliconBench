"""Parse metalstat.jsonl sidecars produced by the weekly benchmark pipeline.

Each line is one per-second sample with GPU/CPU/memory/power metrics. Two
filename shapes exist, because the benchmark now restarts the server for every
concurrency level and traces each level separately:

  <framework>_<YYYYMMDD>_<HHMMSS>_metalstat_c<N>.jsonl   one level, exact
  <framework>_<YYYYMMDD>_<HHMMSS>_metalstat.jsonl        whole sweep, legacy

Per-level traces are concatenated into one Trace with the level boundaries
known exactly. A legacy whole-sweep trace has no boundaries recorded, so its
phases are still approximated from the levels' wall_time_s.
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path

FILENAME_RE = re.compile(
    r"^(?P<framework>.+)_(?P<date>\d{8})_(?P<time>\d{6})_metalstat\.jsonl$"
)
PER_LEVEL_RE = re.compile(
    r"^(?P<framework>.+)_(?P<date>\d{8})_(?P<time>\d{6})"
    r"_metalstat_c(?P<conc>\d+)\.jsonl$"
)

# Colorblind-safe palette (Wong 2011, 8 colors + Tol muted grey). Stable order
# gives each framework the same color across every figure in the paper.
CVD_COLORS = [
    "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2",
    "#D55E00", "#CC79A7", "#000000", "#999999",
]


@dataclass
class Trace:
    framework: str
    timestamp: str
    path: Path
    rows: list[dict]
    wall_times: dict[int, float]  # concurrency -> wall_time_s (0 if phase skipped/crashed)
    # Row indices per concurrency, set only when the levels were traced
    # separately. When present these are exact and wall_times is not consulted.
    phase_idx: dict[int, list[int]] | None = None

    @property
    def elapsed_s(self) -> list[float]:
        return [r["elapsed_s"] for r in self.rows]

    def series(self, key: str) -> list[float | None]:
        return [r.get(key) for r in self.rows]

    def phase_slice(self, concurrency: int) -> tuple[list[float], list[int]] | None:
        """Rows belonging to the given concurrency level, by cumulative wall_times.

        Approximation: phases are laid out contiguously from the start of the
        trace in concurrency order, each taking its recorded wall_time_s.
        Warmup/gap time between phases is absorbed into the next phase head.
        With per-level traces the rows for a phase are known outright and no
        layout is assumed; the docstring above describes the legacy fallback.

        Returns (x_percent_within_phase, row_indices), or None if that phase
        has wall_time_s ~0 (skipped/crashed with no useful window).
        """
        if self.phase_idx is not None:
            idxs = self.phase_idx.get(concurrency) or []
            if not idxs:
                return None
            start = self.elapsed_s[idxs[0]]
            span = self.elapsed_s[idxs[-1]] - start
            if span < 1.0:
                return None
            x_pct = [100.0 * (self.elapsed_s[i] - start) / span for i in idxs]
            return x_pct, idxs
        order = sorted(self.wall_times)
        offset = 0.0
        bounds = {}
        for c in order:
            w = self.wall_times[c]
            bounds[c] = (offset, offset + w)
            offset += w
        if concurrency not in bounds:
            return None
        start, end = bounds[concurrency]
        if end - start < 1.0:
            return None
        idxs = [
            i for i, e in enumerate(self.elapsed_s)
            if start <= e < end
        ]
        if not idxs:
            return None
        x_pct = [
            100.0 * (self.elapsed_s[i] - start) / (end - start) for i in idxs
        ]
        return x_pct, idxs


def load_concurrency_metric(result_json: Path, key: str) -> dict[int, float]:
    """{concurrency: value} from a result JSON's concurrency_results entries."""
    if not result_json.exists():
        return {}
    data = json.loads(result_json.read_text())
    out: dict[int, float] = {}
    for r in data.get("concurrency_results", []):
        c = r.get("concurrency")
        v = r.get(key)
        if c is None or v is None:
            continue
        out[int(c)] = float(v)
    return out


def _read_rows(path: Path) -> list[dict]:
    return [
        json.loads(line)
        for line in path.read_text().splitlines()
        if line.strip()
    ]


def discover_traces(split_dir: Path) -> dict[str, Trace]:
    """One Trace per framework in `split_dir` — the latest timestamp wins."""
    # (framework, timestamp) -> {"levels": {concurrency: path}} / {"whole": path}
    candidates: dict[tuple[str, str], dict] = {}
    for path in sorted(split_dir.glob("*_metalstat*.jsonl")):
        m = PER_LEVEL_RE.match(path.name)
        if m:
            key = (m["framework"], f"{m['date']}_{m['time']}")
            candidates.setdefault(key, {}).setdefault("levels", {})[int(m["conc"])] = path
            continue
        m = FILENAME_RE.match(path.name)
        if m:
            key = (m["framework"], f"{m['date']}_{m['time']}")
            candidates.setdefault(key, {})["whole"] = path

    by_fw: dict[str, Trace] = {}
    for (fw, ts) in sorted(candidates):
        if fw in by_fw and by_fw[fw].timestamp >= ts:
            continue
        entry = candidates[(fw, ts)]
        wall_times = load_concurrency_metric(split_dir / f"{fw}_{ts}.json", "wall_time_s")

        if "levels" in entry:
            # Lay the levels end to end on one synthetic timeline, separated by
            # a nominal second, and remember which rows came from which level.
            rows: list[dict] = []
            phase_idx: dict[int, list[int]] = {}
            offset = 0.0
            for c in sorted(entry["levels"]):
                level_rows = _read_rows(entry["levels"][c])
                level_rows = [r for r in level_rows if r.get("elapsed_s") is not None]
                if not level_rows:
                    continue
                base = min(r["elapsed_s"] for r in level_rows)
                idxs = []
                for r in level_rows:
                    r = dict(r)
                    r["elapsed_s"] = offset + (r["elapsed_s"] - base)
                    idxs.append(len(rows))
                    rows.append(r)
                phase_idx[c] = idxs
                offset = rows[-1]["elapsed_s"] + 1.0
            if not rows:
                continue
            by_fw[fw] = Trace(
                framework=fw, timestamp=ts,
                path=entry["levels"][min(entry["levels"])], rows=rows,
                wall_times=wall_times, phase_idx=phase_idx,
            )
            continue

        rows = _read_rows(entry["whole"])
        if not rows:
            continue
        by_fw[fw] = Trace(
            framework=fw, timestamp=ts, path=entry["whole"], rows=rows,
            wall_times=wall_times,
        )
    return by_fw
