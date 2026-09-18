---
name: skill-creator
description: Scaffold a new spec-compliant agent skill in this repo (template, lint, install test). Use when creating a new skill, packaging a workflow, wrapping a tool, or adding an env module. Do NOT use to edit an existing skill — edit its SKILL.md directly.
license: Apache-2.0
---

# Skill Creator

Scaffold: `npx skills init <name>` or copy `skills/skill-creator/template/SKILL.md`.

Requirements (agentskills.io spec + opencode discovery):

- Dir `skills/<name>/` with `SKILL.md`; `name` == dirname, `^[a-z0-9]+(-[a-z0-9]+)*$`, 1–64 chars.
- `description`: primary use case first + concrete trigger keywords (how users actually phrase the request), then an explicit do-NOT clause naming the nearest sibling skill(s). 1–1024 chars, target ~300 — host skill lists are budgeted and truncated, so whatever must survive selection goes first.
- Phrasing: deliberately assertive; hosts under-trigger on timid descriptions. Encode negatives ("when NOT to trigger") wherever a near-miss sibling exists.
- Overlap check before scaffolding: scan existing `description`s for shared trigger words; resolve collisions with a do-NOT clause on the loser side or split the job (one job per skill).
- Body < 500 lines, ideally < 60; extras → `references/`, deterministic code → `scripts/`. Imperative prose; keep invariants (`Token budget`, `Quality gate`) at the top or bottom of the body, never mid-body.
- Required sections: `Token budget` (what stays unloaded by default) + `Quality gate` (the executable check proving it worked).
- Validate: `python3 scripts/validate-skills.py`. Install test: `npx skills add ./ -s <name> --dry-run` or `./scripts/install.sh --project --skills <name>`.
- Eval: add the skill's positives plus near-misses against every sibling named in its do-NOT clause to the eval suite (`eval/scenarios.yaml`). The suite is frozen between Baseline runs — a mid-freeze addition invalidates comparability and requires a fresh Baseline run.

See `template/` and `references/checklist.md`.

Token budget: this file + the template copy; `references/checklist.md` loads only at review time.

Quality gate: `python3 scripts/validate-skills.py` passes on the new skill, `references/checklist.md` is ticked end-to-end, and the install test runs clean (`--dry-run` first).
