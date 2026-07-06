# SiliconBench Results — Qwen3-0.6B (agent)

**Model:** Qwen3-0.6B
**Split:** agent
**Generated:** 2026-07-05 23:00:19

## Concurrency: 1

| Metric | llamacpp | vllm | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 553.8 | 103.3 | 91.3 |
| TTFT p50 (ms) | 510.5 | 77.9 | 67.2 |
| TTFT p99 (ms) | 1432.0 | 366.6 | 380.2 |
| Throughput avg (tok/s) | 113.2 | 89.3 | 89.3 |
| Output throughput (tok/s) | 55.3 | 80.2 | 82.6 |
| Input throughput (tok/s) | 4077.4 | 5786.5 | 5412.3 |
| Total token throughput (tok/s) | 4132.7 | 5866.7 | 5494.9 |
| ITL avg (ms) | 8.7 | 10.9 | 11.0 |
| ITL p50 (ms) | 8.4 | 10.7 | 10.9 |
| Latency avg (s) | 1.05 | 0.74 | 0.79 |
| Latency p99 (s) | 3.32 | 3.26 | 3.25 |
| Wall time (s) | 104.7 | 73.7 | 78.8 |

## Concurrency: 8

| Metric | llamacpp | vllm | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 1256.8 | 85.4 | 60.9 |
| TTFT p50 (ms) | 1181.0 | 84.6 | 58.5 |
| TTFT p99 (ms) | 2979.8 | 123.1 | 108.3 |
| Throughput avg (tok/s) | 11.0 | 39.9 | 42.1 |
| Output throughput (tok/s) | 70.2 | 294.1 | 323.5 |
| Input throughput (tok/s) | 5080.0 | 20059.6 | 22944.5 |
| Total token throughput (tok/s) | 5150.3 | 20353.7 | 23268.0 |
| ITL avg (ms) | 95.5 | 24.9 | 23.5 |
| ITL p50 (ms) | 94.6 | 25.2 | 23.3 |
| Latency avg (s) | 6.61 | 1.56 | 1.41 |
| Latency p99 (s) | 28.43 | 6.62 | 6.22 |
| Wall time (s) | 84.0 | 21.3 | 18.6 |

## Concurrency: 16

| Metric | llamacpp | vllm | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 2164.6 | 147.1 | 92.5 |
| TTFT p50 (ms) | 1898.1 | 133.9 | 83.7 |
| TTFT p99 (ms) | 5115.8 | 270.8 | 187.9 |
| Throughput avg (tok/s) | 6.2 | 24.6 | 26.7 |
| Output throughput (tok/s) | 79.7 | 342.7 | 384.1 |
| Input throughput (tok/s) | 5743.9 | 24807.2 | 26219.2 |
| Total token throughput (tok/s) | 5823.7 | 25149.8 | 26603.3 |
| ITL avg (ms) | 169.0 | 40.0 | 36.9 |
| ITL p50 (ms) | 166.1 | 39.5 | 36.9 |
| Latency avg (s) | 11.51 | 2.39 | 2.27 |
| Latency p99 (s) | 44.18 | 10.31 | 9.49 |
| Wall time (s) | 74.3 | 17.2 | 16.3 |

## Total Benchmark Duration

| Framework | llamacpp | vllm | sglang |
|-----------|--------|--------|--------|
| Duration | 4.5m | 2.0m | 2.0m |
