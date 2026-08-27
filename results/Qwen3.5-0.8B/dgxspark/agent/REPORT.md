# SiliconBench Results — Qwen3.5-0.8B (agent)

**Model:** Qwen3.5-0.8B
**Split:** agent
**Generated:** 2026-08-27 02:18:34

## Concurrency: 1

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 199.6 | 180.5 | 314.4 |
| TTFT p50 (ms) | 177.0 | 162.2 | 273.6 |
| TTFT p99 (ms) | 498.1 | 565.6 | 910.6 |
| Throughput avg (tok/s) | 99.7 | 105.7 | 118.0 |
| Output throughput (tok/s) | 79.4 | 82.0 | 77.5 |
| Input throughput (tok/s) | 5689.8 | 5749.0 | 5575.8 |
| Total token throughput (tok/s) | 5769.2 | 5830.9 | 5653.4 |
| ITL avg (ms) | 9.7 | 9.5 | 8.2 |
| ITL p50 (ms) | 9.6 | 9.2 | 8.1 |
| Latency avg (s) | 0.81 | 0.80 | 0.83 |
| Latency p99 (s) | 2.82 | 2.80 | 2.63 |
| Wall time (s) | 81.1 | 80.3 | 82.8 |

## Concurrency: 8

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 137.6 | 77.2 | 804.2 |
| TTFT p50 (ms) | 121.3 | 68.3 | 783.5 |
| TTFT p99 (ms) | 348.2 | 181.1 | 2823.3 |
| Throughput avg (tok/s) | 60.0 | 77.9 | 16.3 |
| Output throughput (tok/s) | 396.4 | 520.4 | 108.5 |
| Input throughput (tok/s) | 28901.0 | 35505.6 | 7846.4 |
| Total token throughput (tok/s) | 29297.4 | 36026.0 | 7954.9 |
| ITL avg (ms) | 17.3 | 12.8 | 63.3 |
| ITL p50 (ms) | 16.4 | 12.7 | 61.7 |
| Latency avg (s) | 1.18 | 0.95 | 4.58 |
| Latency p99 (s) | 5.52 | 3.61 | 19.52 |
| Wall time (s) | 16.0 | 13.0 | 58.8 |

## Concurrency: 16

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 115.0 | 109.1 | 898.7 |
| TTFT p50 (ms) | 66.1 | 93.4 | 409.3 |
| TTFT p99 (ms) | 351.9 | 313.3 | 3380.3 |
| Throughput avg (tok/s) | 54.5 | 57.3 | 14.6 |
| Output throughput (tok/s) | 684.1 | 684.6 | 172.7 |
| Input throughput (tok/s) | 51032.4 | 48422.5 | 12707.2 |
| Total token throughput (tok/s) | 51716.5 | 49107.1 | 12880.0 |
| ITL avg (ms) | 18.2 | 17.4 | 75.5 |
| ITL p50 (ms) | 17.6 | 18.2 | 70.2 |
| Latency avg (s) | 1.18 | 1.25 | 5.05 |
| Latency p99 (s) | 5.13 | 4.96 | 20.11 |
| Wall time (s) | 9.0 | 9.5 | 36.3 |

## Total Benchmark Duration

| Framework | sglang | vllm | llamacpp |
|-----------|--------|--------|--------|
| Duration | 1.9m | 1.8m | 3.1m |
