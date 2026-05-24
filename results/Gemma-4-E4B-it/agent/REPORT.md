# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-05-24 06:46:51

## Concurrency: 1

| Metric | vllm_metal | llamacpp | mlx_lm | omlx |
|--------|--------|--------|--------|--------|
| Successful / Failed | 95 / 5 | 100 / 0 | 91 / 9 | 100 / 0 |
| TTFT avg (ms) | 6368.5 | 4536.9 | 4713.6 | 1887.5 |
| TTFT p50 (ms) | 3067.8 | 3319.8 | 3198.0 | 1519.2 |
| TTFT p99 (ms) | 30826.9 | 17519.9 | 15433.5 | 7302.6 |
| Throughput avg (tok/s) | 9.6 | 30.8 | 13.0 | 27.8 |
| Output throughput (tok/s) | 6.0 | 12.8 | 5.4 | 18.5 |
| Input throughput (tok/s) | 322.7 | 614.9 | N/A | 977.5 |
| Total token throughput (tok/s) | 328.7 | 627.8 | N/A | 996.0 |
| ITL avg (ms) | 118.9 | 31.5 | 67.4 | 32.6 |
| ITL p50 (ms) | 107.8 | 31.5 | 47.2 | 32.3 |
| Latency avg (s) | 14.92 | 7.55 | 6.92 | 4.72 |
| Latency p99 (s) | 46.23 | 20.58 | 16.07 | 11.82 |
| Wall time (s) | 1429.4 | 754.9 | 729.4 | 472.4 |

## Concurrency: 8

| Metric | vllm_metal | llamacpp | mlx_lm | omlx |
|--------|--------|--------|--------|--------|
| Successful / Failed | 95 / 5 | 100 / 0 | 91 / 9 | 100 / 0 |
| TTFT avg (ms) | 8141.0 | 21892.7 | 54231.6 | 858.7 |
| TTFT p50 (ms) | 5960.1 | 21124.6 | 55813.5 | 721.0 |
| TTFT p99 (ms) | 25614.7 | 49484.5 | 78302.8 | 2899.2 |
| Throughput avg (tok/s) | 2.0 | 10.9 | 13.0 | 7.9 |
| Output throughput (tok/s) | 10.6 | 21.0 | 5.4 | 60.6 |
| Input throughput (tok/s) | 580.4 | 1007.8 | N/A | 3185.5 |
| Total token throughput (tok/s) | 591.0 | 1028.8 | N/A | 3246.1 |
| ITL avg (ms) | 655.4 | 160.9 | 67.5 | 116.8 |
| ITL p50 (ms) | 521.1 | 119.7 | 47.3 | 118.4 |
| Latency avg (s) | 65.71 | 36.18 | 56.44 | 11.14 |
| Latency p99 (s) | 248.09 | 107.26 | 80.90 | 34.49 |
| Wall time (s) | 794.7 | 460.6 | 729.7 | 145.0 |

## Concurrency: 16

| Metric | vllm_metal | llamacpp | mlx_lm | omlx |
|--------|--------|--------|--------|--------|
| Successful / Failed | 87 / 13 | 100 / 0 | 91 / 9 | 100 / 0 |
| TTFT avg (ms) | 15336.9 | 59116.8 | 105716.5 | 10766.2 |
| TTFT p50 (ms) | 7980.6 | 59045.1 | 113195.3 | 11556.5 |
| TTFT p99 (ms) | 65109.5 | 94905.4 | 136582.0 | 18939.2 |
| Throughput avg (tok/s) | 0.9 | 12.6 | 13.0 | 7.9 |
| Output throughput (tok/s) | 9.0 | 20.2 | 5.4 | 61.9 |
| Input throughput (tok/s) | 589.9 | 974.6 | N/A | 3242.6 |
| Total token throughput (tok/s) | 598.9 | 994.8 | N/A | 3304.5 |
| ITL avg (ms) | 1632.9 | 138.1 | 67.4 | 117.9 |
| ITL p50 (ms) | 1357.1 | 111.0 | 47.2 | 117.5 |
| Latency avg (s) | 106.33 | 73.41 | 107.92 | 21.09 |
| Latency p99 (s) | 299.78 | 138.87 | 139.88 | 43.74 |
| Wall time (s) | 737.3 | 476.3 | 729.8 | 142.4 |

## Total Benchmark Duration

| Framework | vllm_metal | llamacpp | mlx_lm | omlx |
|-----------|--------|--------|--------|--------|
| Duration | 51.3m | 29.3m | 37.8m | 13.2m |
