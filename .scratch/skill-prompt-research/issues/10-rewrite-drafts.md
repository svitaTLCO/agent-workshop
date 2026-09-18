# Write diff-ready rewrite drafts for the corpus

Type: task
Status: resolved
Blocked by: 08

## Question

Author full replacement SKILL.md drafts for every skill with gaps (plus the template), grounded in the gap analysis and citing the SOTA findings each change relies on. Constraints: pass `validate-skills.py`; preserve each skill's honest `Token budget:` / `Quality gate:` declarations (updated, not copied blindly); stay inside the prompt-material boundary (no scripts/ code); obey the repo style — minimal, no filler, and no token growth without intended quality gain. Store drafts where the spec assembler (12) will find them; link from this ticket.

## Answer

Resolved 2026-09-17. All 14 targets had gaps, so all 14 got full replacement drafts (13 SKILL.md + template), plus 2 reference files whose prose was gap-flagged: `env-macos/references/capability-matrix.md`, `skill-creator/references/checklist.md`.

**Location:** `.scratch/skill-prompt-research/drafts/` mirroring the `skills/` layout one-for-one, so any pair diffs directly (`diff skills/<p> .scratch/skill-prompt-research/drafts/<p>`):

- `drafts/{agent-onboard,context-diet,env-detect,env-linux,env-macos,env-windows,env-wsl,local-models,mcp-essentials,memory-system,quality-gates,shell-rtk,skill-creator}/SKILL.md`
- `drafts/skill-creator/template/SKILL.md`, `drafts/skill-creator/references/checklist.md`
- `drafts/env-macos/references/capability-matrix.md`

**Grounding** (gap-analysis FINDINGS tags → survey tags): every edit closes a numbered gap or cross-corpus pattern from the 08 FINDINGS doc. Corpus-wide moves: CP1 non-trigger clauses added to all 13 descriptions (near-miss pairs made decidable: mcp-essentials↔context-diet split decision vs mount, memory-system↔context-diet split store vs shrink, local-models↔env-* split model pick vs daemon/setup, env-windows↔env-wsl declared as a pair via profile `windows-wsl`, quality-gates yields to task-specific skills, agent-onboard excludes single-piece installs, shell-rtk excludes interactive TTY/filter-debugging, env-detect adds probe-once counter-indication). CP2 parity lines standardized on one shared sentence across env-linux/macos/wsl. CP3 triplication resolved by designating the `local-models` table the single source for RAM tiers — `capability-matrix.md` drops its divergent ladder and defers tier numbers there, keeping only Mac-specific detection/MLX/VRAM caveats; env-macos body now points to it instead of restating a third ladder. CP4 selection-level negatives moved from bodies to descriptions (behavioral rules like memory-system's "never store transient state" stay in-body, correctly). agent-onboard CN triggers promoted into the frontmatter (S1/A1) and the duplicated body trigger list deleted; uncited metric lines removed (context-diet evidence line, mcp-essentials eval claim); shell-rtk cheat-sheet fence changed `bash`→`text` so `|` can't read as pipelines; quality-gates step 4 converted to imperatives + gained an evidence-shape exemplar; env-detect inline output spec compressed to key names with the script as shape contract.

**Constraints check (verified, not assumed):**
- Spec compliance: mirror of `scripts/validate-skills.py` run over the drafts tree (template excluded exactly as the prod glob does) — 13/13 valid, zero errors (`/tmp/opencode/validate-drafts.py`). Descriptions 269–511 chars, all ≤1024, all under CC's 1536-char per-entry truncation.
- Token budget / Quality gate: present and positionally P3-compliant in every draft (top/bottom, never mid-body); QGs preserved verbatim except skill-creator's, which now also requires the checklist be ticked.
- Boundary: no `scripts/` touched; references edits are prose-only.
- Size deltas (desc chars / body lines): agent-onboard +236/-2, context-diet +229/-2, env-detect +120/0, env-linux +107/0, env-macos +75/0, env-windows +92/-9, env-wsl +112/0, local-models +135/0, mcp-essentials +250/0, memory-system +177/+2, quality-gates +138/-3, shell-rtk +105/+2, skill-creator +100/+2; capability-matrix.md -5 lines. Description total 3014→4890 chars (+1876), still under Codex's 8,000-char list floor with margin. The always-loaded tier grew ~62% — deliberately, since CP1 makes the frozen suite's near-miss/control scenarios undecidable otherwise; the harness (tickets 06–07, 11) adjudicates whether each skill's delta pays back per-skill, and any net-negative description is a candidate for re-compression at 11.
- Facts preserved: no model facts invented — the merged 16 GB/32–48/64+ rows are unions of the two pre-existing tables' entries, tagged `Tags dated 2026-09` to fix the registry-vs-inline-tag inconsistency.

**Known residuals (out of this ticket's boundary):** RTK cheat-sheet duplication with global `~/AGENTS.md` (outside corpus) left in place for self-contained external installs; agent-onboard's `docs/compatibility.md` / `docs/profiles.md` pointers kept (repo-local single sources of truth — moving them into the skill folder would duplicate, violating A6 less than it violates CP3); validator blind spots (template escaping the glob, position not asserted) unchanged — validator edits belong to a later effort if 12 promotes them.
