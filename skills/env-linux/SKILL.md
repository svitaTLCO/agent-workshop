---
name: env-linux
description: Configure native Linux shells, packages, systemd and Docker for coding agents. Use on non-WSL Linux or for service/key persistence questions.
license: Apache-2.0
---

# Env Linux

Requires `env-detect` (`OS=linux`, `IS_WSL=0`).

- Packages: `apt`/`dnf`/`pacman` via sudo; `python3`, `git`, `gh`, `docker`, `direnv` as needed.
- Shell: respect `$SHELL` (`bash`/`zsh`/`fish`); agent non-interactive shells source `~/.bashrc` (bash) — keep exports after the interactive guard.
- Services: `systemd --user` units for Ollama/agent daemons; `loginctl enable-linger` on headless boxes.
- Docker: native engine; add user to `docker` group rather than running agents as root.
