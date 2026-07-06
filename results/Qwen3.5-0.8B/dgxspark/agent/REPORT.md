# SiliconBench Results — Qwen3.5-0.8B (agent)

**Model:** Qwen3.5-0.8B
**Split:** agent
**Generated:** 2026-07-05 23:09:00

## Concurrency: 1

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 199.6 | 232.2 | 314.4 |
| TTFT p50 (ms) | 177.0 | 215.9 | 273.6 |
| TTFT p99 (ms) | 498.1 | 535.3 | 910.6 |
| Throughput avg (tok/s) | 99.7 | 95.2 | 118.0 |
| Output throughput (tok/s) | 79.4 | 73.4 | 77.5 |
| Input throughput (tok/s) | 5689.8 | 5369.8 | 5575.8 |
| Total token throughput (tok/s) | 5769.2 | 5443.2 | 5653.4 |
| ITL avg (ms) | 9.7 | 10.1 | 8.2 |
| ITL p50 (ms) | 9.6 | 10.1 | 8.1 |
| Latency avg (s) | 0.81 | 0.86 | 0.83 |
| Latency p99 (s) | 2.82 | 3.01 | 2.63 |
| Wall time (s) | 81.1 | 86.0 | 82.8 |

## Concurrency: 8

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 137.6 | 416.7 | 804.2 |
| TTFT p50 (ms) | 121.3 | 361.7 | 783.5 |
| TTFT p99 (ms) | 348.2 | 1634.1 | 2823.3 |
| Throughput avg (tok/s) | 60.0 | 38.5 | 16.3 |
| Output throughput (tok/s) | 396.4 | 223.9 | 108.5 |
| Input throughput (tok/s) | 28901.0 | 16326.8 | 7846.4 |
| Total token throughput (tok/s) | 29297.4 | 16550.7 | 7954.9 |
| ITL avg (ms) | 17.3 | 30.3 | 63.3 |
| ITL p50 (ms) | 16.4 | 26.8 | 61.7 |
| Latency avg (s) | 1.18 | 2.15 | 4.58 |
| Latency p99 (s) | 5.52 | 10.40 | 19.52 |
| Wall time (s) | 16.0 | 28.3 | 58.8 |

## Concurrency: 16

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 115.0 | 807.2 | 898.7 |
| TTFT p50 (ms) | 66.1 | 550.7 | 409.3 |
| TTFT p99 (ms) | 351.9 | 3766.4 | 3380.3 |
| Throughput avg (tok/s) | 54.5 | 21.8 | 14.6 |
| Output throughput (tok/s) | 684.1 | 248.5 | 172.7 |
| Input throughput (tok/s) | 51032.4 | 17271.9 | 12707.2 |
| Total token throughput (tok/s) | 51716.5 | 17520.4 | 12880.0 |
| ITL avg (ms) | 18.2 | 56.1 | 75.5 |
| ITL p50 (ms) | 17.6 | 55.9 | 70.2 |
| Latency avg (s) | 1.18 | 3.99 | 5.05 |
| Latency p99 (s) | 5.13 | 15.95 | 20.11 |
| Wall time (s) | 9.0 | 26.7 | 36.3 |

## Total Benchmark Duration

| Framework | sglang | vllm | llamacpp |
|-----------|--------|--------|--------|
| Duration | 1.9m | 2.5m | 3.1m |
