#!/usr/bin/env bash
# Verify WSL2 interop health for coding agents. Prints OK/WARN/FAIL; exits 1 on any FAIL.
set -u
fails=0
ok(){ echo "OK   $1"; }
warn(){ echo "WARN $1"; }
fail(){ echo "FAIL $1"; fails=$((fails+1)); }
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  warn "not inside WSL — nothing to verify here (use the native OS skill)"; exit 0
fi
command -v wslpath >/dev/null && ok "wslpath available" || fail "wslpath missing"
[ "$(git config --global core.autocrlf 2>/dev/null)" = "input" ] \
  && ok "core.autocrlf=input" \
  || warn "core.autocrlf not 'input' globally (per-repo .gitattributes may cover it)"
if command -v docker >/dev/null 2>&1; then
  docker ps >/dev/null 2>&1 && ok "docker answers from WSL" || fail "docker unreachable from WSL (Docker Desktop WSL2 backend enabled?)"
else warn "docker not installed"; fi
wslcfg=$(ls /mnt/c/Users/*/.wslconfig 2>/dev/null | head -1)
[ -n "$wslcfg" ] && ok ".wslconfig on Windows side ($wslcfg)" || warn "no C:\\Users\\*\\.wslconfig found (host defaults apply — it lives on the Windows side, not ~)"
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
  ok "nvidia-smi answers (GPU passthrough working)"
else warn "no NVIDIA passthrough (fine if this box has no GPU)"; fi
case ":$PATH:" in */mnt/*) warn "PATH references /mnt (Windows-side binaries may shadow Linux ones)";; *) ok "PATH free of /mnt entries";; esac
exit $((fails > 0))
