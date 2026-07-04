# SiliconBench Results — Qwen3-0.6B (chat)

**Model:** Qwen3-0.6B
**Split:** chat
**Generated:** 2026-07-03 20:21:56

## Concurrency: 1

| Metric | llamacpp | sglang | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 87.4 | 33.5 | 41.1 |
| TTFT p50 (ms) | 67.3 | 22.1 | 27.3 |
| TTFT p99 (ms) | 278.9 | 119.8 | 182.9 |
| Throughput avg (tok/s) | 136.2 | 106.2 | 105.5 |
| Output throughput (tok/s) | 115.0 | 106.8 | 103.3 |
| Input throughput (tok/s) | 2500.0 | 2260.3 | 2224.6 |
| Total token throughput (tok/s) | 2615.0 | 2367.1 | 2327.8 |
| ITL avg (ms) | 6.9 | 8.7 | 8.8 |
| ITL p50 (ms) | 6.7 | 8.5 | 8.6 |
| Latency avg (s) | 0.40 | 0.44 | 0.45 |
| Latency p99 (s) | 1.69 | 2.69 | 2.30 |
| Wall time (s) | 39.9 | 44.1 | 44.8 |

## Concurrency: 8

| Metric | llamacpp | sglang | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 1016.4 | 33.9 | 38.7 |
| TTFT p50 (ms) | 1002.3 | 33.3 | 36.9 |
| TTFT p99 (ms) | 2040.8 | 49.1 | 64.9 |
| Throughput avg (tok/s) | 53.0 | 76.0 | 82.1 |
| Output throughput (tok/s) | 191.1 | 592.3 | 633.3 |
| Input throughput (tok/s) | 4137.3 | 12566.6 | 13855.8 |
| Total token throughput (tok/s) | 4328.3 | 13158.9 | 14489.2 |
| ITL avg (ms) | 18.4 | 12.3 | 11.4 |
| ITL p50 (ms) | 17.9 | 12.3 | 11.5 |
| Latency avg (s) | 1.87 | 0.61 | 0.55 |
| Latency p99 (s) | 5.48 | 3.36 | 2.98 |
| Wall time (s) | 24.1 | 7.9 | 7.2 |

## Concurrency: 16

| Metric | llamacpp | sglang | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 2749.8 | 44.5 | 55.1 |
| TTFT p50 (ms) | 3031.1 | 41.5 | 51.7 |
| TTFT p99 (ms) | 4224.2 | 71.6 | 104.4 |
| Throughput avg (tok/s) | 54.5 | 53.4 | 58.9 |
| Output throughput (tok/s) | 193.1 | 734.1 | 796.0 |
| Input throughput (tok/s) | 4063.7 | 16044.1 | 16323.2 |
| Total token throughput (tok/s) | 4256.9 | 16778.2 | 17119.3 |
| ITL avg (ms) | 18.3 | 17.6 | 16.0 |
| ITL p50 (ms) | 17.9 | 17.7 | 16.8 |
| Latency avg (s) | 3.62 | 0.81 | 0.80 |
| Latency p99 (s) | 7.73 | 3.55 | 3.67 |
| Wall time (s) | 24.5 | 6.2 | 6.1 |

## Total Benchmark Duration

| Framework | llamacpp | sglang | vllm |
|-----------|--------|--------|--------|
| Duration | 1.5m | 1.0m | 1.0m |
