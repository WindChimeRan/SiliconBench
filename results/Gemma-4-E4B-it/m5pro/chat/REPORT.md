# SiliconBench Results — Gemma-4-E4B-it (chat)

**Model:** Gemma-4-E4B-it
**Split:** chat
**Generated:** 2026-08-16 16:01:29

## Concurrency: 1

| Metric | vllm_metal | mlx_lm | llamacpp | hf_transformers | vllm_mlx |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 349.9 | 393.3 | 436.5 | 833.8 | 311.6 |
| TTFT p50 (ms) | 198.4 | 240.7 | 276.5 | 324.7 | 229.6 |
| TTFT p99 (ms) | 1613.2 | 1466.0 | 1926.6 | 4013.4 | 1316.6 |
| Throughput avg (tok/s) | 23.0 | 24.6 | 24.4 | 15.5 | 24.2 |
| Output throughput (tok/s) | 22.5 | 23.9 | 23.0 | 14.1 | 24.3 |
| Input throughput (tok/s) | 291.0 | 302.9 | 296.0 | 175.2 | 328.9 |
| Total token throughput (tok/s) | 313.5 | 326.7 | 319.0 | 189.3 | 353.1 |
| ITL avg (ms) | 40.5 | 37.3 | 38.1 | 60.6 | 37.4 |
| ITL p50 (ms) | 40.1 | 37.2 | 38.2 | 58.9 | 37.3 |
| Latency avg (s) | 3.39 | 3.26 | 3.34 | 5.63 | 3.00 |
| Latency p99 (s) | 11.39 | 11.09 | 10.38 | 20.06 | 9.93 |
| Wall time (s) | 339.2 | 326.0 | 333.6 | 563.5 | 300.2 |

## Concurrency: 8

| Metric | vllm_metal | mlx_lm | llamacpp | hf_transformers | vllm_mlx |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 265.3 | 1323.6 | 3625.0 | 35903.1 | 532.4 |
| TTFT p50 (ms) | 265.7 | 647.0 | 3349.6 | 34911.4 | 539.6 |
| TTFT p99 (ms) | 337.6 | 6760.4 | 8074.1 | 66550.5 | 686.9 |
| Throughput avg (tok/s) | 11.7 | 9.2 | 20.0 | 15.9 | 9.8 |
| Output throughput (tok/s) | 91.2 | 62.8 | 77.2 | 14.8 | 83.0 |
| Input throughput (tok/s) | 1157.4 | 801.1 | 991.5 | 184.3 | 1290.9 |
| Total token throughput (tok/s) | 1248.5 | 863.9 | 1068.6 | 199.1 | 1373.9 |
| ITL avg (ms) | 79.1 | 103.6 | 47.4 | 58.6 | 80.1 |
| ITL p50 (ms) | 79.6 | 103.4 | 45.7 | 56.6 | 80.8 |
| Latency avg (s) | 6.32 | 9.39 | 7.22 | 40.55 | 5.64 |
| Latency p99 (s) | 20.94 | 31.67 | 21.65 | 74.36 | 21.52 |
| Wall time (s) | 85.3 | 123.2 | 99.6 | 535.6 | 76.5 |

## Concurrency: 16

| Metric | vllm_metal | mlx_lm | llamacpp | hf_transformers | vllm_mlx |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 298.7 | 2106.7 | 9804.5 | 69475.0 | 675.3 |
| TTFT p50 (ms) | 289.0 | 1208.9 | 10383.8 | 74253.6 | 663.5 |
| TTFT p99 (ms) | 368.1 | 8247.6 | 16335.1 | 110350.7 | 987.9 |
| Throughput avg (tok/s) | 10.5 | 6.4 | 20.0 | 16.4 | 8.3 |
| Output throughput (tok/s) | 146.5 | 83.0 | 80.2 | 15.3 | 124.2 |
| Input throughput (tok/s) | 1856.2 | 1055.7 | 1030.7 | 190.3 | 1932.1 |
| Total token throughput (tok/s) | 2002.6 | 1138.7 | 1111.0 | 205.6 | 2056.3 |
| ITL avg (ms) | 88.5 | 211.6 | 46.9 | 56.9 | 95.8 |
| ITL p50 (ms) | 89.0 | 160.1 | 46.0 | 54.6 | 97.5 |
| Latency avg (s) | 7.06 | 13.60 | 13.32 | 73.98 | 6.61 |
| Latency p99 (s) | 23.64 | 42.71 | 28.21 | 113.60 | 24.88 |
| Wall time (s) | 53.2 | 93.5 | 95.8 | 518.9 | 51.1 |

## Total Benchmark Duration

| Framework | vllm_metal | mlx_lm | llamacpp | hf_transformers | vllm_mlx |
|-----------|--------|--------|--------|--------|--------|
| Duration | 8.3m | 9.4m | 9.1m | 27.6m | 7.4m |
