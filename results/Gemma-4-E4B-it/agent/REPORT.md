# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-07-09 04:11:38

## Concurrency: 1

| Metric | omlx | ollama | mlx_lm | vllm_metal | llamacpp |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 94 / 6 | CRASHED | 91 / 9 | 95 / 5 | 100 / 0 |
| TTFT avg (ms) | 3148.3 | 0.0 | 4751.8 | 6377.6 | 4434.1 |
| TTFT p50 (ms) | 1694.8 | 0.0 | 3256.6 | 3139.5 | 2919.7 |
| TTFT p99 (ms) | 15965.0 | 0.0 | 15663.2 | 31285.4 | 17744.7 |
| Throughput avg (tok/s) | 6.7 | 0.0 | 12.8 | 18.4 | 30.7 |
| Output throughput (tok/s) | 14.7 | 0.0 | 5.3 | 8.4 | 13.0 |
| Input throughput (tok/s) | 1381.6 | 0.0 | N/A | 451.2 | 624.7 |
| Total token throughput (tok/s) | 1396.3 | 0.0 | N/A | 459.6 | 637.7 |
| ITL avg (ms) | 148.3 | 0.0 | 68.3 | 52.5 | 31.6 |
| ITL p50 (ms) | 149.7 | 0.0 | 47.3 | 50.7 | 31.6 |
| Latency avg (s) | 5.97 | 0.00 | 6.99 | 10.63 | 7.43 |
| Latency p99 (s) | 20.29 | 0.00 | 16.24 | 35.94 | 20.45 |
| Wall time (s) | 568.3 | 0.2 | 736.0 | 1022.1 | 743.1 |

## Concurrency: 8

| Metric | omlx | ollama | mlx_lm | vllm_metal | llamacpp |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 94 / 6 | CRASHED | 91 / 9 | 94 / 6 | 100 / 0 |
| TTFT avg (ms) | 1455.9 | 0.0 | 54199.8 | 8752.1 | 22330.8 |
| TTFT p50 (ms) | 1214.0 | 0.0 | 55753.4 | 6135.5 | 20029.5 |
| TTFT p99 (ms) | 4384.3 | 0.0 | 78260.7 | 35502.5 | 51632.5 |
| Throughput avg (tok/s) | 3.5 | 0.0 | 13.0 | 2.5 | 12.1 |
| Output throughput (tok/s) | 48.7 | 0.0 | 5.4 | 11.8 | 21.2 |
| Input throughput (tok/s) | 4689.9 | 0.0 | N/A | 653.9 | 1021.4 |
| Total token throughput (tok/s) | 4738.6 | 0.0 | N/A | 665.6 | 1042.6 |
| ITL avg (ms) | 280.8 | 0.0 | 67.4 | 568.9 | 136.5 |
| ITL p50 (ms) | 278.7 | 0.0 | 47.3 | 476.1 | 98.9 |
| Latency avg (s) | 13.54 | 0.00 | 56.41 | 58.39 | 35.80 |
| Latency p99 (s) | 42.39 | 0.00 | 80.81 | 219.85 | 104.24 |
| Wall time (s) | 167.4 | 0.1 | 729.3 | 697.9 | 454.5 |

## Concurrency: 16

| Metric | omlx | ollama | mlx_lm | vllm_metal | llamacpp |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 94 / 6 | CRASHED | 91 / 9 | 90 / 10 | 100 / 0 |
| TTFT avg (ms) | 12556.6 | 0.0 | 107645.5 | 16554.1 | 56870.0 |
| TTFT p50 (ms) | 13013.0 | 0.0 | 114441.1 | 9770.5 | 56625.1 |
| TTFT p99 (ms) | 21310.9 | 0.0 | 141733.1 | 54817.0 | 97748.5 |
| Throughput avg (tok/s) | 3.3 | 0.0 | 12.8 | 1.1 | 12.1 |
| Output throughput (tok/s) | 50.3 | 0.0 | 5.3 | 10.9 | 21.0 |
| Input throughput (tok/s) | 4774.7 | 0.0 | N/A | 668.0 | 1014.9 |
| Total token throughput (tok/s) | 4825.0 | 0.0 | N/A | 678.9 | 1035.9 |
| ITL avg (ms) | 289.6 | 0.0 | 68.5 | 1416.8 | 134.5 |
| ITL p50 (ms) | 280.9 | 0.0 | 48.0 | 1104.4 | 100.9 |
| Latency avg (s) | 25.10 | 0.00 | 109.89 | 102.22 | 70.45 |
| Latency p99 (s) | 50.92 | 0.00 | 141.74 | 297.20 | 145.75 |
| Wall time (s) | 164.4 | 0.0 | 737.2 | 670.0 | 457.4 |

## Total Benchmark Duration

| Framework | omlx | ollama | mlx_lm | vllm_metal | llamacpp |
|-----------|--------|--------|--------|--------|--------|
| Duration | 15.7m | 0.3s | 38.0m | 41.4m | 28.8m |
