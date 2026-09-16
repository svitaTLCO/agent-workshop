# Contributing — add your personal army-knife

1. Scaffold: `npx skills init my-knife` or copy `skills/skill-creator/template/`.
2. Place at `skills/<name>/SKILL.md` (`name` == dirname, lowercase-hyphen, 1–64 chars).
3. Frontmatter `description` must say what it does **and when to trigger**.
4. Keep body < 500 lines (ideal < 60); put docs in `references/`, runnable code in `scripts/`.
5. Include `Token budget` + `Quality gate` sections; prove the gate with run output.
6. Run `python3 scripts/validate-skills.py`.
6. Add row to `docs/compatibility.md` if it is OS/agent-specific.
7. PR with: what machine/workflow it optimizes, verification evidence (`doctor` output / before-after tokens).

No secrets in PRs. Installer changes must stay idempotent (safe re-run).
