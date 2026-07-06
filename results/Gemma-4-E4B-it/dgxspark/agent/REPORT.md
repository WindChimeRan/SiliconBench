# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-07-05 23:43:48

## Concurrency: 1

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 94 / 6 | 94 / 6 | 100 / 0 |
| TTFT avg (ms) | 551.7 | 500.4 | 896.7 |
| TTFT p50 (ms) | 397.9 | 371.0 | 700.1 |
| TTFT p99 (ms) | 2364.5 | 1832.9 | 2988.5 |
| Throughput avg (tok/s) | 17.1 | 15.7 | 20.9 |
| Output throughput (tok/s) | 16.0 | 16.1 | 18.1 |
| Input throughput (tok/s) | 861.7 | 841.4 | 880.7 |
| Total token throughput (tok/s) | 877.7 | 857.5 | 898.9 |
| ITL avg (ms) | 56.6 | 60.6 | 46.4 |
| ITL p50 (ms) | 56.5 | 57.7 | 46.3 |
| Latency avg (s) | 5.44 | 5.58 | 5.27 |
| Latency p99 (s) | 15.48 | 15.61 | 13.19 |
| Wall time (s) | 514.1 | 526.6 | 527.1 |

## Concurrency: 8

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 94 / 6 | 94 / 6 | 100 / 0 |
| TTFT avg (ms) | 182.5 | 211.7 | 2698.6 |
| TTFT p50 (ms) | 174.1 | 176.2 | 2186.8 |
| TTFT p99 (ms) | 324.8 | 471.7 | 7118.4 |
| Throughput avg (tok/s) | 17.1 | 17.1 | 3.6 |
| Output throughput (tok/s) | 125.8 | 131.9 | 24.6 |
| Input throughput (tok/s) | 6618.3 | 6948.2 | 1201.2 |
| Total token throughput (tok/s) | 6744.1 | 7080.1 | 1225.8 |
| ITL avg (ms) | 56.9 | 55.7 | 283.5 |
| ITL p50 (ms) | 57.2 | 53.3 | 292.4 |
| Latency avg (s) | 5.24 | 4.86 | 30.01 |
| Latency p99 (s) | 15.24 | 14.10 | 88.45 |
| Wall time (s) | 66.9 | 63.8 | 386.5 |

## Concurrency: 16

| Metric | sglang | vllm | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 94 / 6 | 94 / 6 | 100 / 0 |
| TTFT avg (ms) | 208.1 | 240.7 | 3936.5 |
| TTFT p50 (ms) | 189.1 | 211.4 | 2429.9 |
| TTFT p99 (ms) | 416.3 | 546.8 | 12625.8 |
| Throughput avg (tok/s) | 14.5 | 15.5 | 4.5 |
| Output throughput (tok/s) | 201.9 | 226.4 | 51.7 |
| Input throughput (tok/s) | 10290.4 | 11818.6 | 2507.0 |
| Total token throughput (tok/s) | 10492.3 | 12045.1 | 2558.7 |
| ITL avg (ms) | 67.3 | 61.7 | 251.5 |
| ITL p50 (ms) | 67.5 | 59.4 | 233.8 |
| Latency avg (s) | 6.26 | 5.36 | 26.98 |
| Latency p99 (s) | 17.88 | 15.08 | 72.20 |
| Wall time (s) | 43.0 | 37.5 | 185.2 |

## Total Benchmark Duration

| Framework | sglang | vllm | llamacpp |
|-----------|--------|--------|--------|
| Duration | 10.8m | 10.9m | 18.7m |
