# SiliconBench Results — Gemma-4-E4B-it (chat)

**Model:** Gemma-4-E4B-it
**Split:** chat
**Generated:** 2026-07-03 18:32:18

## Concurrency: 1

| Metric | mlx_lm | ollama | omlx | vllm_metal | llamacpp |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | CRASHED | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 1091.9 | 0.0 | 873.5 | 960.6 | 1284.3 |
| TTFT p50 (ms) | 877.3 | 0.0 | 672.0 | 510.3 | 665.9 |
| TTFT p99 (ms) | 2909.7 | 0.0 | 2782.4 | 5196.2 | 4864.2 |
| Throughput avg (tok/s) | 20.8 | 0.0 | 5.9 | 21.9 | 30.0 |
| Output throughput (tok/s) | 14.4 | 0.0 | 24.2 | 18.4 | 21.1 |
| Input throughput (tok/s) | N/A | 0.0 | 309.0 | 238.4 | 272.9 |
| Total token throughput (tok/s) | N/A | 0.0 | 333.2 | 256.8 | 294.0 |
| ITL avg (ms) | 47.9 | 0.0 | 152.5 | 42.6 | 31.1 |
| ITL p50 (ms) | 47.3 | 0.0 | 155.3 | 44.2 | 31.1 |
| Latency avg (s) | 3.46 | 0.00 | 3.20 | 4.14 | 3.62 |
| Latency p99 (s) | 10.30 | 0.00 | 9.03 | 12.33 | 11.92 |
| Wall time (s) | 345.9 | 0.1 | 319.6 | 414.1 | 361.8 |

## Concurrency: 8

| Metric | mlx_lm | ollama | omlx | vllm_metal | llamacpp |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | CRASHED | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 23806.2 | 0.0 | 1202.5 | 444.2 | 9797.2 |
| TTFT p50 (ms) | 24235.1 | 0.0 | 1063.8 | 438.2 | 9210.8 |
| TTFT p99 (ms) | 39138.1 | 0.0 | 3671.6 | 687.3 | 19077.5 |
| Throughput avg (tok/s) | 20.8 | 0.0 | 3.9 | 7.5 | 14.1 |
| Output throughput (tok/s) | 14.5 | 0.0 | 56.3 | 58.7 | 36.1 |
| Input throughput (tok/s) | N/A | 0.0 | 713.2 | 746.4 | 463.6 |
| Total token throughput (tok/s) | N/A | 0.0 | 769.5 | 805.0 | 499.7 |
| ITL avg (ms) | 47.9 | 0.0 | 248.2 | 123.5 | 83.0 |
| ITL p50 (ms) | 47.2 | 0.0 | 247.0 | 123.4 | 76.3 |
| Latency avg (s) | 26.17 | 0.00 | 10.56 | 9.88 | 16.43 |
| Latency p99 (s) | 44.07 | 0.00 | 35.09 | 33.08 | 45.09 |
| Wall time (s) | 345.2 | 0.0 | 138.4 | 132.3 | 213.0 |

## Concurrency: 16

| Metric | mlx_lm | ollama | omlx | vllm_metal | llamacpp |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | CRASHED | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 47380.7 | 0.0 | 9571.8 | 572.8 | 24356.1 |
| TTFT p50 (ms) | 50047.1 | 0.0 | 9983.1 | 575.9 | 26939.3 |
| TTFT p99 (ms) | 68707.6 | 0.0 | 14098.8 | 790.0 | 35095.2 |
| Throughput avg (tok/s) | 20.8 | 0.0 | 3.6 | 6.2 | 15.2 |
| Output throughput (tok/s) | 14.5 | 0.0 | 58.1 | 86.8 | 35.7 |
| Input throughput (tok/s) | N/A | 0.0 | 730.6 | 1107.9 | 460.2 |
| Total token throughput (tok/s) | N/A | 0.0 | 788.7 | 1194.7 | 495.9 |
| ITL avg (ms) | 47.9 | 0.0 | 250.2 | 152.5 | 81.8 |
| ITL p50 (ms) | 47.2 | 0.0 | 254.8 | 151.8 | 64.5 |
| Latency avg (s) | 49.74 | 0.00 | 19.22 | 11.99 | 31.04 |
| Latency p99 (s) | 70.40 | 0.00 | 45.37 | 41.18 | 64.14 |
| Wall time (s) | 345.5 | 0.0 | 135.1 | 89.1 | 214.5 |

## Total Benchmark Duration

| Framework | mlx_lm | ollama | omlx | vllm_metal | llamacpp |
|-----------|--------|--------|--------|--------|--------|
| Duration | 17.7m | 0.2s | 10.4m | 11.0m | 13.7m |
