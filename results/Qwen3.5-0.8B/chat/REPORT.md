# SiliconBench Results — Qwen3.5-0.8B (chat)

**Model:** Qwen3.5-0.8B
**Split:** chat
**Generated:** 2026-05-23 17:21:20

## Concurrency: 1

| Metric | llamacpp | omlx | mlx_lm | ollama | vllm_metal | vllm_mlx | sglang |
|--------|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 99 / 1 | 99 / 1 | 98 / 2 | CRASHED | 99 / 1 | 99 / 1 | CRASHED |
| TTFT avg (ms) | 204.7 | 198.5 | 307.4 | 0.0 | 429.1 | 198.2 | 0.0 |
| TTFT p50 (ms) | 131.7 | 129.3 | 218.9 | 0.0 | 212.1 | 143.8 | 0.0 |
| TTFT p99 (ms) | 839.9 | 725.7 | 777.9 | 0.0 | 1492.5 | 799.4 | 0.0 |
| Throughput avg (tok/s) | 111.2 | 149.9 | 108.8 | 0.0 | 74.2 | 101.5 | 0.0 |
| Output throughput (tok/s) | 92.3 | 117.7 | 68.7 | 0.0 | 54.6 | 87.3 | 0.0 |
| Input throughput (tok/s) | 1066.8 | 1366.2 | N/A | 0.0 | 629.5 | 1121.3 | 0.0 |
| Total token throughput (tok/s) | 1159.1 | 1483.9 | N/A | 0.0 | 684.1 | 1208.5 | 0.0 |
| ITL avg (ms) | 8.6 | 6.1 | 9.0 | 0.0 | 13.1 | 8.9 | 0.0 |
| ITL p50 (ms) | 8.6 | 6.1 | 8.8 | 0.0 | 11.8 | 8.9 | 0.0 |
| Latency avg (s) | 0.94 | 0.73 | 0.84 | 0.00 | 1.59 | 0.89 | 0.00 |
| Latency p99 (s) | 3.09 | 1.80 | 2.44 | 0.00 | 5.21 | 2.77 | 0.00 |
| Wall time (s) | 93.0 | 72.6 | 83.7 | 0.1 | 157.6 | 88.5 | 0.0 |

## Concurrency: 8

| Metric | llamacpp | omlx | mlx_lm | ollama | vllm_metal | vllm_mlx | sglang |
|--------|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 99 / 1 | 99 / 1 | 98 / 2 | CRASHED | 99 / 1 | 96 / 4 | CRASHED |
| TTFT avg (ms) | 1438.7 | 333.2 | 5812.9 | 0.0 | 688.2 | 204.2 | 0.0 |
| TTFT p50 (ms) | 1331.0 | 221.1 | 5820.6 | 0.0 | 276.0 | 195.1 | 0.0 |
| TTFT p99 (ms) | 3393.3 | 1468.1 | 9786.3 | 0.0 | 3955.3 | 294.5 | 0.0 |
| Throughput avg (tok/s) | 54.5 | 31.9 | 108.7 | 0.0 | 16.2 | 29.3 | 0.0 |
| Output throughput (tok/s) | 224.4 | 221.6 | 68.9 | 0.0 | 106.8 | 228.4 | 0.0 |
| Input throughput (tok/s) | 2593.5 | 2542.1 | N/A | 0.0 | 1239.5 | 4859.5 | 0.0 |
| Total token throughput (tok/s) | 2817.9 | 2763.6 | N/A | 0.0 | 1346.3 | 5088.0 | 0.0 |
| ITL avg (ms) | 17.7 | 31.2 | 9.0 | 0.0 | 66.2 | 26.5 | 0.0 |
| ITL p50 (ms) | 17.3 | 29.6 | 8.8 | 0.0 | 63.2 | 27.3 | 0.0 |
| Latency avg (s) | 2.91 | 2.99 | 6.35 | 0.00 | 6.25 | 1.51 | 0.00 |
| Latency p99 (s) | 6.65 | 9.51 | 10.61 | 0.00 | 21.67 | 7.37 | 0.00 |
| Wall time (s) | 38.3 | 39.0 | 83.5 | 0.0 | 80.1 | 19.8 | 0.0 |

## Concurrency: 16

| Metric | llamacpp | omlx | mlx_lm | ollama | vllm_metal | vllm_mlx | sglang |
|--------|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 99 / 1 | 99 / 1 | 98 / 2 | CRASHED | 99 / 1 | 99 / 1 | CRASHED |
| TTFT avg (ms) | 3955.1 | 2846.5 | 11355.8 | 0.0 | 1248.7 | 275.9 | 0.0 |
| TTFT p50 (ms) | 4230.8 | 2933.8 | 11791.5 | 0.0 | 652.2 | 262.6 | 0.0 |
| TTFT p99 (ms) | 5936.1 | 4624.5 | 17275.3 | 0.0 | 5574.7 | 518.2 | 0.0 |
| Throughput avg (tok/s) | 54.9 | 30.6 | 108.8 | 0.0 | 9.7 | 22.1 | 0.0 |
| Output throughput (tok/s) | 224.1 | 224.0 | 69.1 | 0.0 | 124.1 | 332.1 | 0.0 |
| Input throughput (tok/s) | 2591.1 | 2586.9 | N/A | 0.0 | 1465.5 | 5808.4 | 0.0 |
| Total token throughput (tok/s) | 2815.3 | 2810.9 | N/A | 0.0 | 1589.5 | 6140.5 | 0.0 |
| ITL avg (ms) | 17.3 | 34.0 | 9.0 | 0.0 | 120.2 | 38.2 | 0.0 |
| ITL p50 (ms) | 17.1 | 32.0 | 8.7 | 0.0 | 115.5 | 37.3 | 0.0 |
| Latency avg (s) | 5.43 | 5.55 | 11.89 | 0.00 | 10.35 | 2.32 | 0.00 |
| Latency p99 (s) | 10.11 | 11.81 | 17.66 | 0.00 | 35.75 | 10.09 | 0.00 |
| Wall time (s) | 38.3 | 38.4 | 83.1 | 0.0 | 67.7 | 17.1 | 0.0 |

## Total Benchmark Duration

| Framework | llamacpp | omlx | mlx_lm | ollama | vllm_metal | vllm_mlx | sglang |
|-----------|--------|--------|--------|--------|--------|--------|--------|
| Duration | 2.9m | 2.6m | 4.3m | 0.2s | 5.3m | 2.2m | 0.0s |
