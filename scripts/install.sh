#!/usr/bin/env bash
# Idempotent per-agent installer: symlink (default) or copy skills into agent discovery paths.
# Usage: install.sh [--project|--global] [--copy] [--agents a[,b]] [--skills s[,t]|all]
# Agents: opencode, claude-code (alias: claude), codex, pi, cursor, aider. Omit --agents to auto-detect.
# Adapter table mirrored in docs/compatibility.md.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ALL_AGENTS="opencode claude-code codex pi cursor aider"
SCOPE=global MODE=symlink AGENTS="" SKILLS=all
while [ $# -gt 0 ]; do case "$1" in
  --project) SCOPE=project;; --global) SCOPE=global;;
  --copy) MODE=copy;; --agents) AGENTS=${2//,/ }; shift;; --skills) SKILLS=${2//,/ }; shift;;
  *) echo "unknown option: $1" >&2; exit 1;; esac; shift; done
A=""
for a in $AGENTS; do
  if [ "$a" = claude ]; then a=claude-code; fi
  case $a in opencode|claude-code|codex|pi|cursor|aider) A="$A $a";; *) echo "unknown agent: $a (valid: ${ALL_AGENTS// /, })" >&2; exit 1;; esac
done
AGENTS=${A# }
probe(){ if command -v "$1" >/dev/null 2>&1; then return 0; fi; [ -n "${2:-}" ] && [ -e "$HOME/$2" ]; }
if [ -z "$AGENTS" ]; then
  if probe opencode .config/opencode; then AGENTS=opencode; fi
  if probe claude .claude; then AGENTS="$AGENTS claude-code"; fi
  if probe codex .codex; then AGENTS="$AGENTS codex"; fi
  if probe pi .pi; then AGENTS="$AGENTS pi"; fi
  if probe cursor .cursor; then AGENTS="$AGENTS cursor"; fi
  if probe aider .aider.conf.yml; then AGENTS="$AGENTS aider"; fi
  if [ -z "$AGENTS" ]; then AGENTS="$ALL_AGENTS"; fi
fi
if [ "$SKILLS" = all ]; then SKILLS=$(ls "$ROOT/skills")
else
  for s in $SKILLS; do
    [ -d "$ROOT/skills/$s" ] || { echo "unknown skill: $s (valid: $(ls "$ROOT/skills" | tr '\n' ' '))" >&2; exit 1; }
  done
fi
case $SCOPE in global) P=$HOME;; project) P=$PWD;; esac
base_for(){ case "$1/$SCOPE" in
  opencode/global) echo "$HOME/.config/opencode/skills";;
  opencode/project) echo "$PWD/.opencode/skills";;
  claude-code/*) echo "$P/.claude/skills";;
  *) echo "$P/.agents/skills";;
esac; }
M=.agent-workshop-installed
n=0; c=0
while IFS= read -r b; do
  mkdir -p "$b"; c=$((c+1))
  for s in $SKILLS; do
    if [ "$MODE" = copy ]; then
      if [ -d "$b/$s" ] && [ ! -e "$b/$s/$M" ]; then echo "warn: replacing unmanaged $b/$s (move it away first if you edited it)" >&2; fi
      rm -rf "$b/$s"; cp -r "$ROOT/skills/$s" "$b/$s"; touch "$b/$s/$M"
    else ln -sfn "$ROOT/skills/$s" "$b/$s"; fi
    n=$((n+1)); echo "-> [$SCOPE/$MODE] $b/$s"
  done
done <<EOF
$(for a in $AGENTS; do base_for "$a"; done | sort -u)
EOF
echo "installed $n link(s) into $c path(s) for agents: $AGENTS. In any agent say: init my agent"
