# SiliconBench Results — Qwen3-0.6B (chat)

**Model:** Qwen3-0.6B
**Split:** chat
**Generated:** 2026-07-05 22:53:58

## Concurrency: 1

| Metric | sglang | llamacpp | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 33.5 | 85.8 | 41.1 |
| TTFT p50 (ms) | 22.1 | 68.9 | 27.3 |
| TTFT p99 (ms) | 119.8 | 320.1 | 182.9 |
| Throughput avg (tok/s) | 106.2 | 141.7 | 105.5 |
| Output throughput (tok/s) | 106.8 | 119.4 | 103.3 |
| Input throughput (tok/s) | 2260.3 | 2605.1 | 2224.6 |
| Total token throughput (tok/s) | 2367.1 | 2724.5 | 2327.8 |
| ITL avg (ms) | 8.7 | 6.6 | 8.8 |
| ITL p50 (ms) | 8.5 | 6.5 | 8.6 |
| Latency avg (s) | 0.44 | 0.38 | 0.45 |
| Latency p99 (s) | 2.69 | 1.61 | 2.30 |
| Wall time (s) | 44.1 | 38.3 | 44.8 |

## Concurrency: 8

| Metric | sglang | llamacpp | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 33.9 | 163.5 | 38.7 |
| TTFT p50 (ms) | 33.3 | 138.3 | 36.9 |
| TTFT p99 (ms) | 49.1 | 320.5 | 64.9 |
| Throughput avg (tok/s) | 76.0 | 20.4 | 82.1 |
| Output throughput (tok/s) | 592.3 | 157.7 | 633.3 |
| Input throughput (tok/s) | 12566.6 | 3383.7 | 13855.8 |
| Total token throughput (tok/s) | 13158.9 | 3541.4 | 14489.2 |
| ITL avg (ms) | 12.3 | 46.5 | 11.4 |
| ITL p50 (ms) | 12.3 | 45.8 | 11.5 |
| Latency avg (s) | 0.61 | 2.31 | 0.55 |
| Latency p99 (s) | 3.36 | 12.08 | 2.98 |
| Wall time (s) | 7.9 | 29.5 | 7.2 |

## Concurrency: 16

| Metric | sglang | llamacpp | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 44.5 | 228.7 | 55.1 |
| TTFT p50 (ms) | 41.5 | 178.1 | 51.7 |
| TTFT p99 (ms) | 71.6 | 669.8 | 104.4 |
| Throughput avg (tok/s) | 53.4 | 16.3 | 58.9 |
| Output throughput (tok/s) | 734.1 | 235.3 | 796.0 |
| Input throughput (tok/s) | 16044.1 | 5099.2 | 16323.2 |
| Total token throughput (tok/s) | 16778.2 | 5334.5 | 17119.3 |
| ITL avg (ms) | 17.6 | 59.5 | 16.0 |
| ITL p50 (ms) | 17.7 | 59.6 | 16.8 |
| Latency avg (s) | 0.81 | 2.79 | 0.80 |
| Latency p99 (s) | 3.55 | 9.78 | 3.67 |
| Wall time (s) | 6.2 | 19.5 | 6.1 |

## Total Benchmark Duration

| Framework | sglang | llamacpp | vllm |
|-----------|--------|--------|--------|
| Duration | 1.0m | 1.5m | 1.0m |
