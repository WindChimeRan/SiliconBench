# SiliconBench Results — Gemma-4-E4B-it (chat)

**Model:** Gemma-4-E4B-it
**Split:** chat
**Generated:** 2026-07-04 20:09:05

## Concurrency: 1

| Metric | sglang | llamacpp | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 221.7 | 316.5 | 239.1 |
| TTFT p50 (ms) | 151.5 | 187.9 | 189.6 |
| TTFT p99 (ms) | 761.1 | 951.4 | 953.4 |
| Throughput avg (tok/s) | 16.5 | 20.5 | 16.7 |
| Output throughput (tok/s) | 17.2 | 20.5 | 17.2 |
| Input throughput (tok/s) | 219.7 | 266.2 | 217.4 |
| Total token throughput (tok/s) | 236.9 | 286.7 | 234.6 |
| ITL avg (ms) | 56.2 | 45.3 | 55.0 |
| ITL p50 (ms) | 56.2 | 45.2 | 55.7 |
| Latency avg (s) | 4.49 | 3.71 | 4.54 |
| Latency p99 (s) | 14.47 | 12.45 | 14.61 |
| Wall time (s) | 449.4 | 370.9 | 454.2 |

## Concurrency: 8

| Metric | sglang | llamacpp | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 161.0 | 5692.0 | 173.6 |
| TTFT p50 (ms) | 160.4 | 5715.6 | 155.5 |
| TTFT p99 (ms) | 179.4 | 11305.4 | 318.4 |
| Throughput avg (tok/s) | 17.4 | 14.8 | 18.5 |
| Output throughput (tok/s) | 129.4 | 52.9 | 136.6 |
| Input throughput (tok/s) | 1660.6 | 684.7 | 1753.9 |
| Total token throughput (tok/s) | 1790.0 | 737.6 | 1890.5 |
| ITL avg (ms) | 53.4 | 63.9 | 50.1 |
| ITL p50 (ms) | 54.0 | 61.7 | 50.4 |
| Latency avg (s) | 4.25 | 10.67 | 4.01 |
| Latency p99 (s) | 14.58 | 25.83 | 13.42 |
| Wall time (s) | 59.5 | 144.2 | 56.3 |

## Concurrency: 16

| Metric | sglang | llamacpp | vllm |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 168.2 | 14893.4 | 180.4 |
| TTFT p50 (ms) | 166.5 | 15705.9 | 161.3 |
| TTFT p99 (ms) | 238.7 | 22417.0 | 356.3 |
| Throughput avg (tok/s) | 15.4 | 14.7 | 17.9 |
| Output throughput (tok/s) | 211.7 | 52.3 | 238.5 |
| Input throughput (tok/s) | 2792.9 | 671.8 | 3052.5 |
| Total token throughput (tok/s) | 3004.5 | 724.1 | 3291.0 |
| ITL avg (ms) | 61.2 | 65.4 | 51.7 |
| ITL p50 (ms) | 61.5 | 61.1 | 52.1 |
| Latency avg (s) | 4.56 | 19.96 | 4.13 |
| Latency p99 (s) | 15.83 | 40.25 | 13.50 |
| Wall time (s) | 35.4 | 147.0 | 32.3 |

## Total Benchmark Duration

| Framework | sglang | llamacpp | vllm |
|-----------|--------|--------|--------|
| Duration | 9.6m | 11.4m | 9.6m |
