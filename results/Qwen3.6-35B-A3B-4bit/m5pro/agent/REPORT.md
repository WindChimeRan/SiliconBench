# SiliconBench Results — Qwen3.6-35B-A3B-4bit (agent)

**Model:** Qwen3.6-35B-A3B-4bit
**Split:** agent
**Generated:** 2026-09-03 20:30:46

## Concurrency: 1

| Metric | omlx_ram | llamacpp | mlx_lm | vllm_metal | omlx |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 99 / 1 | 38 / 62 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 1561.6 | 2523.7 | 1832.1 | 1567.8 | 1801.3 |
| TTFT p50 (ms) | 1369.6 | 1885.6 | 1631.6 | 1303.0 | 1501.1 |
| TTFT p99 (ms) | 4270.7 | 8108.6 | 4519.6 | 6043.7 | 4089.6 |
| Throughput avg (tok/s) | 113.1 | 60.3 | 91.8 | 67.3 | 115.2 |
| Output throughput (tok/s) | 33.7 | 21.1 | 19.7 | 28.3 | 30.6 |
| Input throughput (tok/s) | 2082.7 | 1198.4 | 520.9 | 1709.8 | 1889.9 |
| Total token throughput (tok/s) | 2116.4 | 1219.5 | 540.6 | 1738.1 | 1920.5 |
| ITL avg (ms) | 8.8 | 16.6 | 10.9 | 14.9 | 8.7 |
| ITL p50 (ms) | 6.7 | 16.4 | 11.8 | 14.8 | 7.5 |
| Latency avg (s) | 2.22 | 3.88 | 3.61 | 2.70 | 2.44 |
| Latency p99 (s) | 5.08 | 10.04 | 5.83 | 7.05 | 5.25 |
| Wall time (s) | 221.7 | 383.7 | 286.8 | 270.1 | 244.3 |

## Concurrency: 2

| Metric | omlx_ram | llamacpp | mlx_lm | vllm_metal | omlx |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 99 / 1 | 40 / 60 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 2665.1 | 2717.9 | 3099.4 | 1772.5 | 3484.8 |
| TTFT p50 (ms) | 2394.7 | 1956.0 | 2333.6 | 1395.0 | 3217.0 |
| TTFT p99 (ms) | 7326.5 | 12350.1 | 8377.8 | 6113.5 | 8590.0 |
| Throughput avg (tok/s) | 39.5 | 17.0 | 36.3 | 26.6 | 37.5 |
| Output throughput (tok/s) | 33.1 | 21.6 | 23.5 | 32.6 | 27.4 |
| Input throughput (tok/s) | 1974.5 | 1249.5 | 574.3 | 2014.3 | 1654.3 |
| Total token throughput (tok/s) | 2007.6 | 1271.2 | 597.8 | 2046.9 | 1681.8 |
| ITL avg (ms) | 25.3 | 58.7 | 27.6 | 37.6 | 26.7 |
| ITL p50 (ms) | 23.2 | 34.8 | 21.6 | 21.0 | 26.0 |
| Latency avg (s) | 4.67 | 7.42 | 8.22 | 4.58 | 5.57 |
| Latency p99 (s) | 11.41 | 39.38 | 19.42 | 24.67 | 12.26 |
| Wall time (s) | 233.9 | 368.0 | 280.9 | 229.2 | 279.1 |

## Concurrency: 4

| Metric | omlx_ram | llamacpp | mlx_lm | vllm_metal | omlx |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 99 / 1 | 38 / 62 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 4880.0 | 3060.1 | 3954.5 | 1984.4 | 6778.3 |
| TTFT p50 (ms) | 4480.1 | 2278.5 | 3100.5 | 1636.2 | 6820.2 |
| TTFT p99 (ms) | 15928.1 | 10241.7 | 10126.6 | 7052.5 | 14203.7 |
| Throughput avg (tok/s) | 20.2 | 8.4 | 14.0 | 11.6 | 20.9 |
| Output throughput (tok/s) | 33.9 | 25.3 | 23.5 | 35.3 | 30.1 |
| Input throughput (tok/s) | 2149.9 | 1462.1 | 627.2 | 2174.1 | 1711.5 |
| Total token throughput (tok/s) | 2183.8 | 1487.4 | 650.7 | 2209.4 | 1741.6 |
| ITL avg (ms) | 49.6 | 119.6 | 71.5 | 86.4 | 47.8 |
| ITL p50 (ms) | 50.3 | 88.9 | 67.0 | 71.7 | 47.9 |
| Latency avg (s) | 8.57 | 12.63 | 16.65 | 8.46 | 10.76 |
| Latency p99 (s) | 21.94 | 53.97 | 35.58 | 35.31 | 25.64 |
| Wall time (s) | 214.8 | 314.5 | 255.2 | 212.4 | 269.8 |

## Total Benchmark Duration

| Framework | omlx_ram | llamacpp | mlx_lm | vllm_metal | omlx |
|-----------|--------|--------|--------|--------|--------|
| Duration | 11.9m | 18.5m | 14.3m | 12.6m | 13.9m |
