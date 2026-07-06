# SiliconBench Results — Qwen3.5-0.8B (chat)

**Model:** Qwen3.5-0.8B
**Split:** chat
**Generated:** 2026-07-05 23:04:25

## Concurrency: 1

| Metric | vllm | llamacpp | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 85.6 | 107.9 | 107.1 |
| TTFT p50 (ms) | 65.0 | 84.5 | 91.0 |
| TTFT p99 (ms) | 496.4 | 310.0 | 422.5 |
| Throughput avg (tok/s) | 96.9 | 113.5 | 99.1 |
| Output throughput (tok/s) | 94.2 | 106.5 | 95.0 |
| Input throughput (tok/s) | 1102.5 | 1249.7 | 1106.0 |
| Total token throughput (tok/s) | 1196.7 | 1356.2 | 1201.0 |
| ITL avg (ms) | 9.6 | 8.3 | 9.3 |
| ITL p50 (ms) | 9.7 | 8.2 | 9.3 |
| Latency avg (s) | 0.90 | 0.80 | 0.90 |
| Latency p99 (s) | 2.65 | 2.41 | 2.70 |
| Wall time (s) | 90.2 | 79.5 | 89.9 |

## Concurrency: 8

| Metric | vllm | llamacpp | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 99.1 | 175.0 | 74.8 |
| TTFT p50 (ms) | 61.7 | 163.9 | 52.8 |
| TTFT p99 (ms) | 411.6 | 418.5 | 260.9 |
| Throughput avg (tok/s) | 72.5 | 20.8 | 76.8 |
| Output throughput (tok/s) | 529.8 | 162.1 | 580.2 |
| Input throughput (tok/s) | 6269.7 | 1889.9 | 6708.3 |
| Total token throughput (tok/s) | 6799.5 | 2052.1 | 7288.6 |
| ITL avg (ms) | 13.7 | 46.1 | 12.3 |
| ITL p50 (ms) | 13.0 | 46.5 | 12.1 |
| Latency avg (s) | 1.19 | 4.04 | 1.12 |
| Latency p99 (s) | 3.51 | 13.48 | 3.61 |
| Wall time (s) | 15.9 | 52.6 | 14.8 |

## Concurrency: 16

| Metric | vllm | llamacpp | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 174.2 | 217.1 | 73.2 |
| TTFT p50 (ms) | 113.2 | 168.9 | 49.9 |
| TTFT p99 (ms) | 572.7 | 623.6 | 226.6 |
| Throughput avg (tok/s) | 49.0 | 27.4 | 65.9 |
| Output throughput (tok/s) | 680.6 | 376.1 | 935.3 |
| Input throughput (tok/s) | 8146.0 | 4363.0 | 11056.3 |
| Total token throughput (tok/s) | 8826.5 | 4739.1 | 11991.6 |
| ITL avg (ms) | 21.5 | 34.1 | 14.4 |
| ITL p50 (ms) | 19.6 | 34.8 | 14.7 |
| Latency avg (s) | 1.71 | 3.15 | 1.24 |
| Latency p99 (s) | 5.64 | 9.51 | 3.99 |
| Wall time (s) | 12.2 | 22.8 | 9.0 |

## Total Benchmark Duration

| Framework | vllm | llamacpp | sglang |
|-----------|--------|--------|--------|
| Duration | 2.1m | 2.7m | 2.2m |
