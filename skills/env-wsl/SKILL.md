---
name: env-wsl
description: Configure WSL2 as a complete home for coding agents. Use on WSL for paths, .exe bridging, Docker, VS Code remote, NVIDIA GPU passthrough (NVIDIA-only boundary), daemon persistence across VM restarts, networking modes (mirrored vs NAT, autoProxy leaks), USB devices via usbipd, or wslconfig tuning. Pairs with env-windows — on WSL-capable hosts the windows-wsl platform loads both skills.
license: Apache-2.0
---

# Env WSL

Token budget: only this file; `references/wsl-runbook.md` (setup details), `references/lifecycle-daemons.md` (what dies + how to persist it), `references/network-devices.md` (port matrix, proxy, USB/GPU sizing) load on demand; gates run as `scripts/verify-wsl.sh` (prereqs) + `scripts/diagnose-wsl.sh` (live triage).
Requires `env-detect` (`IS_WSL=1`).

- Complete standalone home: every capability below has a native WSL path; never steer work to another environment or distro. The one sanctioned exit is hardware/identity-bound workloads → native Windows, always labeled with its costs (see Workload ownership). Same-box parity with the other env skills — routing decisions live at the user.
- Paths: Linux `/mnt/c/...` ↔ Windows `C:\...`; convert in scripts with `wslpath`. Keep repos on the Linux side (`~/`) for speed; `/mnt/c` is slow for git/node.
- Binaries: run Windows tools as `<tool>.exe` (e.g. `notepad.exe .bashrc`, `code.exe .`). Never install a Linux duplicate when the `.exe` exists.
- Line endings: enforce LF in repo (`.gitattributes` `* text=auto eol=lf`); `core.autocrlf=input` on WSL side.
- Docker: Desktop's WSL backend (integrate distro in Settings); verify `docker ps` from inside; host reachability via `host.docker.internal`; ports need `-p` to appear on Windows. Details in `references/wsl-runbook.md`.
- VS Code: `code .` from WSL with the WSL extension (remote server), not Windows-side opening of `\\wsl$`; hanging builds → raise `fs.inotify.max_user_watches` (runbook).
- GPU: pass-through into WSL2 is **NVIDIA-only** — Windows-side driver, module picked up automatically, `nvidia-smi` inside WSL is the gate. An AMD/Intel dGPU cannot accelerate WSL workloads: size as CPU here, or run that compute native-Windows (DirectML-class runtimes). The `[wsl2] memory=` cap must exceed model footprint or inference OOMs/CPU-falls back (`network-devices.md`).
- Node: prefer Linux-side node; if only Windows node exists, call via `node.exe` and note the penalty in `AGENTS.md`.
- Workload ownership: hardware-bound workloads (physical ADB/USB devices, serial/JTAG consoles) and port-specific targets behind enterprise ACLs are suggested to run on the native Windows side — `usbipd` inside WSL is a labeled last-resort fallback with stated costs (`network-devices.md`), never the default pitch.
- Persistence: nothing survives `wsl --shutdown`, idle VM stop, or Windows sleep — register daemons via systemd user units + linger or `[boot] command=` (`lifecycle-daemons.md`); prove long-lived servers at session start, never assume them.
- Networking: default NAT vs mirrored mode changes who sees which port, and Windows proxy settings leak into tooling via `autoProxy` — matrix + fixes in `references/network-devices.md`.
- Keys/env: WSL reads `~/.bashrc`; place exports AFTER the `case $- in *i*)` guard so non-interactive agents inherit them.
- Tuning: caps (`C:\Users\<you>\.wslconfig` + `wsl --shutdown`) and vhdx/disk maintenance in `references/lifecycle-daemons.md`.
- Health: ready only when both scripts report zero FAIL lines (WARN acceptable, report them): `bash scripts/verify-wsl.sh` then `bash scripts/diagnose-wsl.sh`.

Quality gate: run both scripts and attach their output to the claim; a readiness assertion without `diagnose-wsl.sh` evidence counts as failure.
