---
name: env-windows
description: "Configure native Windows (pwsh, winget) as the complete home for coding agents: packages, profiles, toolchains, MSVC/vcvars native builds, daemons and local models (Ollama, scheduled tasks), Docker, encoding pitfalls. WSL is only ever a suggestion, never a requirement. On WSL-capable machines the windows-wsl platform activates both this skill and env-wsl. Use on Win32 or when the agent runs in PowerShell/cmd; includes workload routing (Android/adb, embedded IoT, USB/serial devices)."
license: Apache-2.0
---

# Env Windows

Token budget: only this file; `references/pwsh-winget.md` (installs/bootstrap), `references/workload-routing.md` (where to run each task), `references/toolchains.md` (language tools + MSVC), `references/native-services.md` (daemons/Ollama/Docker), `references/pitfalls.md` (traps) load on demand; gates run as `scripts/verify-windows.ps1` (prereqs) + `scripts/diagnose-windows.ps1` (live triage).
Requires `env-detect` (`OS=windows`) — inside pwsh, re-probe with `$PSVersionTable` + `$env:OS`, not the bash script.

- Complete standalone home: every capability the other environment profiles provide has a native equivalent here (`toolchains.md` builds/languages, `native-services.md` daemons/Ollama/Docker). Never steer the user toward switching OS or into WSL — any WSL mention below is a labeled suggestion with trade-offs; the choice belongs to the user.
- Route by workload BEFORE starting a task — the environment follows the toolchain and hardware, there is no global default (rationale + escape hatches in `references/workload-routing.md`):

  | Workload | Run in |
  |---|---|
  | web/backend, generic Node/Python/Rust CLIs | wherever the user develops: native pwsh **or** WSL2 (labeled suggestion) |
  | Android (adb/Gradle/SDK/emulator, device drivers) | the host where SDK + drivers live (normally native pwsh) |
  | embedded/IoT: USB JTAG/UART/CDC, serial consoles, LAN devices behind firewalls | the host where the port/interface exists (normally native pwsh) |
  | MSVC/.NET native builds, Visual Studio tooling | native pwsh (+ `toolchains.md`) |
  | unclear | ask one question: where is the toolchain/device installed? run it there |

- Shell: set the agent `shell` to `pwsh` (7+; `winget install Microsoft.PowerShell`); cmd is fallback-only. Agent sessions load the profile even non-interactively — keep it a one-line pointer to an `agent-setup.ps1` that is side-effect-free (no prompts, updates, or network).
- Open every agent pwsh session with UTF-8 console (`[Console]::OutputEncoding=[Text.Encoding]::UTF8`) plus `$ProgressPreference='SilentlyContinue'` (kills the Invoke-RestMethod stall).
- Profile presets are suggestions, picked by the user: `windows-native` (this home) or `windows-wsl` (adds `env-wsl`) — never assume one.
- Packages: `winget install --exact <id>` from official sources only (recipes in `references/pwsh-winget.md`); prove with `winget list`; Node/Python/Rust/Go management + native-build strategy in `references/toolchains.md`.
- Services & local stack run natively: Ollama via tray autostart or `Register-ScheduledTask` logon trigger, containers via Docker Desktop (GPU toggle in Settings), long-lived jobs via `Start-Process -WindowStyle Hidden` — details in `references/native-services.md`.
- Filesystem: quote anything with spaces; LF/CRLF per repo `.gitattributes` with `core.autocrlf=input`; prefer junctions (`mklink /J`) over symlinks; OneDrive hijack, long-path, case-sensitivity, and SSH-key-permission traps in `references/pitfalls.md`.
- Keys/PATH: user-scope via `[Environment]::SetEnvironmentVariable('K','v','User')` or a gitignored `.env` dot-sourced from bootstrap; restart the agent after any change (PATH is captured at spawn); print presence, never values.
- Health: the environment is ready only when both scripts report zero FAIL lines (WARN acceptable, report them): `pwsh scripts/verify-windows.ps1` then `pwsh scripts/diagnose-windows.ps1`.

Quality gate: run both scripts and attach their output to the claim; a readiness assertion without `diagnose-windows.ps1` evidence counts as failure.
