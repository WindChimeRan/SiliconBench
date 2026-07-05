# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-07-04 20:40:24

## Concurrency: 1

| Metric | llamacpp | sglang | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 94 / 6 | 94 / 6 |
| TTFT avg (ms) | 907.9 | 551.7 | 500.4 |
| TTFT p50 (ms) | 689.3 | 397.9 | 371.0 |
| TTFT p99 (ms) | 3025.2 | 2364.5 | 1832.9 |
| Throughput avg (tok/s) | 21.0 | 17.1 | 15.7 |
| Output throughput (tok/s) | 18.2 | 16.0 | 16.1 |
| Input throughput (tok/s) | 884.3 | 861.7 | 841.4 |
| Total token throughput (tok/s) | 902.5 | 877.7 | 857.5 |
| ITL avg (ms) | 46.1 | 56.6 | 60.6 |
| ITL p50 (ms) | 46.0 | 56.5 | 57.7 |
| Latency avg (s) | 5.25 | 5.44 | 5.58 |
| Latency p99 (s) | 13.15 | 15.48 | 15.61 |
| Wall time (s) | 524.9 | 514.1 | 526.6 |

## Concurrency: 8

| Metric | llamacpp | sglang | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 94 / 6 | 94 / 6 |
| TTFT avg (ms) | 9616.8 | 182.5 | 211.7 |
| TTFT p50 (ms) | 9937.0 | 174.1 | 176.2 |
| TTFT p99 (ms) | 16992.1 | 324.8 | 471.7 |
| Throughput avg (tok/s) | 13.2 | 17.1 | 17.1 |
| Output throughput (tok/s) | 42.9 | 125.8 | 131.9 |
| Input throughput (tok/s) | 2069.3 | 6618.3 | 6948.2 |
| Total token throughput (tok/s) | 2112.2 | 6744.1 | 7080.1 |
| ITL avg (ms) | 79.6 | 56.9 | 55.7 |
| ITL p50 (ms) | 73.9 | 57.2 | 53.3 |
| Latency avg (s) | 17.16 | 5.24 | 4.86 |
| Latency p99 (s) | 40.53 | 15.24 | 14.10 |
| Wall time (s) | 224.3 | 66.9 | 63.8 |

## Concurrency: 16

| Metric | llamacpp | sglang | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 94 / 6 | 94 / 6 |
| TTFT avg (ms) | 25483.0 | 208.1 | 240.7 |
| TTFT p50 (ms) | 27328.5 | 189.1 | 211.4 |
| TTFT p99 (ms) | 36957.4 | 416.3 | 546.8 |
| Throughput avg (tok/s) | 13.8 | 14.5 | 15.5 |
| Output throughput (tok/s) | 43.8 | 201.9 | 226.4 |
| Input throughput (tok/s) | 2130.7 | 10290.4 | 11818.6 |
| Total token throughput (tok/s) | 2174.5 | 10492.3 | 12045.1 |
| ITL avg (ms) | 75.9 | 67.3 | 61.7 |
| ITL p50 (ms) | 71.1 | 67.5 | 59.4 |
| Latency avg (s) | 32.78 | 6.26 | 5.36 |
| Latency p99 (s) | 60.61 | 17.88 | 15.08 |
| Wall time (s) | 217.9 | 43.0 | 37.5 |

## Total Benchmark Duration

| Framework | llamacpp | sglang | vllm |
|-----------|--------|--------|--------|
| Duration | 16.5m | 10.8m | 10.9m |
