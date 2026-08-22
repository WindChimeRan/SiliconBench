# Correctness eval — Gemma-4-E4B-it

| Framework | 0-shot F1 | 0-shot F1-macro | 0-shot EM | 0-shot errors | 5-shot F1 | 5-shot F1-macro | 5-shot EM | 5-shot errors |
|---|---|---|---|---|---|---|---|---|
| llamacpp | 0.8497 | 0.6797 | 0.8482 | 0/0 | 0.9107 | 0.6908 | 0.9058 | 0/0 |
| mlx_lm | 0.8493 | 0.6808 | 0.8482 | 0/0 | 0.9108 | 0.6926 | 0.9066 | 0/0 |
| vllm_metal | 0.8512 | 0.6830 | 0.8499 | 1/0 | 0.9106 | 0.6918 | 0.9058 | 1/0 |
| omlx | 0.8539 | 0.6825 | 0.8525 | 0/0 | 0.9120 | 0.6924 | 0.9075 | 0/0 |
| vllm_mlx | 0.8530 | 0.6822 | 0.8517 | 0/0 | 0.9107 | 0.6908 | 0.9058 | 0/0 |
| vllm-nvidia | 0.8511 | 0.6816 | 0.8499 | 0/0 | 0.9128 | 0.6927 | 0.9084 | 0/0 |

errors column = request_errors / parse_failures
