# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-08-22 07:54:38

## Concurrency: 1

| Metric | llamacpp | mlx_lm | vllm_mlx | omlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 56 / 44 | 94 / 6 | 94 / 6 | 93 / 7 |
| TTFT avg (ms) | 1669.7 | 1000.7 | 1238.7 | 896.7 | 713.2 |
| TTFT p50 (ms) | 1207.6 | 825.5 | 1133.5 | 744.6 | 551.3 |
| TTFT p99 (ms) | 6270.2 | 2608.0 | 2844.5 | 2640.9 | 3069.3 |
| Throughput avg (tok/s) | 25.5 | 25.4 | 25.4 | 6.6 | 22.3 |
| Output throughput (tok/s) | 18.3 | 17.5 | 19.4 | 21.4 | 21.1 |
| Input throughput (tok/s) | 878.3 | 471.8 | 991.6 | 1098.0 | 1048.0 |
| Total token throughput (tok/s) | 896.6 | 489.3 | 1011.1 | 1119.4 | 1069.1 |
| ITL avg (ms) | 38.0 | 38.9 | 37.8 | 149.7 | 43.0 |
| ITL p50 (ms) | 37.9 | 38.7 | 37.7 | 149.7 | 41.4 |
| Latency avg (s) | 5.29 | 6.35 | 4.69 | 4.25 | 4.44 |
| Latency p99 (s) | 12.21 | 11.55 | 11.14 | 11.04 | 11.98 |
| Wall time (s) | 528.7 | 446.0 | 446.3 | 403.0 | 416.9 |

## Concurrency: 8

| Metric | llamacpp | mlx_lm | vllm_mlx | omlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 56 / 44 | 94 / 6 | 94 / 6 | 93 / 7 |
| TTFT avg (ms) | 9629.6 | 3356.3 | 2751.0 | 902.3 | 1135.6 |
| TTFT p50 (ms) | 9381.7 | 2592.6 | 2232.2 | 744.0 | 904.9 |
| TTFT p99 (ms) | 20984.1 | 13967.5 | 10121.9 | 2588.6 | 3176.7 |
| Throughput avg (tok/s) | 15.3 | 4.8 | 8.8 | 5.2 | 6.9 |
| Output throughput (tok/s) | 44.2 | 23.4 | 46.7 | 72.0 | 52.3 |
| Input throughput (tok/s) | 2122.9 | 633.3 | 2415.7 | 3694.7 | 2644.0 |
| Total token throughput (tok/s) | 2167.1 | 656.7 | 2462.4 | 3766.8 | 2696.3 |
| ITL avg (ms) | 85.2 | 247.2 | 127.3 | 188.6 | 152.2 |
| ITL p50 (ms) | 59.1 | 275.2 | 124.5 | 190.3 | 135.9 |
| Latency avg (s) | 16.83 | 38.49 | 15.18 | 9.62 | 13.74 |
| Latency p99 (s) | 44.17 | 94.09 | 57.11 | 28.34 | 42.25 |
| Wall time (s) | 218.7 | 332.3 | 183.2 | 119.8 | 165.3 |

## Concurrency: 16

| Metric | llamacpp | mlx_lm | vllm_mlx | omlx | vllm_metal |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 56 / 44 | 94 / 6 | 94 / 6 | 93 / 7 |
| TTFT avg (ms) | 28325.5 | 7608.8 | 5221.8 | 8717.4 | 1888.7 |
| TTFT p50 (ms) | 30180.2 | 4401.7 | 2740.4 | 9282.8 | 1490.6 |
| TTFT p99 (ms) | 41201.0 | 31487.0 | 23104.0 | 12914.1 | 5877.8 |
| Throughput avg (tok/s) | 14.5 | 2.1 | 4.4 | 5.0 | 4.2 |
| Output throughput (tok/s) | 40.2 | 21.8 | 49.4 | 74.4 | 63.6 |
| Input throughput (tok/s) | 1932.1 | 598.6 | 2573.2 | 3818.5 | 3204.2 |
| Total token throughput (tok/s) | 1972.4 | 620.4 | 2622.7 | 3892.9 | 3267.8 |
| ITL avg (ms) | 83.0 | 506.2 | 289.4 | 194.9 | 249.1 |
| ITL p50 (ms) | 67.8 | 511.4 | 243.3 | 192.9 | 227.2 |
| Latency avg (s) | 36.12 | 75.87 | 27.77 | 17.59 | 21.66 |
| Latency p99 (s) | 60.17 | 165.16 | 92.22 | 36.66 | 63.31 |
| Wall time (s) | 240.3 | 351.5 | 172.0 | 115.9 | 136.4 |

## Total Benchmark Duration

| Framework | llamacpp | mlx_lm | vllm_mlx | omlx | vllm_metal |
|-----------|--------|--------|--------|--------|--------|
| Duration | 17.0m | 19.3m | 13.7m | 11.0m | 12.3m |
