# SiliconBench Results — Qwen3.5-0.8B (agent)

**Model:** Qwen3.5-0.8B
**Split:** agent
**Generated:** 2026-08-25 21:21:42

## Concurrency: 1

| Metric | llamacpp | vllm_metal | omlx | vllm_mlx | mlx_lm |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 25 / 75 |
| TTFT avg (ms) | 441.5 | 248.1 | 482.0 | 407.9 | 545.3 |
| TTFT p50 (ms) | 305.8 | 200.4 | 441.2 | 341.6 | 504.2 |
| TTFT p99 (ms) | 1751.2 | 1112.6 | 1092.4 | 931.5 | 1033.2 |
| Throughput avg (tok/s) | 114.3 | 107.7 | 179.8 | 95.2 | 145.0 |
| Output throughput (tok/s) | 66.9 | 76.2 | 77.0 | 67.6 | 45.4 |
| Input throughput (tok/s) | 4658.3 | 6120.5 | 5644.0 | 3851.1 | 1178.4 |
| Total token throughput (tok/s) | 4725.2 | 6196.8 | 5721.0 | 3918.7 | 1223.9 |
| ITL avg (ms) | 8.4 | 9.0 | 5.6 | 9.9 | 6.9 |
| ITL p50 (ms) | 8.4 | 8.9 | 3.4 | 9.9 | 7.5 |
| Latency avg (s) | 0.99 | 0.75 | 0.82 | 1.19 | 1.92 |
| Latency p99 (s) | 3.10 | 2.78 | 2.39 | 3.14 | 3.07 |
| Wall time (s) | 99.1 | 75.4 | 81.8 | 119.5 | 99.7 |

## Concurrency: 8

| Metric | llamacpp | vllm_metal | omlx | vllm_mlx | mlx_lm |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 26 / 74 |
| TTFT avg (ms) | 2415.5 | 136.5 | 1643.2 | 917.5 | 2460.4 |
| TTFT p50 (ms) | 2242.9 | 118.9 | 1247.9 | 684.6 | 2599.0 |
| TTFT p99 (ms) | 6407.5 | 344.3 | 4265.3 | 3549.3 | 4945.5 |
| Throughput avg (tok/s) | 51.1 | 34.3 | 19.4 | 21.1 | 16.4 |
| Output throughput (tok/s) | 126.9 | 257.5 | 98.5 | 126.0 | 49.5 |
| Input throughput (tok/s) | 8829.1 | 20385.8 | 7536.1 | 6870.7 | 1350.8 |
| Total token throughput (tok/s) | 8955.9 | 20643.3 | 7634.7 | 6996.7 | 1400.3 |
| ITL avg (ms) | 26.6 | 28.5 | 51.5 | 54.5 | 61.1 |
| ITL p50 (ms) | 17.6 | 27.9 | 53.1 | 49.4 | 49.4 |
| Latency avg (s) | 4.09 | 1.72 | 4.76 | 5.28 | 14.34 |
| Latency p99 (s) | 13.79 | 7.82 | 20.38 | 21.64 | 31.77 |
| Wall time (s) | 52.3 | 22.7 | 61.3 | 67.0 | 89.8 |

## Concurrency: 16

| Metric | llamacpp | vllm_metal | omlx | vllm_mlx | mlx_lm |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 26 / 74 |
| TTFT avg (ms) | 5836.3 | 255.4 | 5990.6 | 2284.5 | 4648.3 |
| TTFT p50 (ms) | 5930.6 | 181.5 | 5879.0 | 1187.6 | 3292.0 |
| TTFT p99 (ms) | 10426.6 | 750.4 | 9557.3 | 9076.7 | 15130.0 |
| Throughput avg (tok/s) | 53.6 | 21.7 | 18.1 | 8.6 | 6.4 |
| Output throughput (tok/s) | 135.3 | 297.0 | 92.7 | 109.4 | 41.7 |
| Input throughput (tok/s) | 9413.4 | 23789.3 | 7742.7 | 6216.2 | 1089.6 |
| Total token throughput (tok/s) | 9548.6 | 24086.3 | 7835.4 | 6325.6 | 1131.3 |
| ITL avg (ms) | 22.5 | 45.7 | 55.3 | 136.6 | 156.1 |
| ITL p50 (ms) | 16.5 | 45.6 | 57.2 | 130.5 | 171.9 |
| Latency avg (s) | 7.43 | 2.70 | 9.06 | 11.55 | 35.79 |
| Latency p99 (s) | 16.55 | 12.23 | 23.59 | 37.59 | 64.50 |
| Wall time (s) | 49.1 | 19.4 | 59.6 | 74.0 | 111.3 |

## Total Benchmark Duration

| Framework | llamacpp | vllm_metal | omlx | vllm_mlx | mlx_lm |
|-----------|--------|--------|--------|--------|--------|
| Duration | 3.5m | 2.0m | 3.6m | 4.5m | 5.2m |
