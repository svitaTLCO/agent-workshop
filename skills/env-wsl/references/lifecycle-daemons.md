# WSL VM lifecycle & daemons — load when a server must outlive a session, or disk/version problems surface

## What kills your processes

- `wsl --shutdown` (anyone), Windows reboot, and driver/distro updates restart the whole Linux VM — everything inside dies, including systemd units until next boot.
- WSL stops the VM after prolonged idle; Windows sleep/hibernate suspends it. Treat any long-running server as **dying at some point**.
- Consequence for agents: never *assume* a daemon is up. Prove it at session start (health endpoint / port probe) before claiming the stack works.

## Persistence patterns (prefer top down)

1. **systemd user unit + linger** (distro runs systemd):
   ```bash
   systemctl --user daemon-reload && systemctl --user enable --now ollama.service
   sudo loginctl enable-linger "$USER"     # survives logouts — essential for headless agent sessions
   systemctl --user status ollama         # proof
   ```
   (`[Unit] After=network-online.target`, `[Service] ExecStart=/usr/local/bin/ollama serve`, `[Install] WantedBy=default.target`; with systemd enabled, `/etc/sysctl.d` values like inotify watches also re-apply automatically.)
2. **`/etc/wsl.conf` boot command** (no-systemd distros):
   ```ini
   [boot]
   command=nohup /usr/local/bin/ollama serve >/var/log/ollama.log 2>&1 &
   ```
   Runs on every distro boot — combine with the app's own self-start or accept manual revival.
3. **Windows-side tray server** (cross-home option): the official Ollama Windows app serves 11434 and stays reachable from WSL via localhost forwarding — one server, both homes, zero WSL-side daemon. Usually the least-maintenance choice.

## Disk / vhdx maintenance

- The distro lives in an ext4 `.vhdx` that grows but never shrinks on its own. Recent WSL can make it reclaim: `wsl --manage <distro> --set-sparse true` (run from Windows PowerShell).
- Moving/rebuilding a distro: `wsl --export <d> d.tar` → delete → `wsl --import <d> C:\path d.tar` (slow for large disks; plan time).
- Free-space guard before pulling models/images: `df -Pk "$HOME" | awk 'NR==2{print int($4/1048576)}'` ≥ 20 GB, else defer.

## Version hygiene

- After any Windows NVIDIA driver install/update: `wsl --update`, then reboot into the distro and check `nvidia-smi` — stale runtime vs new driver shows up exactly there.
- Sanity baseline: `wslinfo` (inside WSL) or `wsl --status` (Windows side) prints runtime/kernel versions; attach them when reporting "WSL misbehaves".
