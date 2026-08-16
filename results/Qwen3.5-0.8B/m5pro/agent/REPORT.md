# SiliconBench Results — Qwen3.5-0.8B (agent)

**Model:** Qwen3.5-0.8B
**Split:** agent
**Generated:** 2026-08-16 16:01:29

## Concurrency: 1

| Metric | mlx_lm | vllm_mlx | omlx | vllm_metal | llamacpp |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 391.6 | 399.4 | 480.3 | 545.5 | 436.3 |
| TTFT p50 (ms) | 331.5 | 337.5 | 433.6 | 410.0 | 277.6 |
| TTFT p99 (ms) | 881.2 | 969.4 | 1089.4 | 1419.3 | 2359.0 |
| Throughput avg (tok/s) | 134.8 | 94.2 | 14.3 | 105.7 | 125.1 |
| Output throughput (tok/s) | 79.0 | 67.4 | 76.9 | 53.5 | 70.6 |
| Input throughput (tok/s) | 5631.0 | 3880.8 | 5638.4 | 4423.1 | 4910.9 |
| Total token throughput (tok/s) | 5710.0 | 3948.2 | 5715.3 | 4476.7 | 4981.5 |
| ITL avg (ms) | 7.1 | 10.0 | 76.1 | 9.1 | 7.7 |
| ITL p50 (ms) | 7.0 | 10.0 | 71.8 | 9.1 | 7.6 |
| Latency avg (s) | 0.82 | 1.19 | 0.82 | 1.04 | 0.94 |
| Latency p99 (s) | 2.24 | 3.15 | 2.43 | 3.12 | 3.68 |
| Wall time (s) | 82.0 | 118.6 | 81.9 | 104.4 | 94.0 |

## Concurrency: 8

| Metric | mlx_lm | vllm_mlx | omlx | vllm_metal | llamacpp |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 879.7 | 218.2 | 588.8 | 1381.2 | 2209.6 |
| TTFT p50 (ms) | 655.3 | 212.4 | 510.5 | 1001.4 | 2020.4 |
| TTFT p99 (ms) | 3446.3 | 390.8 | 2079.0 | 5678.1 | 5314.9 |
| Throughput avg (tok/s) | 17.6 | 31.1 | 8.7 | 11.2 | 56.2 |
| Output throughput (tok/s) | 106.1 | 239.8 | 145.3 | 60.9 | 138.6 |
| Input throughput (tok/s) | 7734.2 | 17040.8 | 10795.8 | 5229.1 | 9647.2 |
| Total token throughput (tok/s) | 7840.2 | 17280.6 | 10941.0 | 5290.0 | 9785.9 |
| ITL avg (ms) | 71.7 | 29.2 | 119.6 | 119.3 | 24.1 |
| ITL p50 (ms) | 64.8 | 29.1 | 115.4 | 104.7 | 16.1 |
| Latency avg (s) | 4.62 | 2.10 | 3.28 | 6.95 | 3.74 |
| Latency p99 (s) | 22.05 | 7.95 | 14.36 | 37.82 | 12.08 |
| Wall time (s) | 59.7 | 27.0 | 42.8 | 88.3 | 47.9 |

## Concurrency: 16

| Metric | mlx_lm | vllm_mlx | omlx | vllm_metal | llamacpp |
|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 1850.8 | 394.3 | 3404.5 | 3292.7 | 4960.0 |
| TTFT p50 (ms) | 1223.8 | 375.9 | 3359.3 | 2270.8 | 5233.0 |
| TTFT p99 (ms) | 8083.7 | 682.5 | 5467.1 | 15205.1 | 9126.6 |
| Throughput avg (tok/s) | 8.8 | 17.8 | 8.1 | 6.0 | 59.3 |
| Output throughput (tok/s) | 106.2 | 261.8 | 146.8 | 62.2 | 157.5 |
| Input throughput (tok/s) | 7728.6 | 16281.9 | 10908.9 | 5234.9 | 10962.3 |
| Total token throughput (tok/s) | 7834.8 | 16543.8 | 11055.7 | 5297.1 | 11119.8 |
| ITL avg (ms) | 145.2 | 52.5 | 124.2 | 220.9 | 20.8 |
| ITL p50 (ms) | 125.9 | 52.5 | 119.7 | 211.3 | 15.1 |
| Latency avg (s) | 9.11 | 4.10 | 6.28 | 13.67 | 6.35 |
| Latency p99 (s) | 38.08 | 13.87 | 17.91 | 65.75 | 13.86 |
| Wall time (s) | 59.7 | 28.3 | 42.3 | 88.2 | 42.1 |

## Total Benchmark Duration

| Framework | mlx_lm | vllm_mlx | omlx | vllm_metal | llamacpp |
|-----------|--------|--------|--------|--------|--------|
| Duration | 3.5m | 3.0m | 2.9m | 4.8m | 3.2m |
