# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-08-15 16:29:42

## Concurrency: 1

| Metric | vllm_mlx | llamacpp | vllm_metal | mlx_lm |
|--------|--------|--------|--------|--------|
| Successful / Failed | 93 / 7 | 100 / 0 | 93 / 7 | 94 / 6 |
| TTFT avg (ms) | 1582.8 | 1800.1 | 1637.9 | 1335.2 |
| TTFT p50 (ms) | 1417.3 | 1310.7 | 975.2 | 1141.9 |
| TTFT p99 (ms) | 3531.2 | 7170.5 | 8578.0 | 2884.2 |
| Throughput avg (tok/s) | 25.1 | 23.7 | 21.2 | 26.6 |
| Output throughput (tok/s) | 18.0 | 16.8 | 16.4 | 19.6 |
| Input throughput (tok/s) | 914.6 | 809.2 | 850.6 | 1006.0 |
| Total token throughput (tok/s) | 932.6 | 826.1 | 867.0 | 1025.6 |
| ITL avg (ms) | 38.2 | 41.1 | 45.4 | 36.3 |
| ITL p50 (ms) | 38.2 | 42.9 | 43.6 | 36.2 |
| Latency avg (s) | 5.08 | 5.74 | 5.43 | 4.62 |
| Latency p99 (s) | 12.10 | 14.03 | 14.48 | 10.80 |
| Wall time (s) | 479.9 | 573.8 | 513.7 | 440.4 |

## Concurrency: 8

| Metric | vllm_mlx | llamacpp | vllm_metal | mlx_lm |
|--------|--------|--------|--------|--------|
| Successful / Failed | 48 / 52 | 100 / 0 | 93 / 7 | 94 / 6 |
| TTFT avg (ms) | 38968.5 | 11607.7 | 2233.1 | 3553.6 |
| TTFT p50 (ms) | 4022.6 | 12112.9 | 1581.6 | 2117.5 |
| TTFT p99 (ms) | 275708.8 | 23251.4 | 11054.3 | 17939.1 |
| Throughput avg (tok/s) | 3.8 | 13.7 | 5.5 | 6.7 |
| Output throughput (tok/s) | 1.4 | 37.4 | 36.8 | 36.4 |
| Input throughput (tok/s) | 109.0 | 1797.2 | 1822.1 | 1881.4 |
| Total token throughput (tok/s) | 110.4 | 1834.7 | 1858.9 | 1917.8 |
| ITL avg (ms) | 517.7 | 93.0 | 208.8 | 174.0 |
| ITL p50 (ms) | 230.3 | 75.4 | 180.5 | 159.8 |
| Latency avg (s) | 55.99 | 20.02 | 19.89 | 19.51 |
| Latency p99 (s) | 278.47 | 44.82 | 61.20 | 80.46 |
| Wall time (s) | 2188.9 | 258.3 | 239.8 | 235.5 |

## Concurrency: 16

| Metric | vllm_mlx | llamacpp | vllm_metal | mlx_lm |
|--------|--------|--------|--------|--------|
| Successful / Failed | 52 / 48 | 100 / 0 | 93 / 7 | 94 / 6 |
| TTFT avg (ms) | 17586.5 | 26168.4 | 3312.5 | 6850.8 |
| TTFT p50 (ms) | 2337.8 | 28278.3 | 2221.8 | 3346.7 |
| TTFT p99 (ms) | 286957.6 | 40320.1 | 11778.7 | 34868.1 |
| Throughput avg (tok/s) | 4.7 | 15.5 | 3.1 | 3.7 |
| Output throughput (tok/s) | 6.4 | 43.1 | 42.4 | 40.1 |
| Input throughput (tok/s) | 767.4 | 2072.2 | 2143.3 | 2034.9 |
| Total token throughput (tok/s) | 773.9 | 2115.3 | 2185.8 | 2075.0 |
| ITL avg (ms) | 1197.0 | 79.0 | 391.3 | 340.6 |
| ITL p50 (ms) | 251.1 | 61.0 | 332.5 | 304.8 |
| Latency avg (s) | 45.03 | 33.48 | 32.90 | 35.12 |
| Latency p99 (s) | 297.06 | 64.88 | 95.19 | 118.24 |
| Wall time (s) | 370.5 | 224.1 | 203.9 | 217.7 |

## Total Benchmark Duration

| Framework | vllm_mlx | llamacpp | vllm_metal | mlx_lm |
|-----------|--------|--------|--------|--------|
| Duration | 51.0m | 18.2m | 16.4m | 15.3m |
