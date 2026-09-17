#!/usr/bin/env bash
# Live Linux triage for coding agents (complements verify-linux.sh prereqs). Prints OK/WARN/FAIL; exits 1 on any FAIL.
set -u
fails=0
ok(){ echo "OK   $1"; }
warn(){ echo "WARN $1"; }
fail(){ echo "FAIL $1"; fails=$((fails+1)); }
if [ "$(uname -s)" != "Linux" ]; then
  warn "not Linux ($(uname -s)) — nothing to diagnose here (use the skill for your OS)"; exit 0
fi
grep -qi microsoft /proc/version 2>/dev/null && { warn "this looks like WSL — use env-wsl / diagnose-wsl.sh instead"; exit 0; }
sysrun=$(systemctl is-system-running 2>/dev/null || true)
case "$sysrun" in
  running|degraded) ok "systemd active ($sysrun)";;
  *) warn "systemd not running — user units won't persist; tmux/screen fallback per references/systemd-units.md";;
esac
loginctl show-user "$USER" 2>/dev/null | grep -q 'Lingering=yes' \
  && ok "linger enabled for $USER" \
  || warn "linger off (sudo loginctl enable-linger $USER) — daemons die on logout"
lang=$(locale 2>/dev/null | awk -F= '/^LANG/{print $2}')
case "${lang:-}" in
  *UTF*) ok "locale UTF-8 (${lang})";;
  *) warn "LANG='${lang:-unset}' not UTF-8 — export LANG=C.UTF-8 in rc after the interactive guard (devices-pitfalls.md)";;
esac
watches=$(sysctl -n fs.inotify.max_user_watches 2>/dev/null || echo 0)
[ "$watches" -le 65536 ] 2>/dev/null && warn "inotify watches at default (${watches}) — large builds may starve them" \
  || ok "inotify watchers raised (${watches})"
ip route 2>/dev/null | grep -q 'default' && ok "default route present" || fail "no default route — networking broken"
if command -v curl >/dev/null 2>&1 && [ -n "${http_proxy:-}${HTTP_PROXY:-}${https_proxy:-}${HTTPS_PROXY:-}" ]; then
  if curl -sS --max-time 5 https://example.com >/dev/null 2>&1; then
    ok "proxy env set and reachable"
  elif curl -sS --max-time 5 --noproxy '*' https://example.com >/dev/null 2>&1; then
    warn "proxy vars block tooling but bypass works — unset them or point at the real proxy"
  else fail "no reachability even without proxy — check adapter/firewall"; fi
elif command -v curl >/dev/null 2>&1; then
  curl -sS --max-time 5 https://example.com >/dev/null 2>&1 && ok "external reachability fine (no proxy vars)" || warn "example.com unreachable — inspect egress before blaming config"
else warn "curl missing — skipping connectivity probe"; fi
for tool in node python3 cargo; do
  if command -v "$tool" >/dev/null 2>&1; then
    distinct=$(type -aP "$tool" 2>/dev/null | xargs -r -n1 readlink -f 2>/dev/null | sort -u | wc -l)
    [ "$distinct" -gt 1 ] && warn "$tool resolves to $distinct distinct binaries (first wins: $(command -v "$tool")) — remove the stale bin dir (devices-pitfalls.md)" \
      || ok "$tool resolves unambiguously"
  fi
done
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
  vram=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
  memgb=$(free -g 2>/dev/null | awk '/^Mem/{print $2}')
  ok "GPU live (nvidia, VRAM ${vram:-?} MiB); system RAM ≈ ${memgb:-?}G — size models accordingly"
elif ! command -v lspci >/dev/null 2>&1; then
  warn "cannot enumerate GPUs (lspci missing — apt install pciutils) — default to CPU sizing per local-models"
else
  gpus=$(lspci 2>/dev/null | grep -Ei 'vga|3d controller' || true)
  if echo "$gpus" | grep -qi nvidia; then
    warn "NVIDIA GPU enumerated but nvidia-smi broken/missing — reinstall distro driver (references/toolchains.md)"
  elif echo "$gpus" | grep -Eqi 'advanced micro devices|\[amd/ati\]'; then
    if command -v rocminfo >/dev/null 2>&1 && rocminfo >/dev/null 2>&1; then
      ok "AMD GPU active under ROCm (rocminfo clean)"
    else warn "AMD GPU enumerated, no working ROCm stack — wire ROCm/Vulkan (references/toolchains.md) or stay CPU"; fi
  elif echo "$gpus" | grep -qi 'intel corporation'; then
    ok "Intel graphics only — CPU-level model sizing (optional Vulkan/SYCL lane per references/toolchains.md)"
  else
    ok "no discrete GPU enumerated — CPU inference, size by RAM only"
  fi
fi
dfree_gb=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2{print int($4/1048576)}')
[ "${dfree_gb:-0}" -ge 10 ] && ok "disk: ${dfree_gb}G free under \$HOME" || warn "disk: only ${dfree_gb:-?}G free — defer pulls/expansions"
usb_nodes=$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | wc -l)
[ "$usb_nodes" -gt 0 ] && ok "$usb_nodes USB serial device nodes present (stable naming via udev — devices-pitfalls.md)" \
  || ok "no USB serial nodes (expected with no IoT hardware attached)"
[ -n "${DISPLAY:-}" ] && ok "display available ($DISPLAY)" || warn "headless (no DISPLAY) — use headless flags / xvfb-run only for GUI-bound one-offs"
exit $((fails > 0))
