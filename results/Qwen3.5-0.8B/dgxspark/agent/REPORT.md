# SiliconBench Results — Qwen3.5-0.8B (agent)

**Model:** Qwen3.5-0.8B
**Split:** agent
**Generated:** 2026-07-04 00:51:08

## Concurrency: 1

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 199.6 | 232.2 | 321.6 |
| TTFT p50 (ms) | 177.0 | 215.9 | 266.5 |
| TTFT p99 (ms) | 498.1 | 535.3 | 914.8 |
| Throughput avg (tok/s) | 99.7 | 95.2 | 117.8 |
| Output throughput (tok/s) | 79.4 | 73.4 | 76.6 |
| Input throughput (tok/s) | 5689.8 | 5369.8 | 5512.4 |
| Total token throughput (tok/s) | 5769.2 | 5443.2 | 5589.0 |
| ITL avg (ms) | 9.7 | 10.1 | 8.2 |
| ITL p50 (ms) | 9.6 | 10.1 | 8.2 |
| Latency avg (s) | 0.81 | 0.86 | 0.84 |
| Latency p99 (s) | 2.82 | 3.01 | 2.65 |
| Wall time (s) | 81.1 | 86.0 | 83.8 |

## Concurrency: 8

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 137.6 | 416.7 | 2113.4 |
| TTFT p50 (ms) | 121.3 | 361.7 | 2132.1 |
| TTFT p99 (ms) | 348.2 | 1634.1 | 3571.1 |
| Throughput avg (tok/s) | 60.0 | 38.5 | 52.2 |
| Output throughput (tok/s) | 396.4 | 223.9 | 139.3 |
| Input throughput (tok/s) | 28901.0 | 16326.8 | 10281.4 |
| Total token throughput (tok/s) | 29297.4 | 16550.7 | 10420.7 |
| ITL avg (ms) | 17.3 | 30.3 | 21.4 |
| ITL p50 (ms) | 16.4 | 26.8 | 18.5 |
| Latency avg (s) | 1.18 | 2.15 | 3.49 |
| Latency p99 (s) | 5.52 | 10.40 | 9.81 |
| Wall time (s) | 16.0 | 28.3 | 44.9 |

## Concurrency: 16

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 115.0 | 807.2 | 5082.9 |
| TTFT p50 (ms) | 66.1 | 550.7 | 5388.2 |
| TTFT p99 (ms) | 351.9 | 3766.4 | 7608.0 |
| Throughput avg (tok/s) | 54.5 | 21.8 | 53.2 |
| Output throughput (tok/s) | 684.1 | 248.5 | 148.9 |
| Input throughput (tok/s) | 51032.4 | 17271.9 | 10890.4 |
| Total token throughput (tok/s) | 51716.5 | 17520.4 | 11039.3 |
| ITL avg (ms) | 18.2 | 56.1 | 20.4 |
| ITL p50 (ms) | 17.6 | 55.9 | 17.6 |
| Latency avg (s) | 1.18 | 3.99 | 6.38 |
| Latency p99 (s) | 5.13 | 15.95 | 12.87 |
| Wall time (s) | 9.0 | 26.7 | 42.4 |

## Total Benchmark Duration

| Framework | sglang | vllm | llamacpp |
|-----------|--------|--------|--------|
| Duration | 1.9m | 2.5m | 3.0m |
