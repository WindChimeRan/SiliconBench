# Correctness eval — Qwen3.5-0.8B

| Framework | 0-shot F1 | 0-shot F1-macro | 0-shot EM | 0-shot errors | 5-shot F1 | 5-shot F1-macro | 5-shot EM | 5-shot errors |
|---|---|---|---|---|---|---|---|---|
| llamacpp | 0.7003 | 0.4055 | 0.6972 | 0/0 | 0.5940 | 0.3766 | 0.5960 | 0/0 |
| mlx_lm | 0.6942 | 0.3999 | 0.6928 | 0/0 | 0.5903 | 0.3787 | 0.5969 | 0/0 |
| vllm_metal | 0.6947 | 0.4065 | 0.6867 | 1/0 | 0.6081 | 0.4176 | 0.5986 | 1/0 |
| omlx | 0.6981 | 0.4046 | 0.6972 | 0/0 | 0.5929 | 0.3808 | 0.5977 | 0/0 |
| vllm_mlx | 0.7006 | 0.4072 | 0.6972 | 0/0 | 0.5922 | 0.3798 | 0.5969 | 0/0 |
| vllm-nvidia | 0.6953 | 0.4055 | 0.6955 | 0/0 | 0.5949 | 0.3851 | 0.6012 | 0/0 |

errors column = request_errors / parse_failures
