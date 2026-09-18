---
name: env-linux
description: Configure native Linux (apt/dnf/pacman, systemd) as a complete home for coding agents, on desktop or headless/server boxes alike. Use on non-WSL Linux for distro packages, shell rc behavior, user services, Docker, build toolchains & GPU stacks (CUDA/ROCm/Vulkan) setup, USB/udev device work, or encoding/locale problems. Which model fits the silicon is local-models' job — this skill sets up the stack that model runs on.
license: Apache-2.0
---

# Env Linux

Token budget: only this file; unit templates load from `references/systemd-units.md`, toolchain/GPU strategy from `references/toolchains.md`, device + trap notes from `references/devices-pitfalls.md`; health runs via `scripts/verify-linux.sh` (prereqs) and `scripts/diagnose-linux.sh` (live triage).
Requires `env-detect` (`OS=linux`, `IS_WSL=0`).

- Complete standalone home: every capability below has a native path here; never steer work to another environment. Same-box parity with `env-windows`/`env-macos`/`env-wsl` — routing decisions live at the user, not in this skill.
- Desktop or headless, either first-class: detect `$DISPLAY` (or use `diagnose-linux.sh`'s report); headless means prefer headless flags, daemons via systemd + linger, no X installs — not that the box is degraded.
- Distro: trust `DISTRO` from `env-detect`; Debian/Ubuntu → `apt`, Fedora/RHEL → `dnf`, Arch → `pacman`. Never cross-install without asking.
- Packages: `apt`/`dnf`/`pacman` with sudo as needed; `python3`, `git`, `gh`, `docker`, `direnv` as required. Official repos only — no curl-pipe scripts. Runtimes/build systems/GPU stacks: decision ladder + NVIDIA/AMD/Intel lanes in `references/toolchains.md` (name the real silicon first; one version manager per language, same rule as Windows).
- Shell: respect `$SHELL` (`bash`/`zsh`/`fish`). Agent non-interactive shells source `~/.bashrc` (bash) / `~/.zshenv` (zsh) — keep exports after the interactive guard; fish uses `set -Ux KEY value` in `~/.config/fish/config.fish`.
- Services: `systemd --user` units for Ollama/agent daemons (templates in `references/systemd-units.md`); `loginctl enable-linger <user>` on headless boxes so units survive logout. No systemd (container/minimal) → run daemons in tmux/screen instead.
- Devices: USB serial/JTAG and physical ADB attach natively here (`/dev/ttyUSB*`) — hardware-bound embedded/IoT/mobile work runs on this box, no passthrough bridge. Stable node naming via udev rules: `references/devices-pitfalls.md`.
- Docker: native engine; add the user to the `docker` group (`sudo usermod -aG docker $USER`, re-login) rather than running agents as root. GPU-in-container (NVIDIA lane) needs `nvidia-container-toolkit` + `--gpus all`; AMD/Intel cards have no container-GPU path — host runtime or CPU.
- Keys/env: export in gitignored files (`~/.profile` line sourcing `~/.config/agents.env`) or direnv `.envrc` per project; never inline in tracked rc files.

Quality gate: both `scripts/verify-linux.sh` (prereqs) and `scripts/diagnose-linux.sh` (live state: locale, lingering, port ownership, PATH shadowing, disk) report zero FAIL lines before relying on the box.
