---
name: env-windows
description: Configure native Windows (pwsh, winget) for coding agents outside WSL. Use on Win32 or when the agent runs in PowerShell/cmd.
license: Apache-2.0
---

# Env Windows

Requires `env-detect` (`OS=windows`).

- Shell: set agent `shell` to `pwsh`; use `winget` for installs (`winget install Ollama.Ollama`, `Docker.DockerDesktop`).
- Prefer WSL2 for real dev work — if `wsl --list` exists, suggest the `windows-wsl` profile and delegate to `env-wsl`.
- Paths: quote spaces (`"C:\Program Files\..."`); LF/CRLF per repo `.gitattributes`.
- Keys: user-scope env vars via Settings or `[Environment]::SetEnvironmentVariable(..., 'User')`; restart agent after change.
