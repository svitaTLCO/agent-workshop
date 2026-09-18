#!/usr/bin/env bash
# Quality gate for scripts/install.sh: runs in throwaway HOME/PWD and asserts exact effects.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
I="$ROOT/scripts/install.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
ok(){ echo "ok: $1"; }; fail(){ echo "FAIL: $1" >&2; exit 1; }
H="$T/h1"; mkdir -p "$H"
HOME="$H" bash "$I" --agents opencode --skills context-diet --global --copy >/dev/null
[ -d "$H/.config/opencode/skills/context-diet" ] || fail "narrow agent+skill copy target missing"
if [ -e "$H/.claude" ] || [ -e "$H/.agents" ]; then fail "untouched agents were modified"; fi
ok "selection honored (agent x skill x scope, other targets untouched)"
H="$T/h2"; mkdir -p "$H"
HOME="$H" bash "$I" --agents codex,pi,cursor --skills quality-gates --global >/dev/null
[ -L "$H/.agents/skills/quality-gates" ] || fail "shared .agents dedupe failed"
if [ -e "$H/.claude" ] || [ -e "$H/.config/opencode" ]; then fail "dedupe leaked other paths"; fi
ok "shared .agents path deduped across codex/pi/cursor"
H="$T/h3"; mkdir -p "$H"
if HOME="$H" bash "$I" --agents bogus --global >/dev/null 2>"$T/e3"; then fail "unknown agent accepted"; fi
grep -q "valid:" "$T/e3" || fail "unknown-agent error lacks valid list"
if HOME="$H" bash "$I" --agents opencode --skills nosuch-skill --global >/dev/null 2>&1; then fail "unknown skill accepted"; fi
ok "invalid agent/skill rejected with non-zero exit + valid names"
H="$T/h4"; mkdir -p "$H"
snap(){ (cd "$H" && { find . | sort; find -L .claude/skills 2>/dev/null | wc -l; }); }
HOME="$H" bash "$I" --agents claude --skills context-diet --global >/dev/null
[ -L "$H/.claude/skills/context-diet" ] || fail "alias claude did not resolve to .claude/skills"
if [ -e "$H/.agents" ]; then fail "alias claude leaked into shared .agents"; fi
A=$(snap)
HOME="$H" bash "$I" --agents claude --skills context-diet --global >/dev/null
[ "$A" = "$(snap)" ] || fail "double-run drift"
ok "idempotent double-run (alias claude -> claude-code, zero drift)"
H="$T/h5"; P="$T/p5"; mkdir -p "$H" "$P"
(cd "$P" && HOME="$H" bash "$I" --agents opencode,claude-code --skills context-diet --project >/dev/null)
if [ ! -e "$P/.opencode/skills/context-diet" ] || [ ! -e "$P/.claude/skills/context-diet" ]; then fail "--project dirs missing"; fi
if [ -e "$H/.config/opencode" ] || [ -e "$H/.claude" ]; then fail "--project touched HOME"; fi
ok "--project scope writes cwd, HOME untouched"
H="$T/h6"; mkdir -p "$H"
(cd "$T" && env HOME="$H" PATH="/usr/bin:/bin" bash "$I" --global >/dev/null)
if [ ! -e "$H/.agents/skills" ] || [ ! -e "$H/.config/opencode/skills" ] || [ ! -e "$H/.claude/skills" ]; then fail "full-set fallback incomplete"; fi
ok "no agents detected -> full-set fallback"
H="$T/h7"; mkdir -p "$H/.claude/skills/context-diet"
echo kept > "$H/.claude/skills/context-diet/user.txt"
rc=0; HOME="$H" bash "$I" --agents claude --skills context-diet --global --copy >/dev/null 2>"$T/e7" || rc=$?
[ "$rc" = 2 ] || fail "copy mode accepted unmanaged dir (exit $rc, want 2)"
grep -q "refusing to replace unmanaged" "$T/e7" || fail "unmanaged refusal message missing"
[ -f "$H/.claude/skills/context-diet/user.txt" ] || fail "unmanaged dir content deleted"
ok "copy mode refuses unmanaged dirs (exit 2, content preserved)"
H="$T/h8"; mkdir -p "$H"
HOME="$H" bash "$I" --agents claude --skills context-diet --global --copy >/dev/null
echo stale > "$H/.claude/skills/context-diet/stale.txt"
HOME="$H" bash "$I" --agents claude --skills context-diet --global --copy >/dev/null
[ -f "$H/.claude/skills/context-diet/SKILL.md" ] || fail "managed dir not replaced on re-copy"
if [ -e "$H/.claude/skills/context-diet/stale.txt" ]; then fail "stale file survived managed re-copy"; fi
ok "copy mode replaces marked managed dirs"
OUT=$(bash "$ROOT/scripts/detect-env.sh")
for f in HAS_OPENCODE HAS_CLAUDE_CODE HAS_CODEX HAS_PI HAS_CURSOR HAS_AIDER; do
  echo "$OUT" | grep -q "^$f=[01]" || fail "detect-env missing $f"
done
ok "detect-env emits all six HAS_* agent flags"
echo "test-install: all checks passed"
