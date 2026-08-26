# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-08-25 21:21:42

## Concurrency: 1

| Metric | llamacpp | mlx_lm | vllm_mlx | omlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 56 / 44 | 94 / 6 | 94 / 6 | 93 / 7 |
| TTFT avg (ms) | 1669.7 | 1000.7 | 1238.7 | 873.2 | 713.2 |
| TTFT p50 (ms) | 1207.6 | 825.5 | 1133.5 | 717.2 | 551.3 |
| TTFT p99 (ms) | 6270.2 | 2608.0 | 2844.5 | 2598.7 | 3069.3 |
| Throughput avg (tok/s) | 25.5 | 25.4 | 25.4 | 27.4 | 22.3 |
| Output throughput (tok/s) | 18.3 | 17.5 | 19.4 | 21.6 | 21.1 |
| Input throughput (tok/s) | 878.3 | 471.8 | 991.6 | 1109.7 | 1048.0 |
| Total token throughput (tok/s) | 896.6 | 489.3 | 1011.1 | 1131.3 | 1069.1 |
| ITL avg (ms) | 38.0 | 38.9 | 37.8 | 36.5 | 43.0 |
| ITL p50 (ms) | 37.9 | 38.7 | 37.7 | 36.1 | 41.4 |
| Latency avg (s) | 5.29 | 6.35 | 4.69 | 4.20 | 4.44 |
| Latency p99 (s) | 12.21 | 11.55 | 11.14 | 10.93 | 11.98 |
| Wall time (s) | 528.7 | 446.0 | 446.3 | 398.7 | 416.9 |

## Concurrency: 8

| Metric | llamacpp | mlx_lm | vllm_mlx | omlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 56 / 44 | 94 / 6 | 94 / 6 | 93 / 7 |
| TTFT avg (ms) | 9629.6 | 3356.3 | 2751.0 | 2907.6 | 1135.6 |
| TTFT p50 (ms) | 9381.7 | 2592.6 | 2232.2 | 2024.3 | 904.9 |
| TTFT p99 (ms) | 20984.1 | 13967.5 | 10121.9 | 10106.0 | 3176.7 |
| Throughput avg (tok/s) | 15.3 | 4.8 | 8.8 | 7.9 | 6.9 |
| Output throughput (tok/s) | 44.2 | 23.4 | 46.7 | 48.3 | 52.3 |
| Input throughput (tok/s) | 2122.9 | 633.3 | 2415.7 | 2525.3 | 2644.0 |
| Total token throughput (tok/s) | 2167.1 | 656.7 | 2462.4 | 2573.6 | 2696.3 |
| ITL avg (ms) | 85.2 | 247.2 | 127.3 | 126.8 | 152.2 |
| ITL p50 (ms) | 59.1 | 275.2 | 124.5 | 124.3 | 135.9 |
| Latency avg (s) | 16.83 | 38.49 | 15.18 | 14.30 | 13.74 |
| Latency p99 (s) | 44.17 | 94.09 | 57.11 | 44.76 | 42.25 |
| Wall time (s) | 218.7 | 332.3 | 183.2 | 175.2 | 165.3 |

## Concurrency: 16

| Metric | llamacpp | mlx_lm | vllm_mlx | omlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 56 / 44 | 94 / 6 | 94 / 6 | 93 / 7 |
| TTFT avg (ms) | 28325.5 | 7608.8 | 5221.8 | 14692.7 | 1888.7 |
| TTFT p50 (ms) | 30180.2 | 4401.7 | 2740.4 | 15051.1 | 1490.6 |
| TTFT p99 (ms) | 41201.0 | 31487.0 | 23104.0 | 21903.1 | 5877.8 |
| Throughput avg (tok/s) | 14.5 | 2.1 | 4.4 | 7.6 | 4.2 |
| Output throughput (tok/s) | 40.2 | 21.8 | 49.4 | 50.4 | 63.6 |
| Input throughput (tok/s) | 1932.1 | 598.6 | 2573.2 | 2572.5 | 3204.2 |
| Total token throughput (tok/s) | 1972.4 | 620.4 | 2622.7 | 2622.8 | 3267.8 |
| ITL avg (ms) | 83.0 | 506.2 | 289.4 | 131.3 | 249.1 |
| ITL p50 (ms) | 67.8 | 511.4 | 243.3 | 135.4 | 227.2 |
| Latency avg (s) | 36.12 | 75.87 | 27.77 | 26.88 | 21.66 |
| Latency p99 (s) | 60.17 | 165.16 | 92.22 | 59.38 | 63.31 |
| Wall time (s) | 240.3 | 351.5 | 172.0 | 172.0 | 136.4 |

## Total Benchmark Duration

| Framework | llamacpp | mlx_lm | vllm_mlx | omlx | vllm_metal |
|-----------|--------|--------|--------|--------|--------|
| Duration | 17.0m | 19.3m | 13.7m | 13.0m | 12.3m |
