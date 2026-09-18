# Approve the spec and promote the standing standard

Type: grilling
Status: resolved
Blocked by: 12

## Question

Walk the finished spec with the human: confirm the standing-standard content, its home in `docs/` beside `quality-token-contract.md`, and the one-line `AGENTS.md` rule referencing it without growing bloat; sign off the handoff payload (rewrite drafts + verification protocol) for the execution effort. On approval: promote, then close the map.

## Answer

Human verdict 2026-09-17 (user verbatim: "1. b 2. choose best 3. ok"): (1) **option B** — promote the template scaffold only; (2) standing-standard placement/content at agent's discretion; (3) handoff payload signed off.

**Promoted (B):** `skills/skill-creator/template/SKILL.md` (description placeholder now teaches WHAT/WHEN-first + do-NOT-nearest-sibling format ~300 chars; first-edits rename line; top/bottom invariant positioning) and `skills/skill-creator/references/checklist.md` (description-craft items, overlap scan, eval-suite item respecting the freeze). Both verified self-contained diffs (no dependency on parked description rewrites); `python3 scripts/validate-skills.py` green (13/13) post-promotion; proxy-gate properties already proven at 11 (validator exit 0). All other round-1 draft targets remain parked at `.scratch/skill-prompt-research/drafts/` (record-and-stop per option B).

**Standing standard (my call):** `docs/skill-authoring-standard.md` beside `quality-token-contract.md` — 16 rules in four groups (D1–D5 selection surface, B1–B4 body, R1–R3 references/scripts, V1–V6 eval-gated promotion incl. measured anchors baseline-001 and the round-1 cost/zero-movement lesson) + watchlist; every claim traceable to `spec.md`/runs. One-line pointer added to `AGENTS.md` Rules ("Skill authoring rules live in `docs/skill-authoring-standard.md`"); repo-map entry added to `README.md` docs/ list for consistency. No validator or suite behavior changed.

**Handoff payload (signed off):** `.scratch/skill-prompt-research/drafts/**` (round-1 rewrites, diffable vs `skills/`) + `eval/` harness (`run.py`, frozen `scenarios.yaml` sha `8c261a1d…`, runs `baseline-001`/`post-final-*`) + `adjudication/trial-deltas-units.json` + this spec, handed to a future execution effort whose first job is round-2 behavior-targeted rewrites of the two failing territories (template-skill vs skill-creator; quality-gates scope) under the V6 cost ceiling, or record-and-stop if that effort is never opened.

Map closed below; effort artifacts stay under `.scratch/` untracked-by-default per issue-tracker convention.
