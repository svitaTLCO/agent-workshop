#!/usr/bin/env bash
# Live macOS triage for local coding models (complements verify-macos.sh prereqs). Prints OK/WARN/FAIL; exits 1 on any FAIL.
set -u
fails=0
ok(){ echo "OK   $1"; }
warn(){ echo "WARN $1"; }
fail(){ echo "FAIL $1"; fails=$((fails+1)); }
if [ "$(uname -s)" != "Darwin" ]; then
  warn "not macOS — nothing to diagnose here (use the skill for your OS)"; exit 0
fi
chip=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo unknown)
cores=$(sysctl -n hw.physicalcpu 2>/dev/null || echo ?)
mem_gb=$(( $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1073741824 ))
rosetta=""
[ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = "1" ] && rosetta=" [Rosetta-translated shell]"
case "$chip" in
  *Apple*) kind=apple-silicon ;;
  *) kind=intel ;;
esac
ok "platform: ${kind} (${chip}, ${cores} cores, ${mem_gb} GB unified)${rosetta}"
if [ "$kind" = apple-silicon ]; then
  if [ "$mem_gb" -lt 16 ]; then tier="≤12B q4 only (16 GB cap)"
  elif [ "$mem_gb" -lt 32 ]; then tier="14B coder class (24B tight)"
  elif [ "$mem_gb" -lt 48 ]; then tier="30B-A3B MoE class"
  else tier="70B q4 range — prefer 30B-A3B for agentic ctx"; fi
  ok "silicon model tier @ ${mem_gb} GB: ${tier} (local-models table)"
else
  dgpu=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -m1 -E 'Chip|VRAM' | sed 's/^ *//')
  warn "Intel Mac — non-unified, VRAM-bound ceilings (local-models Intel section); display: ${dgpu:-unknown}"
fi
swap_used_kb=$(sysctl -n vm.swapusage 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="used"){print $(i+1)}}' | tr -d ',' )
if [ -n "${swap_used_kb:-}" ] && [ "$swap_used_kb" -ge 4194304 ] 2>/dev/null; then
  warn "swap active (~$((swap_used_kb/1048576)) MB used) — long local runs may page; close other heavy work"
else ok "swap quiet enough for local inference"; fi
if command -v lsof >/dev/null 2>&1; then
  owner=$(lsof -nP -iTCP:11434 -sTCP:LISTEN 2>/dev/null | tail -n +2 | head -1 | awk '{print $1}')
  case "${owner:-}" in
    "") ok "port 11434 free (no local model server up yet)";;
    ollama) ok "11434 served by ollama";;
    *) warn "11434 held by unexpected process '${owner}' — confirm ownership before killing";;
  esac
else warn "lsof unavailable — cannot attribute port 11434"; fi
if command -v curl >/dev/null 2>&1 && [ -n "${http_proxy:-}${HTTP_PROXY:-}${https_proxy:-}${HTTPS_PROXY:-}" ]; then
  if curl -sS --max-time 5 https://example.com >/dev/null 2>&1; then
    ok "proxy env set and reachable"
  elif curl -sS --max-time 5 --noproxy '*' https://example.com >/dev/null 2>&1; then
    warn "proxy vars block tooling but bypass works — unset them or point at the real proxy"
  else fail "no reachability even without proxy — check network/firewall"; fi
elif command -v curl >/dev/null 2>&1; then
  curl -sS --max-time 5 https://example.com >/dev/null 2>&1 && ok "external reachability fine (no proxy vars)" || warn "example.com unreachable — inspect egress before blaming config"
else warn "curl missing — skipping connectivity probe"; fi
dfree_gb=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2{print int($4/1048576)}')
[ "${dfree_gb:-0}" -ge 10 ] && ok "disk: ${dfree_gb}G free under \$HOME" || warn "disk: only ${dfree_gb:-?}G free — defer model pulls"
if command -v brew >/dev/null 2>&1 && command -v launchctl >/dev/null 2>&1; then
  launchctl print "gui/$(id -u)/homebrew.mxcl.ollama" >/dev/null 2>&1 && ok "ollama registered with launchd (brew services)" || warn "ollama not registered with launchd (brew services start ollama)"
else warn "brew/launchctl absent — cannot check service registration"; fi
exit $((fails > 0))
