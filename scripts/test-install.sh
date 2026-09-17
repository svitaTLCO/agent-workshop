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
[ ! -e "$H/.claude" ] && [ ! -e "$H/.agents" ] || fail "untouched agents were modified"
ok "selection honored (agent x skill x scope, other targets untouched)"
H="$T/h2"; mkdir -p "$H"
HOME="$H" bash "$I" --agents codex,pi,cursor --skills quality-gates --global >/dev/null
[ -L "$H/.agents/skills/quality-gates" ] || fail "shared .agents dedupe failed"
[ ! -e "$H/.claude" ] && [ ! -e "$H/.config/opencode" ] || fail "dedupe leaked other paths"
ok "shared .agents path deduped across codex/pi/cursor"
H="$T/h3"; mkdir -p "$H"
if HOME="$H" bash "$I" --agents bogus --global >/dev/null 2>"$T/e3"; then fail "unknown agent accepted"; fi
grep -q "valid:" "$T/e3" || fail "unknown-agent error lacks valid list"
if HOME="$H" bash "$I" --agents opencode --skills nosuch-skill --global >/dev/null 2>&1; then fail "unknown skill accepted"; fi
ok "invalid agent/skill rejected with non-zero exit + valid names"
H="$T/h4"; mkdir -p "$H"
snap(){ (cd "$H" && find . | sort && ls -lL "$H"/.claude/skills/* 2>/dev/null | wc -l); }
HOME="$H" bash "$I" --agents claude --skills context-diet --global >/dev/null
[ -L "$H/.claude/skills/context-diet" ] || fail "alias claude did not resolve to .claude/skills"
[ ! -e "$H/.agents" ] || fail "alias claude leaked into shared .agents"
A=$(snap)
HOME="$H" bash "$I" --agents claude --skills context-diet --global >/dev/null
[ "$A" = "$(snap)" ] || fail "double-run drift"
ok "idempotent double-run (alias claude -> claude-code, zero drift)"
H="$T/h5"; P="$T/p5"; mkdir -p "$H" "$P"
(cd "$P" && HOME="$H" bash "$I" --agents opencode,claude-code --skills context-diet --project >/dev/null)
[ -e "$P/.opencode/skills/context-diet" ] && [ -e "$P/.claude/skills/context-diet" ] || fail "--project dirs missing"
[ ! -e "$H/.config/opencode" ] && [ ! -e "$H/.claude" ] || fail "--project touched HOME"
ok "--project scope writes cwd, HOME untouched"
H="$T/h6"; mkdir -p "$H"
(cd "$T" && env HOME="$H" PATH="/usr/bin:/bin" bash "$I" --global >/dev/null)
[ -e "$H/.agents/skills" ] && [ -e "$H/.config/opencode/skills" ] && [ -e "$H/.claude/skills" ] || fail "full-set fallback incomplete"
ok "no agents detected -> full-set fallback"
H="$T/h7"; mkdir -p "$H/.claude/skills/context-diet"
echo kept > "$H/.claude/skills/context-diet/user.txt"
W1=$(HOME="$H" bash "$I" --agents claude --skills context-diet --global --copy 2>&1 >/dev/null)
grep -q "warn: replacing unmanaged" <<<"$W1" || fail "copy mode silent on unmanaged dir"
W2=$(HOME="$H" bash "$I" --agents claude --skills context-diet --global --copy 2>&1 >/dev/null)
grep -q "warn:" <<<"$W2" && fail "marker did not silence managed re-copy"
[ -f "$H/.claude/skills/context-diet/SKILL.md" ] || fail "managed target not replaced"
ok "copy mode warns on unmanaged dirs only (marker marks managed)"
OUT=$(bash "$ROOT/scripts/detect-env.sh")
for f in HAS_OPENCODE HAS_CLAUDE_CODE HAS_CODEX HAS_PI HAS_CURSOR HAS_AIDER; do
  echo "$OUT" | grep -q "^$f=[01]" || fail "detect-env missing $f"
done
ok "detect-env emits all six HAS_* agent flags"
echo "test-install: all checks passed"
