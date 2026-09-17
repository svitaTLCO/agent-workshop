# Windows pwsh/winget reference — load only when installing or bootstrapping

## Winget recipes (official ids)

| Install | Command |
|---|---|
| PowerShell 7 | `winget install -e Microsoft.PowerShell` |
| Git | `winget install -e Git.Git` |
| Ollama | `winget install -e Ollama.Ollama` |
| Docker Desktop | `winget install -e Docker.DockerDesktop` |
| OpenSSH client | `winget install -e Microsoft.OpenSSH.OpenSSHClient` |
| VS Code | `winget install -e Microsoft.VisualStudioCode` |

Flags worth keeping: `-e` exact id, `--silent`, `--accept-source-agreements --accept-package-agreements` for unattended runs. Prove with `winget list <name>`; upgrade later with `winget upgrade`.

## Execution policy

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   # minimum needed for profiles
```

## Profile bootstrap pattern

`$PROFILE` = `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`. Keep it a pointer:

```powershell
New-Item -ItemType Directory -Force $HOME\agent-setup | Out-Null
# C:\Users\<you>\agent-setup.ps1 holds all setup (paths, aliases, keys sourced from gitignored .env)
if (Test-Path $HOME\agent-setup.ps1) { . $HOME\agent-setup.ps1 }
```

Agent shells are non-interactive but still load the profile for the current user; anything not self-contained here will silently be missing in agent sessions.

## pwsh gotchas agents hit

- `curl` is an alias for `Invoke-WebRequest`; call `curl.exe` explicitly.
- Native stderr does not throw under `$ErrorActionPreference='Stop'` unless `$PSNativeCommandUseErrorActionPreference=$true`; guard version probes with try/catch.
- Unix-style `&&` works in pwsh 7; backtick line-continuation and `;` still mean what they have always meant.

## WSL bridge (the preferred escape hatch)

```powershell
wsl --install -d Ubuntu        # one-time, then reboot
wsl --list --verbose           # states: Running / Stopped
wsl -s <Distro>                # set default
wsl -e code .                  # open current folder in the WSL-side editor
```

Once a distro exists, hand off to `env-wsl` for paths/Docker/interop rules.
