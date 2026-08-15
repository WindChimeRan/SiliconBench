# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-08-15 16:23:48

## Concurrency: 1

| Metric | omlx | vllm_mlx | llamacpp | vllm_metal | ollama | mlx_lm |
|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | CRASHED | 93 / 7 | 100 / 0 | 93 / 7 | CRASHED | 94 / 6 |
| TTFT avg (ms) | 0.0 | 1582.8 | 1800.1 | 1637.9 | 0.0 | 1335.2 |
| TTFT p50 (ms) | 0.0 | 1417.3 | 1310.7 | 975.2 | 0.0 | 1141.9 |
| TTFT p99 (ms) | 0.0 | 3531.2 | 7170.5 | 8578.0 | 0.0 | 2884.2 |
| Throughput avg (tok/s) | 0.0 | 25.1 | 23.7 | 21.2 | 0.0 | 26.6 |
| Output throughput (tok/s) | 0.0 | 18.0 | 16.8 | 16.4 | 0.0 | 19.6 |
| Input throughput (tok/s) | 0.0 | 914.6 | 809.2 | 850.6 | 0.0 | 1006.0 |
| Total token throughput (tok/s) | 0.0 | 932.6 | 826.1 | 867.0 | 0.0 | 1025.6 |
| ITL avg (ms) | 0.0 | 38.2 | 41.1 | 45.4 | 0.0 | 36.3 |
| ITL p50 (ms) | 0.0 | 38.2 | 42.9 | 43.6 | 0.0 | 36.2 |
| Latency avg (s) | 0.00 | 5.08 | 5.74 | 5.43 | 0.00 | 4.62 |
| Latency p99 (s) | 0.00 | 12.10 | 14.03 | 14.48 | 0.00 | 10.80 |
| Wall time (s) | 0.1 | 479.9 | 573.8 | 513.7 | 0.1 | 440.4 |

## Concurrency: 8

| Metric | omlx | vllm_mlx | llamacpp | vllm_metal | ollama | mlx_lm |
|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | CRASHED | 48 / 52 | 100 / 0 | 93 / 7 | CRASHED | 94 / 6 |
| TTFT avg (ms) | 0.0 | 38968.5 | 11607.7 | 2233.1 | 0.0 | 3553.6 |
| TTFT p50 (ms) | 0.0 | 4022.6 | 12112.9 | 1581.6 | 0.0 | 2117.5 |
| TTFT p99 (ms) | 0.0 | 275708.8 | 23251.4 | 11054.3 | 0.0 | 17939.1 |
| Throughput avg (tok/s) | 0.0 | 3.8 | 13.7 | 5.5 | 0.0 | 6.7 |
| Output throughput (tok/s) | 0.0 | 1.4 | 37.4 | 36.8 | 0.0 | 36.4 |
| Input throughput (tok/s) | 0.0 | 109.0 | 1797.2 | 1822.1 | 0.0 | 1881.4 |
| Total token throughput (tok/s) | 0.0 | 110.4 | 1834.7 | 1858.9 | 0.0 | 1917.8 |
| ITL avg (ms) | 0.0 | 517.7 | 93.0 | 208.8 | 0.0 | 174.0 |
| ITL p50 (ms) | 0.0 | 230.3 | 75.4 | 180.5 | 0.0 | 159.8 |
| Latency avg (s) | 0.00 | 55.99 | 20.02 | 19.89 | 0.00 | 19.51 |
| Latency p99 (s) | 0.00 | 278.47 | 44.82 | 61.20 | 0.00 | 80.46 |
| Wall time (s) | 0.0 | 2188.9 | 258.3 | 239.8 | 0.0 | 235.5 |

## Concurrency: 16

| Metric | omlx | vllm_mlx | llamacpp | vllm_metal | ollama | mlx_lm |
|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | CRASHED | 52 / 48 | 100 / 0 | 93 / 7 | CRASHED | 94 / 6 |
| TTFT avg (ms) | 0.0 | 17586.5 | 26168.4 | 3312.5 | 0.0 | 6850.8 |
| TTFT p50 (ms) | 0.0 | 2337.8 | 28278.3 | 2221.8 | 0.0 | 3346.7 |
| TTFT p99 (ms) | 0.0 | 286957.6 | 40320.1 | 11778.7 | 0.0 | 34868.1 |
| Throughput avg (tok/s) | 0.0 | 4.7 | 15.5 | 3.1 | 0.0 | 3.7 |
| Output throughput (tok/s) | 0.0 | 6.4 | 43.1 | 42.4 | 0.0 | 40.1 |
| Input throughput (tok/s) | 0.0 | 767.4 | 2072.2 | 2143.3 | 0.0 | 2034.9 |
| Total token throughput (tok/s) | 0.0 | 773.9 | 2115.3 | 2185.8 | 0.0 | 2075.0 |
| ITL avg (ms) | 0.0 | 1197.0 | 79.0 | 391.3 | 0.0 | 340.6 |
| ITL p50 (ms) | 0.0 | 251.1 | 61.0 | 332.5 | 0.0 | 304.8 |
| Latency avg (s) | 0.00 | 45.03 | 33.48 | 32.90 | 0.00 | 35.12 |
| Latency p99 (s) | 0.00 | 297.06 | 64.88 | 95.19 | 0.00 | 118.24 |
| Wall time (s) | 0.0 | 370.5 | 224.1 | 203.9 | 0.0 | 217.7 |

## Total Benchmark Duration

| Framework | omlx | vllm_mlx | llamacpp | vllm_metal | ollama | mlx_lm |
|-----------|--------|--------|--------|--------|--------|--------|
| Duration | 0.2s | 51.0m | 18.2m | 16.4m | 0.2s | 15.3m |
