---
name: local-models
description: Pick and wire a local coding model by RAM and task. Use when asked about offline models, Ollama, LM Studio, privacy, or pointing opencode/Cline/Pi at localhost.
license: Apache-2.0
---

# Local Models

Token budget: this table only. Full model cards stay in the registry — never paste benchmarks into context.

Requires `env-detect` (RAM, NPU/GPU).

| RAM | Start with | Agentic upgrade |
|-----|------------|-----------------|
| 16 GB | Phi-4 / Gemma 4 12B | — |
| 32–36 GB | Llama 3.3 8B / Gemma 4 12B-mlx | Qwen2.5-Coder-14B |
| 64 GB | Qwen2 34B | Qwen3-Coder-30B-A3B (256K ctx, best all-rounder), Devstral-24B (tool-calling) |
| 128 GB+ | Llama 3.3 70B | Qwen3-Coder 480B needs 250 GB+ — datacenter only |

Wiring: Ollama `http://localhost:11434`, LM Studio `http://localhost:1234`. Cline: provider Ollama + baseURL. OpenCode: OpenAI-compatible provider with `baseURL`. Pi: `ollama launch pi --model <tag>`. Keep tasks small — local ctx is tighter than cloud; prefer 14B+ for multi-file refactors, 7B is fine for single-file CLIs. Record pick in `AGENTS.md`.

Quality gate: `ollama list` shows the model and one smoke prompt returns a sane answer through the wired agent.
