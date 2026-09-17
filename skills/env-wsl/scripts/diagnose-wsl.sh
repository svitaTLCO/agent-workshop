#!/usr/bin/env bash
# Live WSL triage for coding agents (complements verify-wsl.sh prereqs). Prints OK/WARN/FAIL; exits 1 on any FAIL.
set -u
fails=0
ok(){ echo "OK   $1"; }
warn(){ echo "WARN $1"; }
fail(){ echo "FAIL $1"; fails=$((fails+1)); }
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  warn "not inside WSL — nothing to diagnose here (use the native OS skill)"; exit 0
fi
if command -v wslinfo >/dev/null 2>&1; then
  netmode=$(wslinfo --networking-mode 2>/dev/null | grep -m1 . || echo unknown)
  wslver=$(wslinfo --version 2>/dev/null | grep -m1 . || echo unknown)
  ok "WSL runtime $wslver (networking mode: $netmode — see network-devices.md matrix)"
else warn "wslinfo missing (very old WSL runtime — run wsl --update from Windows)"; fi
sysrun=$(systemctl is-system-running 2>/dev/null || true)
case "$sysrun" in
  running|degraded) ok "systemd active ($sysrun)";;
  *) warn "systemd not running — user units won't persist; use [boot] command= pattern (lifecycle-daemons.md)";;
esac
loginctl show-user "$USER" 2>/dev/null | grep -q 'Lingering=yes' \
  && ok "linger enabled for $USER" \
  || warn "linger off (sudo loginctl enable-linger $USER) — daemons die on logout"
grep -q '^command=' /etc/wsl.conf 2>/dev/null \
  && ok "/etc/wsl.conf [boot] command= registered" \
  || warn "no [boot] command in /etc/wsl.conf (fine if systemd units cover daemons)"
ip route 2>/dev/null | grep -q 'default' && ok "default route present" || fail "no default route — networking broken"
if command -v curl >/dev/null 2>&1 && [ -n "${http_proxy:-}${HTTP_PROXY:-}${https_proxy:-}${HTTPS_PROXY:-}" ]; then
  if curl -sS --max-time 5 https://example.com >/dev/null 2>&1; then
    ok "proxy env set and reachable"
  elif curl -sS --max-time 5 --noproxy '*' https://example.com >/dev/null 2>&1; then
    warn "proxy vars block tooling but bypass works — imported Windows proxy (autoProxy); see network-devices.md"
  else fail "no reachability even without proxy — check adapter/firewall"; fi
elif command -v curl >/dev/null 2>&1; then
  curl -sS --max-time 5 https://example.com >/dev/null 2>&1 && ok "external reachability fine (no proxy vars)" || warn "example.com unreachable — inspect egress before blaming WSL"
else warn "curl missing — skipping connectivity probe"; fi
case ":$HOME:$PWD:" in */mnt/*) warn "working paths touch /mnt (9P slowness; keep repos under ~/)";; *) ok "paths stay on the Linux filesystem side";; esac
watches=$(sysctl -n fs.inotify.max_user_watches 2>/dev/null || echo 0)
[ "$watches" -le 65536 ] 2>/dev/null && warn "inotify watches at default (${watches}) — large builds may starve them" \
  || ok "inotify watchers raised (${watches})"
if command -v ss >/dev/null 2>&1; then
  line=$(ss -ltnp 2>/dev/null | grep ':11434 ')
  if [ -z "$line" ]; then
    ok "port 11434 free (no local model server up yet)"
  else
    pid=$(echo "$line" | grep -o 'pid=[0-9]*' | head -1 | cut -d= -f2)
    name=$(ps -o comm= -p "$pid" 2>/dev/null || echo "?")
    case "$name" in *ollama*) ok "11434 served by $name (pid $pid)";; *) warn "11434 held by unexpected process $name (pid $pid) — confirm ownership before killing";; esac
  fi
else warn "ss unavailable — cannot attribute port 11434"; fi
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
  memgb=$(free -g 2>/dev/null | awk '/^Mem/{print $2}')
  ok "nvidia-smi answers (GPU passthrough live); WSL total RAM ≈ ${memgb:-?}G — cap must exceed model footprint"
else warn "no NVIDIA passthrough (WSL2 GPU is NVIDIA-only — AMD/Intel dGPUs can't accelerate WSL; fine on GPU-less boxes)"; fi
dfree_gb=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2{print int($4/1048576)}')
[ "${dfree_gb:-0}" -ge 10 ] && ok "disk: ${dfree_gb}G free under \$HOME" || warn "disk: only ${dfree_gb:-?}G free — defer pulls/expansions"
command -v clip.exe >/dev/null 2>&1 && ok "clip.exe interop available (clipboard bridge)" || warn "clip.exe not on PATH (clipboard interop limited)"
exit $((fails > 0))
