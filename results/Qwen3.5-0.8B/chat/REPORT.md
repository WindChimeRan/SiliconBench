# SiliconBench Results — Qwen3.5-0.8B (chat)

**Model:** Qwen3.5-0.8B
**Split:** chat
**Generated:** 2026-07-03 17:46:47

## Concurrency: 1

| Metric | omlx | vllm_metal | ollama | mlx_lm | vllm_mlx | llamacpp |
|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | CRASHED | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 395.8 | 316.7 | 0.0 | 308.9 | 73.9 | 205.5 |
| TTFT p50 (ms) | 338.3 | 161.4 | 0.0 | 224.0 | 42.0 | 136.1 |
| TTFT p99 (ms) | 922.1 | 1106.2 | 0.0 | 765.2 | 541.7 | 832.8 |
| Throughput avg (tok/s) | 8.6 | 82.5 | 0.0 | 105.0 | 90.9 | 126.4 |
| Output throughput (tok/s) | 101.1 | 66.8 | 0.0 | 68.1 | 93.8 | 102.9 |
| Input throughput (tok/s) | 1172.7 | 776.3 | 0.0 | N/A | 1379.8 | 1191.3 |
| Total token throughput (tok/s) | 1273.8 | 843.1 | 0.0 | N/A | 1473.6 | 1294.2 |
| ITL avg (ms) | 100.2 | 11.4 | 0.0 | 9.1 | 9.5 | 7.5 |
| ITL p50 (ms) | 101.7 | 11.5 | 0.0 | 8.8 | 9.6 | 7.4 |
| Latency avg (s) | 0.85 | 1.28 | 0.00 | 0.84 | 0.72 | 0.83 |
| Latency p99 (s) | 2.21 | 3.32 | 0.00 | 2.45 | 2.93 | 2.76 |
| Wall time (s) | 84.8 | 128.1 | 0.1 | 84.4 | 72.0 | 83.4 |

## Concurrency: 8

| Metric | omlx | vllm_metal | ollama | mlx_lm | vllm_mlx | llamacpp |
|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | CRASHED | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 692.2 | 638.2 | 0.0 | 5821.4 | 223.6 | 1423.2 |
| TTFT p50 (ms) | 567.4 | 294.9 | 0.0 | 5868.5 | 220.5 | 1329.6 |
| TTFT p99 (ms) | 2455.8 | 3053.4 | 0.0 | 9843.2 | 306.5 | 3303.5 |
| Throughput avg (tok/s) | 8.8 | 19.6 | 0.0 | 105.0 | 26.5 | 59.9 |
| Output throughput (tok/s) | 150.5 | 130.4 | 0.0 | 68.6 | 217.6 | 232.9 |
| Input throughput (tok/s) | 1725.9 | 1550.6 | 0.0 | N/A | 3058.4 | 2726.5 |
| Total token throughput (tok/s) | 1876.4 | 1681.0 | 0.0 | N/A | 3276.0 | 2959.5 |
| ITL avg (ms) | 118.8 | 53.7 | 0.0 | 9.1 | 31.5 | 16.0 |
| ITL p50 (ms) | 119.5 | 50.1 | 0.0 | 8.8 | 31.9 | 15.6 |
| Latency avg (s) | 4.46 | 4.96 | 0.00 | 6.36 | 2.48 | 2.76 |
| Latency p99 (s) | 13.29 | 17.47 | 0.00 | 10.66 | 8.30 | 6.22 |
| Wall time (s) | 57.6 | 64.1 | 0.0 | 83.8 | 32.5 | 36.5 |

## Concurrency: 16

| Metric | omlx | vllm_metal | ollama | mlx_lm | vllm_mlx | llamacpp |
|--------|--------|--------|--------|--------|--------|--------|
| Successful / Failed | 100 / 0 | 100 / 0 | CRASHED | 100 / 0 | 100 / 0 | 100 / 0 |
| TTFT avg (ms) | 4348.4 | 1078.1 | 0.0 | 11405.6 | 330.8 | 3869.9 |
| TTFT p50 (ms) | 4553.9 | 710.1 | 0.0 | 11848.7 | 316.4 | 4064.2 |
| TTFT p99 (ms) | 6304.2 | 4321.7 | 0.0 | 17422.7 | 604.6 | 5649.1 |
| Throughput avg (tok/s) | 7.9 | 12.2 | 0.0 | 105.0 | 18.6 | 60.6 |
| Output throughput (tok/s) | 152.7 | 158.4 | 0.0 | 68.7 | 288.2 | 237.6 |
| Input throughput (tok/s) | 1751.3 | 1841.6 | 0.0 | N/A | 3918.4 | 2750.6 |
| Total token throughput (tok/s) | 1904.1 | 2000.0 | 0.0 | N/A | 4206.6 | 2988.2 |
| ITL avg (ms) | 125.5 | 93.4 | 0.0 | 9.1 | 47.4 | 15.8 |
| ITL p50 (ms) | 127.0 | 88.5 | 0.0 | 8.8 | 47.1 | 15.4 |
| Latency avg (s) | 8.36 | 8.04 | 0.00 | 11.94 | 3.64 | 5.20 |
| Latency p99 (s) | 19.85 | 27.37 | 0.00 | 17.81 | 12.76 | 9.75 |
| Wall time (s) | 56.8 | 54.0 | 0.0 | 83.7 | 25.4 | 36.1 |

## Total Benchmark Duration

| Framework | omlx | vllm_metal | ollama | mlx_lm | vllm_mlx | llamacpp |
|-----------|--------|--------|--------|--------|--------|--------|
| Duration | 3.5m | 4.3m | 0.2s | 4.3m | 2.3m | 2.7m |
