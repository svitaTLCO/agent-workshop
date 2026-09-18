# Assemble the spec

Type: task
Status: resolved
Blocked by: 08, 10, 11

## Question

Assemble `.scratch/skill-prompt-research/spec.md`: (1) SOTA findings summary with citations, (2) per-skill gap analysis, (3) diff-ready rewrite drafts (or pointers to them), (4) verification protocol with Baseline/delta tables, (5) synthesis and recommendations. Every claim traceable to a ticket answer or stored raw run. Obey the token invariant — no filler lines.

## Answer

Assembled 2026-09-17 at `.scratch/skill-prompt-research/spec.md` (five sections per the question): (1) SOTA findings table sourced from `research/sota-survey`@dc9a7ef (whose numbered sources 1-16 carry the primary citations); (2) gap analysis condensed from `research/gap-analysis`@efdfe22 (full 40-gap detail stays there); (3) round-1 draft pointers to `.scratch/skill-prompt-research/drafts/**` with T-10's verified size/constraint log; (4) verification protocol (T-04/T-09 locked) + Baseline table (`RUN baseline-001`: 51/56, 737 material tok/call anchor) + post-trials delta tables (`RUN t1-*`, `post-final-001`, `post-final-galene-001`, `ART`: 51/56 → 51/56, zero flips, 737 → 1205 +63%, 0/10 units adopted, all three planted defects persist cross-ruler); (5) synthesis: mechanism of failure (FACT vs INFERENCE split per map Notes), five numbered findings, and options A/B/C tabled for 13 (B = promote template scaffold only, recommended as the sole empirically supported artifact). Every claim carries a citation tag defined in the spec's evidence-base table; all cited run manifests, branch commits, and artifacts existence-checked. No skill-material touched; ledger untouched by this ticket.
