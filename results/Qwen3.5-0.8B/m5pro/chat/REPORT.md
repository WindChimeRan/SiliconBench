# SiliconBench Results — Qwen3.5-0.8B (chat)

**Model:** Qwen3.5-0.8B
**Split:** chat
**Generated:** 2026-08-25 21:21:42

## Concurrency: 1

| Metric | vllm_mlx | llamacpp | mlx_lm | omlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 109.6 | 107.8 | 223.9 | 271.6 | 93.4 |
| TTFT p50 (ms) | 65.4 | 68.1 | 181.5 | 249.3 | 64.3 |
| TTFT p99 (ms) | 329.8 | 456.5 | 457.6 | 480.1 | 481.2 |
| Throughput avg (tok/s) | 99.5 | 112.9 | 114.6 | 174.7 | 106.1 |
| Output throughput (tok/s) | 95.3 | 105.5 | 93.9 | 113.4 | 100.9 |
| Input throughput (tok/s) | 1125.7 | 1230.7 | 1046.6 | 1328.5 | 1215.7 |
| Total token throughput (tok/s) | 1220.9 | 1336.2 | 1140.5 | 1442.0 | 1316.6 |
| ITL avg (ms) | 9.1 | 8.3 | 8.2 | 5.7 | 8.9 |
| ITL p50 (ms) | 9.0 | 8.3 | 8.0 | 5.2 | 8.8 |
| Latency avg (s) | 0.88 | 0.81 | 0.95 | 0.75 | 0.82 |
| Latency p99 (s) | 2.84 | 2.58 | 2.73 | 2.02 | 2.44 |
| Wall time (s) | 88.3 | 80.8 | 95.0 | 74.8 | 81.8 |

## Concurrency: 8

| Metric | vllm_mlx | llamacpp | mlx_lm | omlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 300.7 | 1049.4 | 1222.6 | 543.6 | 107.1 |
| TTFT p50 (ms) | 230.0 | 965.6 | 1051.2 | 426.8 | 94.9 |
| TTFT p99 (ms) | 1035.5 | 2677.9 | 3505.1 | 1705.4 | 275.9 |
| Throughput avg (tok/s) | 39.8 | 73.7 | 31.9 | 32.9 | 44.7 |
| Output throughput (tok/s) | 285.1 | 304.0 | 139.1 | 208.0 | 338.7 |
| Input throughput (tok/s) | 3329.8 | 3545.1 | 1534.1 | 2433.7 | 3972.1 |
| Total token throughput (tok/s) | 3615.0 | 3849.1 | 1673.2 | 2641.7 | 4310.8 |
| ITL avg (ms) | 23.2 | 12.7 | 39.5 | 30.4 | 21.0 |
| ITL p50 (ms) | 22.7 | 12.7 | 32.8 | 32.6 | 21.1 |
| Latency avg (s) | 2.29 | 2.12 | 4.85 | 3.12 | 1.87 |
| Latency p99 (s) | 7.61 | 4.65 | 17.51 | 9.99 | 5.64 |
| Wall time (s) | 29.9 | 28.0 | 64.8 | 40.8 | 25.0 |

## Concurrency: 16

| Metric | vllm_mlx | llamacpp | mlx_lm | omlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 543.9 | 2926.3 | 1986.0 | 3112.8 | 174.0 |
| TTFT p50 (ms) | 430.5 | 3064.5 | 1238.4 | 3332.2 | 130.7 |
| TTFT p99 (ms) | 1475.8 | 4607.7 | 6578.3 | 4523.7 | 397.7 |
| Throughput avg (tok/s) | 22.1 | 72.6 | 12.2 | 31.1 | 31.9 |
| Output throughput (tok/s) | 318.0 | 296.0 | 144.4 | 212.6 | 456.1 |
| Input throughput (tok/s) | 3600.8 | 3451.6 | 1601.0 | 2462.9 | 5149.6 |
| Total token throughput (tok/s) | 3918.8 | 3747.6 | 1745.4 | 2675.5 | 5605.7 |
| ITL avg (ms) | 41.3 | 13.1 | 80.3 | 32.2 | 29.6 |
| ITL p50 (ms) | 42.2 | 12.9 | 83.6 | 34.2 | 30.4 |
| Latency avg (s) | 4.13 | 4.02 | 9.16 | 5.87 | 2.71 |
| Latency p99 (s) | 13.39 | 7.68 | 26.23 | 14.11 | 8.33 |
| Wall time (s) | 27.6 | 28.8 | 62.1 | 40.4 | 19.3 |

## Total Benchmark Duration

| Framework | vllm_mlx | llamacpp | mlx_lm | omlx | vllm_metal |
|-----------|--------|--------|--------|--------|--------|
| Duration | 2.5m | 2.4m | 3.8m | 2.8m | 2.2m |
