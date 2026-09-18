# agent-workshop — repo instructions for coding agents

This repo builds **agent skills**, not an app. Each skill is `skills/<name>/SKILL.md` (+ optional `scripts/`, `references/`).

## Prime directive

Code quality and low token usage are **horizontal invariants** for the whole repo core: every skill, script, template, doc, installer path, and generated file obeys them.
They are not a separate vertical module and not an optional focus area.
Any change that grows context without measured quality gain is a regression.

## Rules

- Skill frontmatter: `name` (== dirname, `^[a-z0-9]+(-[a-z0-9]+)*$`, 1–64 chars) + `description` (what + when, 1–1024 chars). Optional: `license`, `metadata`.
- Body < 500 lines and ideally < 60; heavy content goes to `references/`, deterministic code to `scripts/`.
- Each skill states its token budget (what stays out of context by default) and its quality gate (how to verify it worked — never "should work").
- Docs, templates, and scripts are held to the same invariant: minimal, executable, no filler lines; prefer references/scripts over prose; installer paths stay idempotent and verifiable.
- Never commit secrets. Keys live in env files, never in repo.
- Keep `README.md`, `templates/`, `scripts/`, `docs/quality-token-contract.md` consistent with any skill change.
- Validate with `python3 scripts/validate-skills.py` before finishing; also run `python3 scripts/check-profiles.py` when touching profiles docs, onboard, env skills, or detect-env.sh.
- Skill authoring rules live in `docs/skill-authoring-standard.md` (description craft, body discipline, eval-gated promotion).

## Agent skills

### Issue tracker

Issues live as local markdown under `.scratch/<effort>/`; see `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at root; see `docs/agents/domain.md`.
