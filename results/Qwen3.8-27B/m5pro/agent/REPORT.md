# SiliconBench Results — Qwen3.8-27B (agent)

**Model:** Qwen3.8-27B
**Split:** agent
**Generated:** 2026-08-26 15:42:59

## Concurrency: 1

| Metric | omlx | llamacpp | vllm_metal |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 7776.6 | 10849.1 | 10145.9 |
| TTFT p50 (ms) | 6647.3 | 8149.3 | 7858.4 |
| TTFT p99 (ms) | 23674.2 | 31283.9 | 27636.0 |
| Throughput avg (tok/s) | 9.6 | 9.2 | 8.9 |
| Output throughput (tok/s) | 4.7 | 3.8 | 3.9 |
| Input throughput (tok/s) | 303.6 | 254.4 | 257.9 |
| Total token throughput (tok/s) | 308.3 | 258.2 | 261.8 |
| ITL avg (ms) | 100.9 | 104.7 | 108.4 |
| ITL p50 (ms) | 102.3 | 104.0 | 108.3 |
| Latency avg (s) | 15.22 | 18.16 | 17.92 |
| Latency p99 (s) | 41.26 | 40.27 | 40.33 |
| Wall time (s) | 1522.3 | 1816.5 | 1792.3 |

## Concurrency: 2

| Metric | omlx | llamacpp | vllm_metal |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 13573.7 | 13741.2 | 11876.6 |
| TTFT p50 (ms) | 11802.9 | 9739.4 | 9414.6 |
| TTFT p99 (ms) | 36203.4 | 42579.9 | 35394.6 |
| Throughput avg (tok/s) | 5.3 | 5.1 | 5.7 |
| Output throughput (tok/s) | 5.2 | 4.2 | 4.7 |
| Input throughput (tok/s) | 340.8 | 280.0 | 312.2 |
| Total token throughput (tok/s) | 346.0 | 284.2 | 316.9 |
| ITL avg (ms) | 196.1 | 289.7 | 287.3 |
| ITL p50 (ms) | 197.8 | 206.8 | 146.8 |
| Latency avg (s) | 27.10 | 33.00 | 29.56 |
| Latency p99 (s) | 83.10 | 139.92 | 120.07 |
| Wall time (s) | 1356.2 | 1650.4 | 1480.1 |

## Concurrency: 4

| Metric | omlx | llamacpp | vllm_metal |
|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 26867.6 | 15615.0 | 14655.6 |
| TTFT p50 (ms) | 24132.7 | 11072.0 | 11668.3 |
| TTFT p99 (ms) | 72273.4 | 51781.4 | 60532.3 |
| Throughput avg (tok/s) | 3.4 | 3.1 | 3.2 |
| Output throughput (tok/s) | 5.9 | 4.7 | 5.2 |
| Input throughput (tok/s) | 384.2 | 318.5 | 348.0 |
| Total token throughput (tok/s) | 390.1 | 323.2 | 353.3 |
| ITL avg (ms) | 292.6 | 586.9 | 533.9 |
| ITL p50 (ms) | 312.2 | 463.0 | 445.1 |
| Latency avg (s) | 47.87 | 57.59 | 52.70 |
| Latency p99 (s) | 149.05 | 205.91 | 221.64 |
| Wall time (s) | 1202.8 | 1450.9 | 1327.9 |

## Total Benchmark Duration

| Framework | omlx | llamacpp | vllm_metal |
|-----------|--------|--------|--------|
| Duration | 71.7m | 85.7m | 80.4m |
