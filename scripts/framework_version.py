#!/usr/bin/env python3
"""Report the installed version of one inference framework.

Both tracks stamp their results with this so a number can be traced back to the
build that produced it. Until now neither did: perf results carried only
{framework, model, endpoint, timestamp, machine, total_duration_s} and
correctness scores.json carried no identity at all beyond its directory name, so
an F1 shift between runs could not be bisected to a framework version.

Every probe is best-effort and never raises: a benchmark must not fail because a
version lookup did. An unknown version is reported as null, which is honest —
strictly better than omitting the field and leaving the reader to assume the
runs matched.

Usage:
    python3 scripts/framework_version.py llamacpp        # -> one JSON object
    python3 scripts/framework_version.py --all           # -> {fw: {...}, ...}
"""
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parents[1]
FRAMEWORKS_DIR = PROJECT_DIR / ".frameworks"
VENVS_DIR = PROJECT_DIR / ".venvs"


def _run(cmd, cwd=None):
    try:
        r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=15)
        return r.stdout.strip() if r.returncode == 0 else None
    except Exception:
        return None


def _git(repo_dir):
    """Commit SHA + author date for a cloned source tree."""
    d = Path(repo_dir)
    if not (d / ".git").is_dir():
        return {}
    sha = _run(["git", "log", "-1", "--format=%H"], cwd=d)
    date = _run(["git", "log", "-1", "--format=%cI"], cwd=d)
    out = {}
    if sha:
        out["commit"] = sha
        out["version"] = sha[:9]
    if date:
        out["commit_date"] = date
    return out


def _dist(python_bin, *dists):
    """importlib.metadata versions read from inside a specific venv."""
    py = Path(python_bin)
    if not py.exists():
        return {}
    code = (
        "import json, importlib.metadata as m\n"
        f"names = {list(dists)!r}\n"
        "out = {}\n"
        "for n in names:\n"
        "    try: out[n] = m.version(n)\n"
        "    except Exception: out[n] = None\n"
        "print(json.dumps(out))\n"
    )
    raw = _run([str(py), "-c", code])
    if not raw:
        return {}
    try:
        return {k: v for k, v in json.loads(raw).items() if v}
    except Exception:
        return {}


def probe(fw):
    """Return {version, ...detail} for one framework. Never raises."""
    try:
        if fw == "llamacpp":
            d = _git(FRAMEWORKS_DIR / "llama.cpp")
            # llama-server prints its own build number, which is what the
            # server's system_fingerprint reports back in responses.
            out = _run([str(FRAMEWORKS_DIR / "llama.cpp/build/bin/llama-server"), "--version"])
            if out:
                for line in out.splitlines():
                    if "build:" in line:
                        d["build"] = line.split("build:", 1)[1].strip()
                        break
            return d

        if fw == "mlx_lm":
            return _dist(VENVS_DIR / "mlx_lm/bin/python", "mlx-lm", "mlx")

        if fw == "omlx":
            d = _git(FRAMEWORKS_DIR / "omlx")
            d.update(_dist(VENVS_DIR / "omlx/bin/python", "omlx", "mlx"))
            return d

        if fw == "vllm_metal":
            # Global venv by design — not under .venvs/ (see CLAUDE.md).
            return _dist(Path.home() / ".venv-vllm-metal/bin/python", "vllm_metal", "vllm")

        if fw == "vllm_mlx":
            d = _dist(VENVS_DIR / "vllm_mlx/bin/python", "vllm-mlx", "mlx")
            # The PyPI version string has been static across rebuilds, so the
            # git SHA uv records is the only thing that actually moves.
            raw = _run([str(VENVS_DIR / "vllm_mlx/bin/python"), "-c",
                        "import importlib.metadata as m;"
                        "print(m.distribution('vllm-mlx').read_text('direct_url.json') or '')"])
            if raw:
                try:
                    commit = json.loads(raw).get("vcs_info", {}).get("commit_id")
                    if commit:
                        d["commit"] = commit
                except Exception:
                    pass
            return d

        if fw == "mistralrs":
            return _git(FRAMEWORKS_DIR / "mistral.rs")

        if fw == "ollama":
            v = _run(["ollama", "--version"])
            return {"version": v.split()[-1]} if v else {}

        if fw == "hf_transformers":
            return _dist(VENVS_DIR / "hf_transformers/bin/python", "transformers", "torch")

        if fw == "sglang":
            d = _git(FRAMEWORKS_DIR / "sglang")
            d.update(_dist(VENVS_DIR / "sglang/bin/python", "sglang", "torch"))
            return d
    except Exception:
        pass
    return {}


ALL = ["llamacpp", "mlx_lm", "omlx", "vllm_metal", "vllm_mlx",
       "mistralrs", "ollama", "hf_transformers", "sglang"]


def describe(fw):
    """Probe result plus a guaranteed 'version' key (null when unknown)."""
    d = probe(fw) or {}
    if "version" not in d:
        for k in ("vllm_metal", "mlx-lm", "omlx", "vllm-mlx", "transformers", "sglang"):
            if d.get(k):
                d["version"] = d[k]
                break
        else:
            d["version"] = None
    return d


def machine():
    """Host identity, matching the block benchmark.py already records."""
    import platform
    d = {"host": platform.node(),
         "os": f"{platform.system()} {platform.release()}"}
    chip = _run(["sysctl", "-n", "machdep.cpu.brand_string"])
    if chip:
        d["chip"] = chip
    return d


def provenance(fw, model=None, shots=None):
    """Full 'which build produced this' block for embedding in a result file."""
    import datetime
    d = {"framework": fw,
         "framework_version": describe(fw),
         "date": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
         "machine": machine()}
    if model is not None:
        d["model"] = model
    if shots is not None:
        d["shots"] = int(shots)
    return d


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("framework", nargs="?", help="framework name")
    ap.add_argument("--all", action="store_true", help="probe every framework")
    ap.add_argument("--provenance", action="store_true",
                    help="emit a full provenance block (version + machine + date) "
                         "on one line, for embedding in a result file")
    ap.add_argument("--model", default=None, help="model name, for --provenance")
    ap.add_argument("--shots", default=None, help="shot count, for --provenance")
    a = ap.parse_args()
    if a.all:
        print(json.dumps({fw: describe(fw) for fw in ALL}, indent=2))
        return 0
    if not a.framework:
        ap.error("give a framework name or --all")
    if a.provenance:
        # One line, no indent: this gets passed as a single shell argument.
        print(json.dumps(provenance(a.framework, a.model, a.shots)))
        return 0
    print(json.dumps(describe(a.framework), indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
