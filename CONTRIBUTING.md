# Contributing — add your personal army-knife

1. Scaffold: `npx skills init my-knife` or copy `skills/skill-creator/template/`.
2. Place at `skills/<name>/SKILL.md` (`name` == dirname, lowercase-hyphen, 1–64 chars).
3. Frontmatter `description` must say what it does **and when to trigger**.
4. Keep body < 500 lines (ideal < 60); put docs in `references/`, runnable code in `scripts/`.
5. Include `Token budget` + `Quality gate` sections; prove the gate with run output.
6. Run `python3 scripts/validate-skills.py` (structural check only, not YAML); also `python3 scripts/check-profiles.py` when touching profiles docs, onboard, env skills, or detect-env.sh; `bash scripts/test-install.sh` + `bash scripts/test-skill-discovery.sh` for installer/discovery changes.
7. Add a bullet to `docs/compatibility.md` noting the skill ↔ OS/agent constraint if it is OS/agent-specific.
8. PR with: what machine/workflow it optimizes, verification evidence (`doctor` output / before-after tokens).

No secrets in PRs. Installer changes must stay idempotent (safe re-run) and never overwrite unmanaged skill directories (refuse with exit 2).
