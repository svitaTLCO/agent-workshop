---
name: env-wsl
description: Configure WSL2 interop for coding agents. Use on WSL or when paths, line endings, .exe bridging, Docker, or VSCode remote behave unexpectedly.
license: Apache-2.0
---

# Env WSL

Requires `env-detect` (`IS_WSL=1`).

- Paths: Linux `/mnt/c/...` ↔ Windows `C:\...`; use `wslpath` to convert in scripts. Keep repo checkouts on the Linux side (`~/`) for speed; `/mnt/c` is slow for git/node.
- Binaries: run Windows tools as `<tool>.exe` (e.g. `notepad.exe .bashrc`, `code.exe .`). Never install a Linux duplicate when the `.exe` exists.
- Line endings: enforce LF in repo (`.gitattributes` `* text=auto eol=lf`); `core.autocrlf=input` on WSL side.
- Docker: use Docker Desktop WSL backend; verify `docker ps` from inside WSL.
- VSCode: `code .` from WSL with the WSL extension (remote server), not Windows-side opening of `\\wsl$`.
- Node: prefer Linux-side node; if only Windows node exists, call via `node.exe` and note the penalty in `AGENTS.md`.
- Keys/env: WSL reads `~/.bashrc`; place exports AFTER the `case $- in *i*)` guard so non-interactive agents inherit them.
