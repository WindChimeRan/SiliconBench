# SiliconBench Results — m5pro (chat)

**Model:** m5pro
**Split:** chat
**Generated:** 2026-08-21 12:02:51

## Concurrency: 1

| Metric | omlx | vllm_mlx | llamacpp | mlx_lm | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 258.7 | 109.6 | 107.8 | 223.9 | 93.4 |
| TTFT p50 (ms) | 252.6 | 65.4 | 68.1 | 181.5 | 64.3 |
| TTFT p99 (ms) | 420.1 | 329.8 | 456.5 | 457.6 | 481.2 |
| Throughput avg (tok/s) | 8.8 | 99.5 | 112.9 | 114.6 | 106.1 |
| Output throughput (tok/s) | 109.0 | 95.3 | 105.5 | 93.9 | 100.9 |
| Input throughput (tok/s) | 1276.7 | 1125.7 | 1230.7 | 1046.6 | 1215.7 |
| Total token throughput (tok/s) | 1385.8 | 1220.9 | 1336.2 | 1140.5 | 1316.6 |
| ITL avg (ms) | 99.4 | 9.1 | 8.3 | 8.2 | 8.9 |
| ITL p50 (ms) | 105.0 | 9.0 | 8.3 | 8.0 | 8.8 |
| Latency avg (s) | 0.78 | 0.88 | 0.81 | 0.95 | 0.82 |
| Latency p99 (s) | 2.06 | 2.84 | 2.58 | 2.73 | 2.44 |
| Wall time (s) | 77.9 | 88.3 | 80.8 | 95.0 | 81.8 |

## Concurrency: 8

| Metric | omlx | vllm_mlx | llamacpp | mlx_lm | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 476.0 | 300.7 | 1049.4 | 1222.6 | 107.1 |
| TTFT p50 (ms) | 407.5 | 230.0 | 965.6 | 1051.2 | 94.9 |
| TTFT p99 (ms) | 1559.2 | 1035.5 | 2677.9 | 3505.1 | 275.9 |
| Throughput avg (tok/s) | 11.2 | 39.8 | 73.7 | 31.9 | 44.7 |
| Output throughput (tok/s) | 209.9 | 285.1 | 304.0 | 139.1 | 338.7 |
| Input throughput (tok/s) | 2457.6 | 3329.8 | 3545.1 | 1534.1 | 3972.1 |
| Total token throughput (tok/s) | 2667.5 | 3615.0 | 3849.1 | 1673.2 | 4310.8 |
| ITL avg (ms) | 91.7 | 23.2 | 12.7 | 39.5 | 21.0 |
| ITL p50 (ms) | 90.2 | 22.7 | 12.7 | 32.8 | 21.1 |
| Latency avg (s) | 3.08 | 2.29 | 2.12 | 4.85 | 1.87 |
| Latency p99 (s) | 9.56 | 7.61 | 4.65 | 17.51 | 5.64 |
| Wall time (s) | 40.4 | 29.9 | 28.0 | 64.8 | 25.0 |

## Concurrency: 16

| Metric | omlx | vllm_mlx | llamacpp | mlx_lm | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 2993.1 | 543.9 | 2926.3 | 1986.0 | 174.0 |
| TTFT p50 (ms) | 3192.9 | 430.5 | 3064.5 | 1238.4 | 130.7 |
| TTFT p99 (ms) | 4464.1 | 1475.8 | 4607.7 | 6578.3 | 397.7 |
| Throughput avg (tok/s) | 10.4 | 22.1 | 72.6 | 12.2 | 31.9 |
| Output throughput (tok/s) | 214.5 | 318.0 | 296.0 | 144.4 | 456.1 |
| Input throughput (tok/s) | 2510.9 | 3600.8 | 3451.6 | 1601.0 | 5149.6 |
| Total token throughput (tok/s) | 2725.4 | 3918.8 | 3747.6 | 1745.4 | 5605.7 |
| ITL avg (ms) | 92.3 | 41.3 | 13.1 | 80.3 | 29.6 |
| ITL p50 (ms) | 92.0 | 42.2 | 12.9 | 83.6 | 30.4 |
| Latency avg (s) | 5.75 | 4.13 | 4.02 | 9.16 | 2.71 |
| Latency p99 (s) | 13.71 | 13.39 | 7.68 | 26.23 | 8.33 |
| Wall time (s) | 39.6 | 27.6 | 28.8 | 62.1 | 19.3 |

## Total Benchmark Duration

| Framework | omlx | vllm_mlx | llamacpp | mlx_lm | vllm_metal |
|-----------|--------|--------|--------|--------|--------|
| Duration | 2.8m | 2.5m | 2.4m | 3.8m | 2.2m |
