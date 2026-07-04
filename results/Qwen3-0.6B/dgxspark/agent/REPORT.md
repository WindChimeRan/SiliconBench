# SiliconBench Results — Qwen3-0.6B (agent)

**Model:** Qwen3-0.6B
**Split:** agent
**Generated:** 2026-07-04 00:34:02

## Concurrency: 1

| Metric | llamacpp | vllm | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 413.9 | 103.3 | 91.3 |
| TTFT p50 (ms) | 364.8 | 77.9 | 67.2 |
| TTFT p99 (ms) | 946.7 | 366.6 | 380.2 |
| Throughput avg (tok/s) | 115.8 | 89.3 | 89.3 |
| Output throughput (tok/s) | 66.5 | 80.2 | 82.6 |
| Input throughput (tok/s) | 4644.3 | 5786.5 | 5412.3 |
| Total token throughput (tok/s) | 4710.8 | 5866.7 | 5494.9 |
| ITL avg (ms) | 8.5 | 10.9 | 11.0 |
| ITL p50 (ms) | 8.3 | 10.7 | 10.9 |
| Latency avg (s) | 0.92 | 0.74 | 0.79 |
| Latency p99 (s) | 2.91 | 3.26 | 3.25 |
| Wall time (s) | 91.9 | 73.7 | 78.8 |

## Concurrency: 8

| Metric | llamacpp | vllm | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 3726.6 | 85.4 | 60.9 |
| TTFT p50 (ms) | 3779.0 | 84.6 | 58.5 |
| TTFT p99 (ms) | 7177.5 | 123.1 | 108.3 |
| Throughput avg (tok/s) | 27.5 | 39.9 | 42.1 |
| Output throughput (tok/s) | 77.6 | 294.1 | 323.5 |
| Input throughput (tok/s) | 5576.1 | 20059.6 | 22944.5 |
| Total token throughput (tok/s) | 5653.8 | 20353.7 | 23268.0 |
| ITL avg (ms) | 39.8 | 24.9 | 23.5 |
| ITL p50 (ms) | 37.5 | 25.2 | 23.3 |
| Latency avg (s) | 6.06 | 1.56 | 1.41 |
| Latency p99 (s) | 17.61 | 6.62 | 6.22 |
| Wall time (s) | 76.5 | 21.3 | 18.6 |

## Concurrency: 16

| Metric | llamacpp | vllm | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 9701.0 | 147.1 | 92.5 |
| TTFT p50 (ms) | 10149.4 | 133.9 | 83.7 |
| TTFT p99 (ms) | 17037.4 | 270.8 | 187.9 |
| Throughput avg (tok/s) | 26.2 | 24.6 | 26.7 |
| Output throughput (tok/s) | 75.3 | 342.7 | 384.1 |
| Input throughput (tok/s) | 5377.2 | 24807.2 | 26219.2 |
| Total token throughput (tok/s) | 5452.5 | 25149.8 | 26603.3 |
| ITL avg (ms) | 42.8 | 40.0 | 36.9 |
| ITL p50 (ms) | 41.5 | 39.5 | 36.9 |
| Latency avg (s) | 12.16 | 2.39 | 2.27 |
| Latency p99 (s) | 24.03 | 10.31 | 9.49 |
| Wall time (s) | 79.4 | 17.2 | 16.3 |

## Total Benchmark Duration

| Framework | llamacpp | vllm | sglang |
|-----------|--------|--------|--------|
| Duration | 4.3m | 2.0m | 2.0m |
