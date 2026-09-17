# Linux systemd reference — load only when wiring user services

## Ollama as a user service

`~/.config/systemd/user/ollama.service`:

```ini
[Unit]
Description=Ollama LLM server (user)
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
Environment=OLLAMA_HOST=127.0.0.1:11434
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

Wire it up:

```bash
systemctl --user daemon-reload
systemctl --user enable --now ollama
loginctl enable-linger "$USER"          # headless boxes: units run without login
loginctl show-user "$USER" | grep Linger   # expect yes
journalctl --user -u ollama -f           # live logs
```

Use the real `ollama` path from `command -v ollama`; `/usr/local/bin` is the common but not universal location.

## Generic agent-daemon pattern

Same shape with `Type=simple`, an absolute `WorkingDirectory`, and secret-free env via `EnvironmentFile=-%h/.config/agents/agent.env` (leading `-` = optional file). Keep API keys out of the unit file itself.

## When there is no systemd

Containers and minimal images: start daemons in a named tmux/screen session (`tmux new -d -s ollama 'ollama serve'`), record the session name in project `AGENTS.md`, and let the container's entrypoint own restarts. Do not fight init.

## Distro notes

| Distros | Gotcha |
|---|---|
| Ubuntu 24.04+ | snap vs apt conflicts on docker — prefer the apt engine over the snap package here |
| Fedora | unprivileged user namespaces restricted by some vendors; docker rootless may need `sysctl user.max_user_namespaces` |
| Arch | rolling releases; pin nothing, re-run `verify-linux.sh` after major kernel updates |
