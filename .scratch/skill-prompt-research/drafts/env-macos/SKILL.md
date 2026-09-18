---
name: env-macos
description: Configure macOS as a complete home for coding agents — Apple Silicon (Ollama MLX, unified memory) or Intel (VRAM-bound ceilings), brew services, local-model wiring. Use on macOS or when asked about NPU/MLX/mlx-lm, Ollama on Mac, chip detection, memory pressure, offline coding, or which model fits this Mac. Setup mechanics live here; model tier numbers defer to local-models.
license: Apache-2.0
---

# Env macOS

Token budget: only this file; silicon/intel capability notes load from `references/capability-matrix.md`, inference tuning from `references/mlx-ollama.md`; health runs via `scripts/verify-macos.sh` (prereqs) and `scripts/diagnose-macos.sh` (live triage).
Requires `env-detect` (`OS=darwin`; `NPU=1` on Apple Silicon).

- Standalone home with same-box parity with `env-windows`/`env-linux`/`env-wsl`: every capability below has a native macOS path; routing decisions live at the user, not in this skill.
- Detect before picking: run `detect-env.sh` and trust `RAM_GB` + `MAC_KIND` + `MAC_CHIP`. `-mlx` tags only accelerate on Apple Silicon; their size class differs from plain q4. Tier numbers: the `local-models` table (single source); Mac-specific detection/Rosetta/VRAM caveats: `references/capability-matrix.md`.
- Apple Silicon: Ollama ≥ 0.19 runs on MLX over unified memory. Install `brew install ollama` + `brew services start ollama` (survives reboots; `brew services list`). Pull per the `local-models` unified ladder — smallest tier to test first, agentic tier for repo-scale work. Wire the OpenAI-compatible baseURL (`http://localhost:11434/v1`) or `mlx_lm.server` (tool-capable checkpoints only); stable system prompts hit the prefix cache. Prefer `-mlx`/NVFP4 tags (halves 4-bit quality loss vs `q4_K_M`).
- Intel Mac: no MLX acceleration — plain Ollama on CPU/iGPU (skip `-mlx` tags). Ceilings are VRAM-bound: read the display data (`system_profiler SPDisplaysDataType`) and size from the `local-models` Intel section; above it, recommend a remote endpoint rather than a thrashing pull.
- Smallest tier first: verify with the smallest tier before pulling bigger; record chosen model + detected RAM in project `AGENTS.md`.
- Memory pressure: free pool = detected `RAM_GB` minus resident apps; `diagnose-macos.sh` flags active swap (`vm.swapusage`) — an OOM kill mid-task is worse than a slow one.
- Long runs: wrap agent sessions in `caffeinate -dims` so sleep cannot interrupt; change `pmset` defaults only when explicitly asked.

Quality gate: both `scripts/verify-macos.sh` (darwin arch + Rosetta check, brew, ollama version, RAM tier) and `scripts/diagnose-macos.sh` (platform facts, model-tier verdict, swap, port ownership, service registration) report zero FAIL lines before relying on the box.
