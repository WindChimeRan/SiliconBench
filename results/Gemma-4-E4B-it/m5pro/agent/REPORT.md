# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-08-25 14:14:35

## Concurrency: 1

| Metric | llamacpp | omlx | mlx_lm | vllm_mlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 94 / 6 | 56 / 44 | 94 / 6 | 93 / 7 |
| TTFT avg (ms) | 1669.7 | 992.9 | 1000.7 | 1238.7 | 713.2 |
| TTFT p50 (ms) | 1207.6 | 839.4 | 825.5 | 1133.5 | 551.3 |
| TTFT p99 (ms) | 6270.2 | 3125.7 | 2608.0 | 2844.5 | 3069.3 |
| Throughput avg (tok/s) | 25.5 | 28.7 | 25.4 | 25.4 | 22.3 |
| Output throughput (tok/s) | 18.3 | 21.3 | 17.5 | 19.4 | 21.1 |
| Input throughput (tok/s) | 878.3 | 1092.1 | 471.8 | 991.6 | 1048.0 |
| Total token throughput (tok/s) | 896.6 | 1113.4 | 489.3 | 1011.1 | 1069.1 |
| ITL avg (ms) | 38.0 | 34.6 | 38.9 | 37.8 | 43.0 |
| ITL p50 (ms) | 37.9 | 35.3 | 38.7 | 37.7 | 41.4 |
| Latency avg (s) | 5.29 | 4.27 | 6.35 | 4.69 | 4.44 |
| Latency p99 (s) | 12.21 | 11.31 | 11.55 | 11.14 | 11.98 |
| Wall time (s) | 528.7 | 405.1 | 446.0 | 446.3 | 416.9 |

## Concurrency: 8

| Metric | llamacpp | omlx | mlx_lm | vllm_mlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 94 / 6 | 56 / 44 | 94 / 6 | 93 / 7 |
| TTFT avg (ms) | 9629.6 | 2682.2 | 3356.3 | 2751.0 | 1135.6 |
| TTFT p50 (ms) | 9381.7 | 2003.3 | 2592.6 | 2232.2 | 904.9 |
| TTFT p99 (ms) | 20984.1 | 9535.7 | 13967.5 | 10121.9 | 3176.7 |
| Throughput avg (tok/s) | 15.3 | 8.1 | 4.8 | 8.8 | 6.9 |
| Output throughput (tok/s) | 44.2 | 48.8 | 23.4 | 46.7 | 52.3 |
| Input throughput (tok/s) | 2122.9 | 2505.3 | 633.3 | 2415.7 | 2644.0 |
| Total token throughput (tok/s) | 2167.1 | 2554.1 | 656.7 | 2462.4 | 2696.3 |
| ITL avg (ms) | 85.2 | 127.7 | 247.2 | 127.3 | 152.2 |
| ITL p50 (ms) | 59.1 | 122.9 | 275.2 | 124.5 | 135.9 |
| Latency avg (s) | 16.83 | 14.28 | 38.49 | 15.18 | 13.74 |
| Latency p99 (s) | 44.17 | 43.12 | 94.09 | 57.11 | 42.25 |
| Wall time (s) | 218.7 | 176.6 | 332.3 | 183.2 | 165.3 |

## Concurrency: 16

| Metric | llamacpp | omlx | mlx_lm | vllm_mlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 94 / 6 | 56 / 44 | 94 / 6 | 93 / 7 |
| TTFT avg (ms) | 28325.5 | 14384.5 | 7608.8 | 5221.8 | 1888.7 |
| TTFT p50 (ms) | 30180.2 | 14496.2 | 4401.7 | 2740.4 | 1490.6 |
| TTFT p99 (ms) | 41201.0 | 22359.5 | 31487.0 | 23104.0 | 5877.8 |
| Throughput avg (tok/s) | 14.5 | 7.8 | 2.1 | 4.4 | 4.2 |
| Output throughput (tok/s) | 40.2 | 51.0 | 21.8 | 49.4 | 63.6 |
| Input throughput (tok/s) | 1932.1 | 2607.7 | 598.6 | 2573.2 | 3204.2 |
| Total token throughput (tok/s) | 1972.4 | 2658.7 | 620.4 | 2622.7 | 3267.8 |
| ITL avg (ms) | 83.0 | 129.7 | 506.2 | 289.4 | 249.1 |
| ITL p50 (ms) | 67.8 | 131.4 | 511.4 | 243.3 | 227.2 |
| Latency avg (s) | 36.12 | 26.31 | 75.87 | 27.77 | 21.66 |
| Latency p99 (s) | 60.17 | 53.16 | 165.16 | 92.22 | 63.31 |
| Wall time (s) | 240.3 | 169.7 | 351.5 | 172.0 | 136.4 |

## Total Benchmark Duration

| Framework | llamacpp | omlx | mlx_lm | vllm_mlx | vllm_metal |
|-----------|--------|--------|--------|--------|--------|
| Duration | 17.0m | 13.1m | 19.3m | 13.7m | 12.3m |
