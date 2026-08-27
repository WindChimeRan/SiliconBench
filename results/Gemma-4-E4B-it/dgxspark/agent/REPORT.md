# SiliconBench Results — Gemma-4-E4B-it (agent)

**Model:** Gemma-4-E4B-it
**Split:** agent
**Generated:** 2026-08-27 02:18:34

## Concurrency: 1

| Metric | vllm | sglang | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 94 / 6 | 94 / 6 | 100 / 0 |
| TTFT avg (ms) | 616.7 | 551.7 | 896.7 |
| TTFT p50 (ms) | 497.0 | 397.9 | 700.1 |
| TTFT p99 (ms) | 1906.8 | 2364.5 | 2988.5 |
| Throughput avg (tok/s) | 17.7 | 17.1 | 20.9 |
| Output throughput (tok/s) | 15.7 | 16.0 | 18.1 |
| Input throughput (tok/s) | 819.3 | 861.7 | 880.7 |
| Total token throughput (tok/s) | 834.9 | 877.7 | 898.9 |
| ITL avg (ms) | 56.5 | 56.6 | 46.4 |
| ITL p50 (ms) | 56.1 | 56.5 | 46.3 |
| Latency avg (s) | 5.73 | 5.44 | 5.27 |
| Latency p99 (s) | 15.80 | 15.48 | 13.19 |
| Wall time (s) | 540.8 | 514.1 | 527.1 |

## Concurrency: 8

| Metric | vllm | sglang | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 94 / 6 | 94 / 6 | 100 / 0 |
| TTFT avg (ms) | 189.3 | 182.5 | 2698.6 |
| TTFT p50 (ms) | 172.0 | 174.1 | 2186.8 |
| TTFT p99 (ms) | 261.1 | 324.8 | 7118.4 |
| Throughput avg (tok/s) | 19.0 | 17.1 | 3.6 |
| Output throughput (tok/s) | 133.9 | 125.8 | 24.6 |
| Input throughput (tok/s) | 7068.5 | 6618.3 | 1201.2 |
| Total token throughput (tok/s) | 7202.5 | 6744.1 | 1225.8 |
| ITL avg (ms) | 52.5 | 56.9 | 283.5 |
| ITL p50 (ms) | 51.8 | 57.2 | 292.4 |
| Latency avg (s) | 4.90 | 5.24 | 30.01 |
| Latency p99 (s) | 13.91 | 15.24 | 88.45 |
| Wall time (s) | 62.7 | 66.9 | 386.5 |

## Concurrency: 16

| Metric | vllm | sglang | llamacpp |
|--------|--------|--------|--------|
| Successful / Failed | 95 / 5 | 94 / 6 | 100 / 0 |
| TTFT avg (ms) | 212.1 | 208.1 | 3936.5 |
| TTFT p50 (ms) | 192.6 | 189.1 | 2429.9 |
| TTFT p99 (ms) | 338.2 | 416.3 | 12625.8 |
| Throughput avg (tok/s) | 17.4 | 14.5 | 4.5 |
| Output throughput (tok/s) | 225.1 | 201.9 | 51.7 |
| Input throughput (tok/s) | 11598.7 | 10290.4 | 2507.0 |
| Total token throughput (tok/s) | 11823.8 | 10492.3 | 2558.7 |
| ITL avg (ms) | 57.3 | 67.3 | 251.5 |
| ITL p50 (ms) | 56.5 | 67.5 | 233.8 |
| Latency avg (s) | 5.48 | 6.26 | 26.98 |
| Latency p99 (s) | 15.28 | 17.88 | 72.20 |
| Wall time (s) | 38.6 | 43.0 | 185.2 |

## Total Benchmark Duration

| Framework | vllm | sglang | llamacpp |
|-----------|--------|--------|--------|
| Duration | 11.0m | 10.8m | 18.7m |
