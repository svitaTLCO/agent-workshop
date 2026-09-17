# Windows pitfalls reference — load when output looks wrong, files misbehave, ports collide, or disk fills up

## Encoding & shell I/O
- First lines of every agent pwsh session:
  ```powershell
  [Console]::OutputEncoding = [Text.Encoding]::UTF8
  $ProgressPreference = 'SilentlyContinue'    # removes the Invoke-RestMethod progress-bar stall
  ```
- cmd children inherit codepage: start generated `.bat`/`cmd /c` chains with `chcp 65001 >$null`.
- PowerShell `>` redirection can rewrite LF→CRLF depending on version/encoding; for byte-exact files use `Out-File -Encoding utf8NoBOM` (PS 7.2+) or `[IO.File]::WriteAllBytes`.
- Never emit UTF-8 **with BOM** into sources, `.gitignore`, lockfiles, or anything git/node parses.

## Filesystem traps
- Case-insensitive FS: `Rename-Item foo Foo` fails — two-hop via a temp name.
- Long paths: admin registry `HKLM\SYSTEM\CurrentControlSet\Control\FileSystem` → `LongPathsEnabled=1` (+ reboot), then `git config --global core.longpaths true`; without both, deep `node_modules` installs throw ENOENT.
- Reserved names (`CON`, `NUL`, `AUX`, `PRN`, `COM1-9`, `LPT1-9`) cannot be created normally — avoid them at creation time rather than fighting the trailing-dot workaround.
- Junctions are the admin-free link primitive (symlinks need Developer Mode/admin): `New-Item -ItemType Junction -Path C:\dev -Target D:\projects`.
- OneDrive known-folder move: check `[Environment]::GetFolderPath('MyDocuments')` — if it starts under `$env:OneDrive`, treat literal `C:\Users\<u>\Documents` as phantom; hardcoding it breaks tools.

## Ports & processes
- Owner of a localhost port:
  ```powershell
  Get-NetTCPConnection -LocalPort 11434 -State Listen | Select-Object OwningProcess
  Get-Process -Id <pid> | Select-Object Name, Path
  ```
- Ollama expects 11434; a foreign PID there means another server silently took the port. Kill deliberately after confirming the owner — never broad `taskkill /F /IM`.

## Disk & daemons
- Docker Desktop stores images in a hidden ext4 VHD under `%LOCALAPPDATA%\Docker`; inspect size of its `.vhdx`, relocate to a second disk via Settings → Resources before C: exhausts.
- Free-space guard before pulling models/images: `(Get-PSDrive C).Free / 1GB` ≥ 20 GB, else defer.

## Secrets
- Prefer a gitignored `.env` dot-sourced from bootstrap over User-scope env vars (process-wide env is visible to every spawned child); print presence only: `[Environment]::GetEnvironmentVariable('K','User') -ne $null`.

## SSH private keys
- Trap: `WARNING: UNPROTECTED PRIVATE KEY FILE` / `bad permissions` after keys arrive via backup restore or OneDrive sync — profile-level inherited ACEs make them world-readable to OpenSSH's eye.
- Fix: strip inheritance, grant owner read only:
  ```powershell
  icacls "$env:USERPROFILE\.ssh\id_ed25519" /inheritance:r /grant:r "${env:USERNAME}:R"
  icacls "$env:USERPROFILE\.ssh\config"     /inheritance:r /grant:r "${env:USERNAME}:C,R"
  ```
- Windows OpenSSH ships `ssh-agent` as a service (auto-start); `ssh-add` once in an interactive console and the key persists for that agent instance.
