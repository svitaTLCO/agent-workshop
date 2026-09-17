# Native services & local stack — load when starting daemons (Ollama, helpers), containers, or long-running processes on native Windows

There is no systemd on Windows; persistence means scheduled tasks or the process's own autostart. Pick per service.

## Ollama (local models)

- Install: `winget install -e Ollama.Ollama` (official app). Default behavior: the tray app runs `ollama serve` at logon — usually leave it as is.
- Headless machines (tray autostart off): register a logon task instead — never both (port 11434 conflict):
  ```powershell
  Register-ScheduledTask -TaskName OllamaServe -Trigger (New-ScheduledTaskTrigger -AtLogOn) `
    -Action (New-ScheduledTaskAction -Execute "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe" -Argument 'serve') `
    -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries)
  Start-ScheduledTask OllamaServe
  Get-ScheduledTask OllamaServe | Select State                    # Ready/Running
  Invoke-RestMethod http://localhost:11434/api/version           # proof
  ```
- BaseURL/model wiring is identical to other platforms (see the `local-models` skill): use standard quantized tags (the MLX/NVFP4 rows are macOS-only); RAM budgeting follows the same table; `OLLAMA_KEEP_ALIVE=<duration>` works here too.
- Port already bound → run `scripts/diagnose-windows.ps1`; it names the owning PID (trap detail in `pitfalls.md`).

## Generic daemons (no-systemd patterns)

- At logon, any helper binary: the `Register-ScheduledTask … -AtLogOn` shape above — the universal daemon pattern on Windows.
- Session-scoped only: `Start-Process -FilePath <exe> -ArgumentList … -WindowStyle Hidden -PassThru` (returns a Process; stop later with `Stop-Process <id>`).
- Prove liveness without attaching: `Get-Process -Name <name>` + `Test-NetConnection localhost -Port <p>` (TCP connect).

## Docker (native pwsh side)

- `winget install -e Docker.DockerDesktop`, reboot after first launch (WSL2 backend required under the hood); prove from pwsh: `docker ps`, `docker version`.
- GPU: Settings → Resources → GPU → "Use the GPU in containers" — no toolkit juggling from the Windows side (that concern lives in `env-wsl`).
- Non-NVIDIA GPUs on Windows: there is no CUDA-class stack. Practical options: DirectML-capable runtimes (e.g. LM Studio) or CPU — say so explicitly instead of promising parity for AMD/Intel cards.
- Images/volumes live in the Desktop VM's hidden VHD → sizing/relocation in `pitfalls.md`; `host.docker.internal` reaches the host like on other backends.
