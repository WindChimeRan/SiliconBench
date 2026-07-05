# SiliconBench results page

One self-contained static HTML page generated from the committed benchmark
data, served at https://ranranhaoranzhang.com/siliconbench/ as a passthrough
file of the personal website (al-folio copies `siliconbench/index.html`
verbatim; nothing else on that site is touched).

## How it updates

`.github/workflows/site.yml` runs on every push to `main` that changes
`results/**`, `correctness/results/**`, or `site/**`: it regenerates the page
and pushes the single file to `WindChimeRan/WindChimeRan.github.io`, whose own
CI then redeploys. So the weekly benchmark push updates the public page with
no manual step.

One-time setup: create a fine-grained PAT with **Contents: read/write** scoped
to `WindChimeRan/WindChimeRan.github.io`, and save it in this repo as the
Actions secret **`PERSONAL_SITE_TOKEN`**. Until the secret exists, the
workflow builds the page as an artifact and skips the deploy.

## Local preview

    python3 site/generate.py            # writes site/out/index.html
    open site/out/index.html

## Data model and conventions

The page is keyed by (machine, model, split):

- **Apple M2 Max** — the legacy tree `results/<MODEL>/<split>/`.
- **Apple M5 Pro** — reserved: land future runs under
  `results/<MODEL>/m5pro/<split>/` (mirror the dgxspark platform-segment
  pattern). The tab exists today as a placeholder and fills automatically
  when the first `comparison.json` appears there.
- **NVIDIA DGX Spark** — `results/<MODEL>/dgxspark/<split>/`.

Adding a machine = one entry in `MACHINES` in `site/generate.py`.
Fidelity comes from `correctness/results/<MODEL>_comparison.json`.
Multi-node results are out of scope for the page (single-node serving only).

Design rules: stacks are listed alphabetically with the three lenses side by
side (deliberately not a speed-sorted leaderboard, per the paper's thesis);
run dates / harness commit / per-framework timestamps are muted meta info at
the bottom; the paper's failure vocabulary carries over (n/100 partial,
crossed-out crash, budget "skip").
