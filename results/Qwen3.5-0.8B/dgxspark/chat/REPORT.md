# SiliconBench Results — Qwen3.5-0.8B (chat)

**Model:** Qwen3.5-0.8B
**Split:** chat
**Generated:** 2026-07-04 00:40:54

## Concurrency: 1

| Metric | vllm | llamacpp | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 85.6 | 105.7 | 107.1 |
| TTFT p50 (ms) | 65.0 | 80.3 | 91.0 |
| TTFT p99 (ms) | 496.4 | 312.4 | 422.5 |
| Throughput avg (tok/s) | 96.9 | 114.7 | 99.1 |
| Output throughput (tok/s) | 94.2 | 108.0 | 95.0 |
| Input throughput (tok/s) | 1102.5 | 1267.0 | 1106.0 |
| Total token throughput (tok/s) | 1196.7 | 1375.0 | 1201.0 |
| ITL avg (ms) | 9.6 | 8.2 | 9.3 |
| ITL p50 (ms) | 9.7 | 8.1 | 9.3 |
| Latency avg (s) | 0.90 | 0.78 | 0.90 |
| Latency p99 (s) | 2.65 | 2.42 | 2.70 |
| Wall time (s) | 90.2 | 78.5 | 89.9 |

## Concurrency: 8

| Metric | vllm | llamacpp | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 99.1 | 1215.1 | 74.8 |
| TTFT p50 (ms) | 61.7 | 1146.7 | 52.8 |
| TTFT p99 (ms) | 411.6 | 2919.3 | 260.9 |
| Throughput avg (tok/s) | 72.5 | 69.1 | 76.8 |
| Output throughput (tok/s) | 529.8 | 271.2 | 580.2 |
| Input throughput (tok/s) | 6269.7 | 3142.9 | 6708.3 |
| Total token throughput (tok/s) | 6799.5 | 3414.1 | 7288.6 |
| ITL avg (ms) | 13.7 | 13.8 | 12.3 |
| ITL p50 (ms) | 13.0 | 13.4 | 12.1 |
| Latency avg (s) | 1.19 | 2.38 | 1.12 |
| Latency p99 (s) | 3.51 | 5.49 | 3.61 |
| Wall time (s) | 15.9 | 31.6 | 14.8 |

## Concurrency: 16

| Metric | vllm | llamacpp | sglang |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 174.2 | 3183.8 | 73.2 |
| TTFT p50 (ms) | 113.2 | 3423.1 | 49.9 |
| TTFT p99 (ms) | 572.7 | 5301.6 | 226.6 |
| Throughput avg (tok/s) | 49.0 | 68.4 | 65.9 |
| Output throughput (tok/s) | 680.6 | 276.4 | 935.3 |
| Input throughput (tok/s) | 8146.0 | 3263.8 | 11056.3 |
| Total token throughput (tok/s) | 8826.5 | 3540.1 | 11991.6 |
| ITL avg (ms) | 21.5 | 13.7 | 14.4 |
| ITL p50 (ms) | 19.6 | 13.4 | 14.7 |
| Latency avg (s) | 1.71 | 4.31 | 1.24 |
| Latency p99 (s) | 5.64 | 7.52 | 3.99 |
| Wall time (s) | 12.2 | 30.5 | 9.0 |

## Total Benchmark Duration

| Framework | vllm | llamacpp | sglang |
|-----------|--------|--------|--------|
| Duration | 2.1m | 2.4m | 2.2m |
