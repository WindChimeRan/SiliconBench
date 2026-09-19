# SiliconBench

<p align="center">
<a href="https://ranranhaoranzhang.com/siliconbench/">Project Website</a> | 📄 Paper (pending) | 🛠️ <a href="https://github.com/WindChimeRan/SiliconBench">GitHub</a>
</p>

This repository includes code and materials for the paper
"**SiliconBench: Speed, Memory, and Fidelity for LLM Serving on Unified-Memory Desktops**"
(submitted to arXiv).

```bibtex
@misc{zhang2026siliconbenchspeedmemoryfidelity,
      title={SiliconBench: Speed, Memory, and Fidelity for LLM Serving on Unified-Memory Desktops}, 
      author={Ranran Haoran Zhang and Aysa Xuemo Fan and David Munhá Correia and Alex Cheema and Rui Zhang},
      year={2026},
      eprint={2609.19169},
      archivePrefix={arXiv},
      primaryClass={cs.AR},
      url={https://arxiv.org/abs/2609.19169}, 
}
```

## Overview

SiliconBench evaluates local LLM serving through three lenses: speed, memory,
and fidelity. Throughput and latency measure performance under concurrent
load; memory measurements show how much headroom remains for other applications;
and a classification task checks for quality regressions against an NVIDIA
reference.

The main audit covers nine Apple Silicon serving engines on chat and agent
workloads, using Qwen3, Qwen3.5, and Gemma 4. A complementary NVIDIA DGX Spark
track evaluates serving performance for three shared engine families. The
[benchmark page](https://ranranhaoranzhang.com/siliconbench/) presents the latest
recorded results and run details.

## Quick start

Open this repository in your coding agent and ask it to run the
[benchmark skill](.claude/skills/weekly-bench/SKILL.md):

> Read `.claude/skills/weekly-bench/SKILL.md` and run SiliconBench.

In Claude Code, invoke the skill directly with `/weekly-bench`.

## Frameworks

The Apple Silicon audit includes:

- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [MLX LM](https://github.com/ml-explore/mlx-lm)
- [mistral.rs](https://github.com/EricLBuehler/mistral.rs)
- [vllm-metal](https://github.com/vllm-project/vllm-metal)
- [vllm-mlx](https://github.com/waybarrios/vllm-mlx)
- [oMLX](https://github.com/jundot/omlx)
- [Ollama](https://github.com/ollama/ollama)
- [Hugging Face Transformers](https://github.com/huggingface/transformers)
- [SGLang](https://github.com/sgl-project/sglang)

The DGX Spark track covers llama.cpp, [vLLM](https://github.com/vllm-project/vllm),
and SGLang. The paper's multi-node study also includes
[EXO](https://github.com/exo-explore/exo), alongside MLX LM and llama.cpp.

## License

Original SiliconBench harness code and documentation are licensed under the
[MIT License](LICENSE). Third-party inference engines, model weights, and source
datasets retain their upstream licenses and access conditions. This license does
not relicense those assets or third-party text retained in prompts and outputs.
