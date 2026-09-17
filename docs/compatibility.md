# Compatibility

Single `skills/` source installs to all agents via `npx skills add` or `scripts/install.sh`.
The adapter table below is the single source of truth; `scripts/install.sh` embeds it and
`scripts/detect-env.sh` implements the same presence probes (`HAS_*` flags).

| agent (aliases) | global skills dir | project skills dir | instruction root | presence signal |
|---|---|---|---|---|
| opencode | `~/.config/opencode/skills/` | `.opencode/skills/` | `AGENTS.md` (+ `CLAUDE.md` shim) | `opencode` binary or `~/.config/opencode` |
| claude-code (`claude`) | `~/.claude/skills/` | `.claude/skills/` | `CLAUDE.md` | `claude` binary or `~/.claude` |
| codex | `~/.agents/skills/` | `.agents/skills/` | `AGENTS.md` | `codex` binary or `~/.codex` |
| pi | `~/.agents/skills/` | `.agents/skills/` | `AGENTS.md` | `pi` binary or `~/.pi` |
| cursor | `~/.agents/skills/` | `.agents/skills/` | `AGENTS.md` | `cursor` binary or `~/.cursor` |
| aider / generic | `~/.agents/skills/` | `.agents/skills/` | `AGENTS.md` | `aider` binary or `~/.aider.conf.yml` |

Selection: `install.sh --agents a[,b] --skills s[,t] --project|--global [--copy]`;
omitting `--agents` auto-detects via the presence signals, falling back to all agents.
Unknown agent/skill names exit non-zero listing valid options. Quality gate: `bash scripts/test-install.sh`.

Notes: Pi natively also reads `~/.pi/agent/skills/` (global) and `.pi/skills/` (project); Codex follows
symlinked skill dirs and scans `$CWD/.agents/skills` up to the repo root. The installer targets the shared
`.agents/skills` so one copy serves codex/pi/cursor/aider. Copy mode stamps `.agent-workshop-installed`
inside each installed dir; re-copying a managed dir is silent, replacing an unmanaged one warns first.

Root `AGENTS.md` is read by Codex/opencode/Pi; `CLAUDE.md` shim points to it — no duplicated config.
OS routing: `env-detect` → `env-wsl` (IS_WSL=1) / `env-macos` (darwin) / `env-linux` / `env-windows`.

`install.ps1` mirrors the same table, validation, auto-detect and `-Project` scope (copy mode only;
symlinks need dev rights). It targets Windows PowerShell 5.1 and has not been executed on a Windows host;
verify: `powershell -File scripts/install.ps1 -Agents opencode -Skills context-diet -Project`, then check
`.opencode\skills` and `.claude\skills` under the cwd.
