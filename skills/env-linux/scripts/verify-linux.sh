#!/usr/bin/env bash
# Verify native-Linux agent prerequisites. Prints OK/WARN/FAIL; exits 1 on any FAIL.
set -u
fails=0
ok(){ echo "OK   $1"; }
warn(){ echo "WARN $1"; }
fail(){ echo "FAIL $1"; fails=$((fails+1)); }
[ "$(uname -s)" = "Linux" ] || { warn "not Linux ($(uname -s)) — use the skill for your OS instead"; exit 0; }
grep -qi microsoft /proc/version 2>/dev/null \
  && { warn "this looks like WSL — use env-wsl / verify-wsl.sh instead"; exit 0; }
found_pm=0
for pm in apt dnf pacman zypper; do
  if command -v "$pm" >/dev/null 2>&1; then ok "package manager: $pm"; found_pm=1; break; fi
done
[ "$found_pm" = 1 ] || fail "no known package manager (apt/dnf/pacman/zypper)"
command -v git >/dev/null 2>&1 && ok "git present" || warn "git missing"
if command -v docker >/dev/null 2>&1; then
  docker info >/dev/null 2>&1 && ok "docker engine reachable" || warn "docker binary present but engine unreachable"
  id -nG | grep -qw docker && ok "user in docker group" || warn "not in docker group (sudo usermod -aG docker \$USER)"
else warn "docker not installed"; fi
command -v systemctl >/dev/null 2>&1 \
  && ok "systemd available — user units possible" \
  || warn "no systemd (container/minimal) — tmux/screen fallback per references/systemd-units.md"
case "${SHELL:-}" in
  */bash|*/zsh|*/fish) ok "shell: ${SHELL##*/}";;
  *) warn "SHELL unset or unusual (${SHELL:-unset})";;
esac
exit $((fails > 0))
