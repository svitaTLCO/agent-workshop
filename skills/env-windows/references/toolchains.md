# Windows toolchains reference — load only when installing language tools or native builds fail

## Node.js
- One version manager per machine: Volta (`winget install -e Volta.Volta`) **or** nvm-windows (`winget install -e CoreyButler.NVMforWindows`) — never both.
- Global package bins must be on PATH: npm `%APPDATA%\npm`, Volta `%LOCALAPPDATA%\Volta\bin`. Prove with `where.exe node`, `where.exe npm`.
- Pin per project: `volta pin node@x.y.z pnpm@a.b.c`; record chosen runtime + versions in project `AGENTS.md`.
- A failing native-module build (node-gyp) needs MSVC below before retrying.

## Python
- Use the launcher, never assume `python.exe`: `py -0p` lists installs.
- Per-project isolation: `py -m venv .venv`; prefer passing the absolute interpreter path (`.venv\Scripts\python.exe`) to tools over activating in each shell.
- No system-wide `pip install`; `--user` output isn't on PATH anyway.

## Rust / Go
- Bin dirs to keep on PATH: `%USERPROFILE%\.cargo\bin`, `%USERPROFILE%\go\bin`. Prove with `where.exe cargo` / `where.exe go`.
- After any installer touches PATH: restart the agent session (PATH is captured at spawn).

## Native builds (MSVC) — the #1 blocker
1. Install once (several minutes):
   ```powershell
   winget install -e Microsoft.VisualStudio.2022.BuildTools `
     --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
   ```
2. Locate the install root (default path shown; adjust if absent):
   ```powershell
   $vc = & "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
   ```
3. vcvars exports env into *cmd* processes only. Wrap the whole build in one cmd call so every step inherits it:
   ```powershell
   & cmd /c "call `"${vc}\VC\Auxiliary\Build\vcvars64.bat`" && where cl"        # proof
   & cmd /c "call `"${vc}\VC\Auxiliary\Build\vcvars64.bat`" && node scripts\build-native.js"
   ```
   If `cl` is needed mid-pwsh-script (rare), re-wrap each such block separately — do not expect vcvars vars to persist in pwsh.

## Toolchain decision ladder
1. Official Windows binary (zip/exe) → 2. winget/scoop id → 3. language-level manager (volta/pnpm/py/cargo) → 4. vcvars build above → 5. last resort only: run inside a WSL distro (`wsl -e bash -lc '<cmd>'`, hand off to `env-wsl`) — label it as such and note why paths 1–4 failed.
