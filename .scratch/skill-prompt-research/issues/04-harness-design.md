# Decide the harness architecture

Type: grilling
Status: open
Blocked by: 01, 14

## Question

Fix the design of `eval/` (the harness: top-level component, never shipped by the installer):

- Runner mechanics: how a trial "session" is simulated — direct chat completions with skill frontmatter presented as the host would see it, versus headless agent CLI sessions — and where each stands on fidelity/cost
- Metric formalizations: trigger-selection scoring (positives, cross-skill near-misses, no-skill controls) and the context-cost accounting definition
- Storage layout for raw runs and results
- Reproducibility knobs: model pins (from 01), repeat counts, seeded ordering
- The harness's own `Token budget:` / `Quality gate:` declarations (repo contract)

Inputs: SOTA findings (does published practice prescribe evaluation methods?), Azure facts (01), local-lane facts (03). Resolves as the spec ticket 06 executes. HITL: decisions go to the human in a grilling round.
