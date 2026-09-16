---
name: env-detect
description: Probe OS, arch, shell, WSL, container, GPU/NPU and installed CLIs. Use when onboarding, before any env-specific setup, or when behavior differs across machines.
license: Apache-2.0
---

# Env Detect

Run `bash scripts/detect-env.sh` from repo root. It prints `KEY=value` lines: `OS`, `ARCH`, `DISTRO`, `SHELL`, `IS_WSL`, `IS_CONTAINER`, `HAS_SYSTEMD`, `GPU`, `NPU`, `RAM_GB`, plus `HAS_RTK/HAS_OLLAMA/HAS_DOCKER/HAS_GH/HAS_NODE/HAS_PYTHON`.

Rules:

- Prefer this script over ad-hoc `uname` chains so all env skills share one probe.
- On WSL (`IS_WSL=1`): delegate paths/GUI/docker to `env-wsl`.
- On macOS (`OS=darwin`): delegate accelerators/models to `env-macos`.
- Never print secrets; only `SET/UNSET` for keys.
- Cache output for the session; re-run only if the user changed the machine.
