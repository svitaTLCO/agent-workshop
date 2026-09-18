---
name: local-models
description: Pick and wire a local coding model from detected hardware (RAM, chip, platform) and task — this skill owns the RAM→model tier table. Use for offline models, Ollama/LM Studio pulls, privacy, or pointing opencode/Cline/Pi at localhost. Do NOT use for cloud endpoints or installing Ollama/LM Studio daemons (daemon setup: env-* skills).
license: Apache-2.0
---

# Local Models

Token budget: this table only. Full model cards stay in the registry — never paste benchmarks into context. Tags dated 2026-09; check `ollama list` before pulling. This table is the corpus's single source for RAM tiers — macOS-specific detection and MLX caveats live in `env-macos/references/capability-matrix.md`, which defers tier numbers here.

Requires `env-detect` (`RAM_GB` + `MAC_KIND`/`MAC_CHIP` on macOS, `NPU`/`GPU` elsewhere). Run the scan first; size by detected capability, not the assumed machine.

## Apple Silicon / unified memory (also any Linux host with that much RAM)

| RAM | Start with | Agentic upgrade |
|-----|------------|-----------------|
| ≤16 GB | Gemma 4 12B q4 (`gemma4:12b-mlx` on Apple Silicon) / Phi-4 | — |
| 16–32 GB | Llama 3.3 8B / Gemma 4 12B-mlx | Qwen2.5-Coder-14B (24B tight) |
| 32–48 GB | Qwen3-Coder-30B-A3B (MoE) / `qwen3.5-35b-a3b` class | 256K-ctx variant (best all-rounder); Devstral-24B (tool-calling) |
| 64 GB+ | Qwen3-Coder-30B-A3B (256K ctx) | Llama 3.3 70B q4 (dense); Qwen3-Coder 480B needs 250 GB+ — datacenter only |

## Intel Mac (non-unified)

No MLX acceleration (avoid `-mlx` tags — CPU-speed there). iGPU-only: ≤3B comfortable, 8B q4 for short tasks. dGPU is VRAM-bound (check `system_profiler SPDisplaysDataType`): 8 GB VRAM → 8B q4, 16 GB → 14B q4. Above that use a remote endpoint — thrashing a local pull is worse than its latency.

Wiring: Ollama `http://localhost:11434`, LM Studio `http://localhost:1234`. Cline: provider Ollama + baseURL. OpenCode: OpenAI-compatible provider with `baseURL`. Pi: `ollama launch pi --model <tag>`. Keep tasks small — local ctx is tighter than cloud; prefer 14B+ for multi-file refactors, 7B is fine for single-file CLIs. Record pick in `AGENTS.md`.

Quality gate: `ollama list` shows the model and one smoke prompt returns a sane answer through the wired agent.
