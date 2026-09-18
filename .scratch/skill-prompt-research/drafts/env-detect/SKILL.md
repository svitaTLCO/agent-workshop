---
name: env-detect
description: Probe OS, arch, shell, WSL, container, GPU/NPU and installed CLIs in one run. Use when onboarding, before any env-specific setup, or when behavior differs across machines. Probe once per session and reuse the cached output — do NOT re-probe mid-session unless the machine changed.
license: Apache-2.0
---

# Env Detect

Token budget: this file + one script run; nothing else loads.

Run `bash scripts/detect-env.sh` from repo root. It prints `KEY=value` lines: `OS`, `ARCH`, `DISTRO`, `SHELL`, `IS_WSL`, `IS_CONTAINER`, `HAS_SYSTEMD`, `GPU`, `NPU`, `RAM_GB`, `MAC_KIND`, `MAC_CHIP`, `CPU_CORES`, plus `HAS_RTK/HAS_OLLAMA/HAS_DOCKER/HAS_GH/HAS_NODE/HAS_PYTHON`. The script itself is the shape contract — delegate by `IS_WSL`/`OS` per the rules below; don't hand-copy key shapes into docs.

Rules:

- Prefer this script over ad-hoc `uname` chains so all env skills share one probe.
- On WSL (`IS_WSL=1`): delegate paths/GUI/docker to `env-wsl`.
- On macOS (`OS=darwin`): delegate accelerators/models to `env-macos`; pick local models from `RAM_GB` + `MAC_KIND` (unified memory vs VRAM-bound).
- Never print secrets; only `SET/UNSET` for keys.
- Cache output for the session; re-run only if the user changed the machine.

Quality gate: `bash scripts/detect-env.sh` exits 0 and prints every documented key with `OS`, `ARCH`, `RAM_GB` populated (`unknown` OS or empty RAM = probe failure).
