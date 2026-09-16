# Compatibility

Single `skills/` source installs to all agents via `npx skills add` or `scripts/install.sh`:

- opencode: `.opencode/skills/` / `~/.config/opencode/skills/`
- Claude Code: `.claude/skills/` / `~/.claude/skills/`
- Pi / Codex / Cursor / generic: `.agents/skills/` / `~/.agents/skills/`
- Root `AGENTS.md` read by Codex/opencode/Claude/Pi; `CLAUDE.md` shim points to it.

OS routing: `env-detect` → `env-wsl` (IS_WSL=1) / `env-macos` (darwin) / `env-linux` / `env-windows`.
