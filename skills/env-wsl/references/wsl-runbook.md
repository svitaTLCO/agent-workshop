# WSL runbook — load only when a topic above needs setup detail

## Resource limits (`C:\Users\<you>\.wslconfig` on the Windows side — `~/.wslconfig` does not exist inside WSL)

```ini
[wsl2]
memory=16GB        # cap; omit = up to 80% of host RAM
swap=8GB
localhostForwarding=true
networkingMode=mirrored   # optional: same network namespace as host (Win11 22H2+)
```

Apply: `wsl --shutdown` from an admin PowerShell, then re-open the distro. Verify with `free -g` inside WSL.

## File watchers

Build systems die at the default ~65k watches on big trees:

```bash
sudo sysctl fs.inotify.max_user_watches=524288     # live value
```

WSL has no init to re-apply `/etc/sysctl.d` after `wsl --shutdown`; keep the same one-liner at the end of `~/.profile` if builds depend on it.

## Git hygiene

```bash
git config --global core.autocrlf input
printf '* text=auto eol=lf\n*.png binary\n' > .gitattributes   # once per repo
```

## Docker Desktop integration

1. Desktop → Settings → General: "Use WSL 2 based engine"; Resources → Integrations: enable your distro.
2. Inside WSL: `docker context ls` should show `default`; `docker ps` must answer.
3. Container→host: use `host.docker.internal` or the WSL eth0 IP (`hostname -I`). Host→container ports need `-p`.
4. GPU into containers (driver already on Windows side): install `nvidia-container-toolkit` inside WSL, then `docker run --gpus all nvidia/cuda:12.x-base nvidia-smi`.

## VS Code remote

- Install "WSL" extension on the Windows side; open folders via `code .` **from inside WSL**.
- Never edit `/mnt/c` files with watcher-heavy extensions — copy into `~/` first.
- Port forwarding works automatically; if a bound port doesn't appear on `localhost` in Edge, restart the WSL distro (not just the editor).

## GPU (NVIDIA-only pass-through)

- WSL2 GPU pass-through is **NVIDIA-only**: an AMD/Intel dGPU does not accelerate processes inside WSL. Size those boxes as CPU in WSL, or keep GPU-bound compute native-Windows (DirectML-class runtimes — see `env-windows`).
- Windows side (NVIDIA): `winget install Nvidia.Windows.Driver.GeForce` (or your vendor's), reboot, `wsl --update`.
- Inside WSL: `nvidia-smi` is the gate. No Linux driver, no `.run` installer, ever.
