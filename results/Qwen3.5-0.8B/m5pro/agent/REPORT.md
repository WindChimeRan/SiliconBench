# SiliconBench Results — Qwen3.5-0.8B (agent)

**Model:** Qwen3.5-0.8B
**Split:** agent
**Generated:** 2026-08-21 21:07:43

## Concurrency: 1

| Metric | llamacpp | vllm_metal | omlx | mlx_lm | vllm_mlx |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 25 / 75 | 100 / 0 |
| TTFT avg (ms) | 441.5 | 248.1 | 306.3 | 556.7 | 407.9 |
| TTFT p50 (ms) | 305.8 | 200.4 | 296.0 | 507.0 | 341.6 |
| TTFT p99 (ms) | 1751.2 | 1112.6 | 429.2 | 1044.5 | 931.5 |
| Throughput avg (tok/s) | 114.3 | 107.7 | 14.5 | 100.4 | 95.2 |
| Output throughput (tok/s) | 66.9 | 76.2 | 98.3 | 44.3 | 67.6 |
| Input throughput (tok/s) | 4658.3 | 6120.5 | 7203.2 | 1149.8 | 3851.1 |
| Total token throughput (tok/s) | 4725.2 | 6196.8 | 7301.5 | 1194.1 | 3918.7 |
| ITL avg (ms) | 8.4 | 9.0 | 74.4 | 13.7 | 9.9 |
| ITL p50 (ms) | 8.4 | 8.9 | 70.8 | 7.9 | 9.9 |
| Latency avg (s) | 0.99 | 0.75 | 0.64 | 1.97 | 1.19 |
| Latency p99 (s) | 3.10 | 2.78 | 2.10 | 3.12 | 3.14 |
| Wall time (s) | 99.1 | 75.4 | 64.1 | 102.2 | 119.5 |

## Concurrency: 8

| Metric | llamacpp | vllm_metal | omlx | mlx_lm | vllm_mlx |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 26 / 74 | 100 / 0 |
| TTFT avg (ms) | 2415.5 | 136.5 | 594.6 | 2472.3 | 917.5 |
| TTFT p50 (ms) | 2242.9 | 118.9 | 515.1 | 2534.3 | 684.6 |
| TTFT p99 (ms) | 6407.5 | 344.3 | 2074.1 | 5561.5 | 3549.3 |
| Throughput avg (tok/s) | 51.1 | 34.3 | 8.8 | 14.9 | 21.1 |
| Output throughput (tok/s) | 126.9 | 257.5 | 146.4 | 51.8 | 126.0 |
| Input throughput (tok/s) | 8829.1 | 20385.8 | 10877.8 | 1415.8 | 6870.7 |
| Total token throughput (tok/s) | 8955.9 | 20643.3 | 11024.2 | 1467.6 | 6996.7 |
| ITL avg (ms) | 26.6 | 28.5 | 118.3 | 64.6 | 54.5 |
| ITL p50 (ms) | 17.6 | 27.9 | 113.5 | 54.6 | 49.4 |
| Latency avg (s) | 4.09 | 1.72 | 3.26 | 13.79 | 5.28 |
| Latency p99 (s) | 13.79 | 7.82 | 14.23 | 33.88 | 21.64 |
| Wall time (s) | 52.3 | 22.7 | 42.4 | 85.5 | 67.0 |

## Concurrency: 16

| Metric | llamacpp | vllm_metal | omlx | mlx_lm | vllm_mlx |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 28 / 72 | 100 / 0 |
| TTFT avg (ms) | 5836.3 | 255.4 | 3388.3 | 4621.1 | 2284.5 |
| TTFT p50 (ms) | 5930.6 | 181.5 | 3344.2 | 3080.4 | 1187.6 |
| TTFT p99 (ms) | 10426.6 | 750.4 | 5518.1 | 14679.7 | 9076.7 |
| Throughput avg (tok/s) | 53.6 | 21.7 | 8.2 | 4.6 | 8.6 |
| Output throughput (tok/s) | 135.3 | 297.0 | 147.8 | 41.0 | 109.4 |
| Input throughput (tok/s) | 9413.4 | 23789.3 | 10986.0 | 1036.9 | 6216.2 |
| Total token throughput (tok/s) | 9548.6 | 24086.3 | 11133.8 | 1077.9 | 6325.6 |
| ITL avg (ms) | 22.5 | 45.7 | 124.6 | 510.0 | 136.6 |
| ITL p50 (ms) | 16.5 | 45.6 | 121.1 | 191.2 | 130.5 |
| Latency avg (s) | 7.43 | 2.70 | 6.24 | 39.76 | 11.55 |
| Latency p99 (s) | 16.55 | 12.23 | 17.80 | 68.16 | 37.59 |
| Wall time (s) | 49.1 | 19.4 | 42.0 | 125.5 | 74.0 |

## Total Benchmark Duration

| Framework | llamacpp | vllm_metal | omlx | mlx_lm | vllm_mlx |
|-----------|--------|--------|--------|--------|--------|
| Duration | 3.5m | 2.0m | 2.6m | 5.4m | 4.5m |
