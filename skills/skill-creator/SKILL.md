---
name: skill-creator
description: Create a new spec-compliant agent skill with template and lint. Use when adding a personal workflow trick, tool wrapper, or env module to this repo.
license: Apache-2.0
---

# Skill Creator

Scaffold: `npx skills init <name>` or copy `skills/skill-creator/template/SKILL.md`.

Requirements (agentskills.io spec + opencode discovery):

- Dir `skills/<name>/` with `SKILL.md`; `name` == dirname, `^[a-z0-9]+(-[a-z0-9]+)*$`, 1–64 chars.
- `description`: what it does + when to trigger, 1–1024 chars.
- Body < 500 lines, ideally < 60; extras → `references/`, code → `scripts/`.
- Required sections: `Token budget` (what stays unloaded by default) + `Quality gate` (the executable check proving it worked).
- Validate: `python3 scripts/validate-skills.py`.
- Install test: `npx skills add ./ -s <name> --dry-run` or `./scripts/install.sh --project --skills <name>`.

See `template/` and `references/checklist.md`.

Token budget: this file + the template copy; `references/checklist.md` loads only at review time.

Quality gate: `python3 scripts/validate-skills.py` passes on the new skill and the install test runs clean (`--dry-run` first).
