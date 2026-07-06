# SiliconBench Results — Gemma-4-E4B-it (chat)

**Model:** Gemma-4-E4B-it
**Split:** chat
**Generated:** 2026-07-05 23:23:24

## Concurrency: 1

| Metric | llamacpp | sglang | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 313.0 | 221.7 | 239.1 |
| TTFT p50 (ms) | 189.1 | 151.5 | 189.6 |
| TTFT p99 (ms) | 952.6 | 761.1 | 953.4 |
| Throughput avg (tok/s) | 19.9 | 16.5 | 16.7 |
| Output throughput (tok/s) | 20.1 | 17.2 | 17.2 |
| Input throughput (tok/s) | 260.3 | 219.7 | 217.4 |
| Total token throughput (tok/s) | 280.4 | 236.9 | 234.6 |
| ITL avg (ms) | 46.6 | 56.2 | 55.0 |
| ITL p50 (ms) | 46.4 | 56.2 | 55.7 |
| Latency avg (s) | 3.79 | 4.49 | 4.54 |
| Latency p99 (s) | 12.49 | 14.47 | 14.61 |
| Wall time (s) | 379.3 | 449.4 | 454.2 |

## Concurrency: 8

| Metric | llamacpp | sglang | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 1240.7 | 161.0 | 173.6 |
| TTFT p50 (ms) | 1036.6 | 160.4 | 155.5 |
| TTFT p99 (ms) | 2709.7 | 179.4 | 318.4 |
| Throughput avg (tok/s) | 3.9 | 17.4 | 18.5 |
| Output throughput (tok/s) | 29.8 | 129.4 | 136.6 |
| Input throughput (tok/s) | 377.7 | 1660.6 | 1753.9 |
| Total token throughput (tok/s) | 407.5 | 1790.0 | 1890.5 |
| ITL avg (ms) | 244.7 | 53.4 | 50.1 |
| ITL p50 (ms) | 246.5 | 54.0 | 50.4 |
| Latency avg (s) | 19.87 | 4.25 | 4.01 |
| Latency p99 (s) | 69.99 | 14.58 | 13.42 |
| Wall time (s) | 261.4 | 59.5 | 56.3 |

## Concurrency: 16

| Metric | llamacpp | sglang | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 1344.3 | 168.2 | 180.4 |
| TTFT p50 (ms) | 1186.3 | 166.5 | 161.3 |
| TTFT p99 (ms) | 4203.5 | 238.7 | 356.3 |
| Throughput avg (tok/s) | 6.2 | 15.4 | 17.9 |
| Output throughput (tok/s) | 72.8 | 211.7 | 238.5 |
| Input throughput (tok/s) | 940.7 | 2792.9 | 3052.5 |
| Total token throughput (tok/s) | 1013.5 | 3004.5 | 3291.0 |
| ITL avg (ms) | 178.3 | 61.2 | 51.7 |
| ITL p50 (ms) | 162.3 | 61.5 | 52.1 |
| Latency avg (s) | 13.94 | 4.56 | 4.13 |
| Latency p99 (s) | 48.22 | 15.83 | 13.50 |
| Wall time (s) | 105.0 | 35.4 | 32.3 |

## Total Benchmark Duration

| Framework | llamacpp | sglang | vllm |
|-----------|--------|--------|--------|
| Duration | 12.8m | 9.6m | 9.6m |
