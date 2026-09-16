---
name: env-macos
description: Configure Apple Silicon Macs for coding agents with Ollama MLX and local models. Use on macOS or when asked about NPU, MLX, Ollama, or offline coding.
license: Apache-2.0
---

# Env macOS

Requires `env-detect` (`OS=darwin`).

- Runtime: Ollama ≥ 0.19 runs on MLX (unified memory). Verify `ollama --version`; needs ≥ 32 GB unified memory for 30B+ coding models; M5 GPU Neural Accelerators speed prefill/decode.
- Install: `brew install ollama`; start server; pull per `local-models` RAM table (`gemma4:12b-mlx` to test, `qwen3.5-35b-a3b` / Qwen3-Coder-30B for repo-scale agentic work).
- Wire agents: point OpenAI-compatible baseURL at Ollama (`http://localhost:11434/v1`) — e.g. `ollama launch pi --model gemma4:12b-mlx`, or opencode provider `baseURL`. Alternative: `mlx_lm.server` (`pip install mlx-lm`, OpenAI-compatible, tool-calling models only).
- Caching: Ollama MLX reuses prefix cache + snapshots — keep shared system prompts stable to hit cache.
- Quality note: NVFP4 halves 4-bit quality loss vs `q4_K_M` and matches datacenter-optimized weights; prefer `-mlx` / NVFP4 tags.
- Small models first: verify with 12B before pulling 30B+. Record chosen model + RAM in project `AGENTS.md`.
