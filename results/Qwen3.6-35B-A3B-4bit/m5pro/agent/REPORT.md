# SiliconBench Results — Qwen3.6-35B-A3B-4bit (agent)

**Model:** Qwen3.6-35B-A3B-4bit
**Split:** agent
**Generated:** 2026-09-03 17:19:50

## Concurrency: 1

| Metric | llamacpp | mlx_lm | vllm_metal | omlx | omlx_bounded |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 99 / 1 | 38 / 62 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 2523.7 | 1832.1 | 1567.8 | 1801.3 | 1948.7 |
| TTFT p50 (ms) | 1885.6 | 1631.6 | 1303.0 | 1501.1 | 1584.2 |
| TTFT p99 (ms) | 8108.6 | 4519.6 | 6043.7 | 4089.6 | 4037.3 |
| Throughput avg (tok/s) | 60.3 | 91.8 | 67.3 | 115.2 | 118.0 |
| Output throughput (tok/s) | 21.1 | 19.7 | 28.3 | 30.6 | 29.0 |
| Input throughput (tok/s) | 1198.4 | 520.9 | 1709.8 | 1889.9 | 1792.3 |
| Total token throughput (tok/s) | 1219.5 | 540.6 | 1738.1 | 1920.5 | 1821.3 |
| ITL avg (ms) | 16.6 | 10.9 | 14.9 | 8.7 | 8.5 |
| ITL p50 (ms) | 16.4 | 11.8 | 14.8 | 7.5 | 6.9 |
| Latency avg (s) | 3.88 | 3.61 | 2.70 | 2.44 | 2.58 |
| Latency p99 (s) | 10.04 | 5.83 | 7.05 | 5.25 | 5.20 |
| Wall time (s) | 383.7 | 286.8 | 270.1 | 244.3 | 257.6 |

## Concurrency: 2

| Metric | llamacpp | mlx_lm | vllm_metal | omlx | omlx_bounded |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 99 / 1 | 40 / 60 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 2717.9 | 3099.4 | 1772.5 | 3484.8 | 3297.0 |
| TTFT p50 (ms) | 1956.0 | 2333.6 | 1395.0 | 3217.0 | 3093.2 |
| TTFT p99 (ms) | 12350.1 | 8377.8 | 6113.5 | 8590.0 | 8726.5 |
| Throughput avg (tok/s) | 17.0 | 36.3 | 26.6 | 37.5 | 40.1 |
| Output throughput (tok/s) | 21.6 | 23.5 | 32.6 | 27.4 | 29.6 |
| Input throughput (tok/s) | 1249.5 | 574.3 | 2014.3 | 1654.3 | 1765.7 |
| Total token throughput (tok/s) | 1271.2 | 597.8 | 2046.9 | 1681.8 | 1795.3 |
| ITL avg (ms) | 58.7 | 27.6 | 37.6 | 26.7 | 24.9 |
| ITL p50 (ms) | 34.8 | 21.6 | 21.0 | 26.0 | 18.1 |
| Latency avg (s) | 7.42 | 8.22 | 4.58 | 5.57 | 5.22 |
| Latency p99 (s) | 39.38 | 19.42 | 24.67 | 12.26 | 12.71 |
| Wall time (s) | 368.0 | 280.9 | 229.2 | 279.1 | 261.5 |

## Concurrency: 4

| Metric | llamacpp | mlx_lm | vllm_metal | omlx | omlx_bounded |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 99 / 1 | 38 / 62 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 3060.1 | 3954.5 | 1984.4 | 6778.3 | 6423.0 |
| TTFT p50 (ms) | 2278.5 | 3100.5 | 1636.2 | 6820.2 | 5933.1 |
| TTFT p99 (ms) | 10241.7 | 10126.6 | 7052.5 | 14203.7 | 14835.3 |
| Throughput avg (tok/s) | 8.4 | 14.0 | 11.6 | 20.9 | 21.2 |
| Output throughput (tok/s) | 25.3 | 23.5 | 35.3 | 30.1 | 30.3 |
| Input throughput (tok/s) | 1462.1 | 627.2 | 2174.1 | 1711.5 | 1820.6 |
| Total token throughput (tok/s) | 1487.4 | 650.7 | 2209.4 | 1741.6 | 1851.0 |
| ITL avg (ms) | 119.6 | 71.5 | 86.4 | 47.8 | 47.1 |
| ITL p50 (ms) | 88.9 | 67.0 | 71.7 | 47.9 | 46.0 |
| Latency avg (s) | 12.63 | 16.65 | 8.46 | 10.76 | 10.12 |
| Latency p99 (s) | 53.97 | 35.58 | 35.31 | 25.64 | 25.06 |
| Wall time (s) | 314.5 | 255.2 | 212.4 | 269.8 | 253.6 |

## Total Benchmark Duration

| Framework | llamacpp | mlx_lm | vllm_metal | omlx | omlx_bounded |
|-----------|--------|--------|--------|--------|--------|
| Duration | 18.5m | 14.3m | 12.6m | 13.9m | 13.5m |
