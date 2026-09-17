#!/usr/bin/env bash
# Verify macOS prerequisites for local coding models. Prints OK/WARN/FAIL; exits 1 on any FAIL.
set -u
fails=0
ok(){ echo "OK   $1"; }
warn(){ echo "WARN $1"; }
fail(){ echo "FAIL $1"; fails=$((fails+1)); }
if [ "$(uname -s)" != "Darwin" ]; then
  warn "not macOS — env-macos does not apply here"; exit 0
fi
chip=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo unknown)
[ "$(uname -m)" = "arm64" ] \
  && { [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = "1" ] && warn "Rosetta x86_64 shell on Apple Silicon (${chip}) — detect-env corrects ARCH; restart agents natively arm64" || ok "Apple Silicon (${chip}) — MLX-eligible"; } \
  || warn "Intel Mac (${chip}) — no MLX acceleration; see references/capability-matrix.md Intel column"
mem_gb=$(( $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1024 / 1024 / 1024 ))
echo "INFO unified memory: ${mem_gb} GB"
if [ "${mem_gb:-0}" -lt 32 ]; then warn "under 32 GB — stay on ≤14B tier per local-models"; fi
command -v brew >/dev/null && ok "brew available" || fail "brew missing (install Homebrew from homebrew.org first)"
if command -v ollama >/dev/null 2>&1; then
  ver=$(ollama --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  major_minor=${ver%%.*}; minor=$(printf '%s' "$ver" | cut -d. -f2)
  if [ -n "$minor" ] && { [ "${major_minor:-0}" -gt 0 ] || [ "$minor" -ge 19 ]; }; then ok "ollama ${ver} (MLX backend)"; else fail "ollama ${ver:-unknown} < 0.19 — upgrade (brew upgrade ollama)"; fi
  curl -fsS http://localhost:11434/api/version >/dev/null 2>&1 && ok "ollama server answering" || warn "ollama server not answering (brew services start ollama)"
else
  warn "ollama not installed — deferring local models is valid"
fi
exit $((fails > 0))
