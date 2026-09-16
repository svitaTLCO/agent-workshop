#!/usr/bin/env bash
# Idempotent installer: symlink (default) or copy skills into agent discovery paths.
set -eu
SCOPE="--global"; MODE="symlink"; AGENTS="opencode,claude-code,pi,codex"; SKILLS="all"
while [ $# -gt 0 ]; do case "$1" in
  --project) SCOPE="--project";; --global) SCOPE="--global";;
  --copy) MODE="copy";; --agents) AGENTS="$2"; shift;; --skills) SKILLS="$2"; shift;;
  *) echo "unknown $1"; exit 1;; esac; shift; done
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ "$SKILLS" = "all" ]; then SKILLS=$(ls "$ROOT/skills"); fi
echo "scope=$SCOPE mode=$MODE agents=$AGENTS skills=$SKILLS"
command -v npx >/dev/null 2>&1 && HAS_NPX=1 || HAS_NPX=0
if [ "$HAS_NPX" = "1" ]; then
  # Prefer the skills CLI when available (handles 70+ agents automatically)
  # shellcheck disable=SC2086
  for s in $SKILLS; do echo "-> $s (via npx skills)"; done
  echo "Run: npx skills add $ROOT -s $SKILLS $SCOPE"
fi
# Fallback/manual: symlink core .agents path (shared by opencode/claude/pi/codex discovery)
for s in $SKILLS; do
  for base in "$HOME/.agents/skills" "$HOME/.config/opencode/skills" "$HOME/.claude/skills"; do
    mkdir -p "$base"
    if [ "$MODE" = "copy" ]; then rm -rf "$base/$s"; cp -r "$ROOT/skills/$s" "$base/$s"
    else ln -sfn "$ROOT/skills/$s" "$base/$s"; fi
  done
  echo "installed $s"
done
echo "done. In any agent say: init my agent"
