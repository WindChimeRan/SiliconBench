# Superseded — vllm-metal capped at half the machine

This arm ran under serve_vllm_metal.sh's old `VLLM_METAL_MEMORY_FRACTION=0.5`
pin, removed in 46e7e1e. vllm-metal's own default is `auto`, which resolves to
0.92, while oMLX ran a soft 0.85 / hard 0.95 guard and llama.cpp had no
comparable cap — so the pin was never an apples-to-apples memory budget.

Output throughput at c=1/2/4: 22.3 / 25.7 / 24.6 tok/s, against 28.3 / 32.6 /
35.3 for the published arm measured without it.

Predates the run_config block (b8de3f3), so this file records no serve_env;
the pin is attested by the removal commit, not by the file.

Kept for provenance. Do not plot.
