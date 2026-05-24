# SiliconBench Results — Gemma-4-E4B-it (chat)

**Model:** Gemma-4-E4B-it
**Split:** chat
**Generated:** 2026-05-24 04:26:07

## Concurrency: 1

| Metric | vllm_metal | mlx_lm | llamacpp | omlx |
|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 914.0 | 1093.5 | 987.6 | 620.4 |
| TTFT p50 (ms) | 462.8 | 877.1 | 601.0 | 411.3 |
| TTFT p99 (ms) | 5101.1 | 2851.5 | 4867.8 | 2712.4 |
| Throughput avg (tok/s) | 19.1 | 20.8 | 29.8 | 29.3 |
| Output throughput (tok/s) | 15.3 | 14.4 | 23.0 | 25.4 |
| Input throughput (tok/s) | 196.7 | N/A | 294.9 | 324.1 |
| Total token throughput (tok/s) | 212.1 | N/A | 317.9 | 349.5 |
| ITL avg (ms) | 52.5 | 47.9 | 31.2 | 31.4 |
| ITL p50 (ms) | 44.2 | 47.5 | 31.1 | 31.5 |
| Latency avg (s) | 5.02 | 3.46 | 3.35 | 3.05 |
| Latency p99 (s) | 21.71 | 10.30 | 9.15 | 8.83 |
| Wall time (s) | 501.9 | 346.1 | 334.8 | 304.7 |

## Concurrency: 8

| Metric | vllm_metal | mlx_lm | llamacpp | omlx |
|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 347.7 | 23865.3 | 3113.9 | 747.8 |
| TTFT p50 (ms) | 355.5 | 24259.1 | 2980.8 | 627.0 |
| TTFT p99 (ms) | 486.3 | 39219.6 | 6254.7 | 2628.8 |
| Throughput avg (tok/s) | 6.5 | 20.8 | 22.7 | 8.5 |
| Output throughput (tok/s) | 50.9 | 14.4 | 90.3 | 63.5 |
| Input throughput (tok/s) | 646.8 | N/A | 1159.0 | 801.2 |
| Total token throughput (tok/s) | 697.6 | N/A | 1249.3 | 864.8 |
| ITL avg (ms) | 142.4 | 48.0 | 41.5 | 110.9 |
| ITL p50 (ms) | 143.1 | 47.5 | 39.9 | 110.8 |
| Latency avg (s) | 11.29 | 26.23 | 6.23 | 9.22 |
| Latency p99 (s) | 38.22 | 44.17 | 16.49 | 30.85 |
| Wall time (s) | 152.7 | 346.0 | 85.2 | 123.2 |

## Concurrency: 16

| Metric | vllm_metal | mlx_lm | llamacpp | omlx |
|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 454.7 | 47393.3 | 8432.3 | 8366.1 |
| TTFT p50 (ms) | 459.7 | 50111.0 | 8764.0 | 8496.9 |
| TTFT p99 (ms) | 624.8 | 68635.6 | 13864.2 | 13497.5 |
| Throughput avg (tok/s) | 4.9 | 20.8 | 23.1 | 8.6 |
| Output throughput (tok/s) | 70.2 | 14.5 | 93.4 | 64.2 |
| Input throughput (tok/s) | 905.3 | N/A | 1198.7 | 822.1 |
| Total token throughput (tok/s) | 975.5 | N/A | 1292.1 | 886.3 |
| ITL avg (ms) | 191.0 | 47.9 | 40.3 | 108.0 |
| ITL p50 (ms) | 193.3 | 47.4 | 39.6 | 110.8 |
| Latency avg (s) | 14.63 | 49.76 | 11.49 | 16.79 |
| Latency p99 (s) | 50.68 | 70.33 | 24.31 | 40.21 |
| Wall time (s) | 109.1 | 345.6 | 82.4 | 120.1 |

## Total Benchmark Duration

| Framework | vllm_metal | mlx_lm | llamacpp | omlx |
|-----------|--------|--------|--------|--------|
| Duration | 13.2m | 17.8m | 8.7m | 9.8m |
