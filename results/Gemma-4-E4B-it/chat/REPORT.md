# SiliconBench Results — Gemma-4-E4B-it (chat)

**Model:** Gemma-4-E4B-it
**Split:** chat
**Generated:** 2026-07-08 22:52:31

## Concurrency: 1

| Metric | llamacpp | vllm_metal | mlx_lm | ollama | omlx | hf_transformers |
|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | CRASHED | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 1297.5 | 960.6 | 1089.8 | 0.0 | 502.7 | 2316.6 |
| TTFT p50 (ms) | 677.9 | 511.2 | 867.7 | 0.0 | 476.4 | 1071.9 |
| TTFT p99 (ms) | 4887.0 | 5207.4 | 2828.5 | 0.0 | 686.0 | 8581.0 |
| Throughput avg (tok/s) | 29.5 | 21.9 | 20.5 | 0.0 | 6.0 | 14.2 |
| Output throughput (tok/s) | 20.8 | 18.4 | 14.3 | 0.0 | 27.8 | 10.5 |
| Input throughput (tok/s) | 268.7 | 238.9 | N/A | 0.0 | 354.6 | 130.6 |
| Total token throughput (tok/s) | 289.5 | 257.3 | N/A | 0.0 | 382.5 | 141.2 |
| ITL avg (ms) | 31.6 | 42.5 | 48.6 | 0.0 | 149.5 | 66.5 |
| ITL p50 (ms) | 31.5 | 44.2 | 47.9 | 0.0 | 152.4 | 64.2 |
| Latency avg (s) | 3.67 | 4.13 | 3.49 | 0.00 | 2.78 | 7.56 |
| Latency p99 (s) | 12.25 | 12.32 | 10.41 | 0.00 | 8.64 | 27.30 |
| Wall time (s) | 367.4 | 413.2 | 348.8 | 0.1 | 278.4 | 755.8 |

## Concurrency: 8

| Metric | llamacpp | vllm_metal | mlx_lm | ollama | omlx | hf_transformers |
|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | CRASHED | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 9890.0 | 440.2 | 24031.9 | 0.0 | 1208.0 | 51331.1 |
| TTFT p50 (ms) | 9413.2 | 433.8 | 24466.0 | 0.0 | 1054.4 | 54119.9 |
| TTFT p99 (ms) | 19700.9 | 682.9 | 39585.4 | 0.0 | 3704.1 | 96326.1 |
| Throughput avg (tok/s) | 14.2 | 7.6 | 20.5 | 0.0 | 4.0 | 14.4 |
| Output throughput (tok/s) | 35.0 | 59.2 | 14.3 | 0.0 | 56.8 | 10.7 |
| Input throughput (tok/s) | 452.0 | 753.5 | N/A | 0.0 | 720.2 | 132.6 |
| Total token throughput (tok/s) | 487.0 | 812.7 | N/A | 0.0 | 777.0 | 143.3 |
| ITL avg (ms) | 84.1 | 122.3 | 48.6 | 0.0 | 244.1 | 65.7 |
| ITL p50 (ms) | 75.4 | 122.3 | 47.9 | 0.0 | 244.6 | 62.3 |
| Latency avg (s) | 16.79 | 9.78 | 26.43 | 0.00 | 10.47 | 56.49 |
| Latency p99 (s) | 46.20 | 32.78 | 44.60 | 0.00 | 34.74 | 105.05 |
| Wall time (s) | 218.4 | 131.0 | 348.7 | 0.0 | 137.1 | 744.7 |

## Concurrency: 16

| Metric | llamacpp | vllm_metal | mlx_lm | ollama | omlx | hf_transformers |
|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | CRASHED | 100 / 0 | 99 / 1 |
| TTFT avg (ms) | 24663.6 | 563.8 | 47816.4 | 0.0 | 9517.6 | 100741.6 |
| TTFT p50 (ms) | 26527.6 | 567.6 | 50518.7 | 0.0 | 9749.7 | 105156.1 |
| TTFT p99 (ms) | 35805.8 | 770.5 | 69427.7 | 0.0 | 14345.6 | 154768.9 |
| Throughput avg (tok/s) | 14.5 | 6.2 | 20.5 | 0.0 | 3.8 | 14.4 |
| Output throughput (tok/s) | 35.2 | 87.8 | 14.3 | 0.0 | 57.6 | 10.6 |
| Input throughput (tok/s) | 454.0 | 1120.6 | N/A | 0.0 | 735.0 | 132.5 |
| Total token throughput (tok/s) | 489.2 | 1208.4 | N/A | 0.0 | 792.6 | 143.1 |
| ITL avg (ms) | 87.0 | 150.5 | 48.6 | 0.0 | 247.6 | 65.6 |
| ITL p50 (ms) | 70.3 | 150.4 | 48.0 | 0.0 | 250.3 | 62.3 |
| Latency avg (s) | 31.57 | 11.85 | 50.21 | 0.00 | 18.98 | 105.92 |
| Latency p99 (s) | 67.89 | 40.63 | 71.15 | 0.00 | 46.87 | 158.34 |
| Wall time (s) | 217.4 | 88.1 | 348.8 | 0.0 | 134.3 | 744.1 |

## Total Benchmark Duration

| Framework | llamacpp | vllm_metal | mlx_lm | ollama | omlx | hf_transformers |
|-----------|--------|--------|--------|--------|--------|--------|
| Duration | 13.9m | 11.0m | 17.9m | 0.2s | 9.6m | 38.5m |
