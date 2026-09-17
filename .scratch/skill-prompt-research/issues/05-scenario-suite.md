# Draft and approve the scenario suite

Type: grilling
Status: resolved
Blocked by: 02

## Question

Draft the scenario suite: for each of the 13 skills + template, positive scenarios (realistic task prompts that should trigger the skill), cross-skill near-misses (prompts confusable between similar skills — the env-* quartet is the obvious cluster), and no-skill controls (should trigger nothing). Scenario design informed by the SOTA survey's trigger-evaluation findings.

The human approves the full suite in one gate; afterwards it is frozen — any edit invalidates comparability and forces a re-baseline (map Notes). Output: machine-readable suite file inside `eval/`; its schema defers to the harness design (04), so keep both consistent when 04 lands.

## Answer

Human-approved and frozen 2026-09-17 (`status: frozen:2026-09-17`). Suite: **`eval/scenarios.yaml`**, v1 draft schema (judge-side invocation stays with harness design). Composition: **56 scenarios** = 42 positives (3/target × 14: canonical | paraphrase | edge) + 8 near-misses across 4 collision clusters (env crossfire, onboard↔env-*, context-diet↔mcp-essentials, quality-gates↔generic coding) + 6 no-skill controls. Labels = global argmax over all 14 targets or null. Deliberate contested label: `scn-nm7` expects null on a plain refactor ask — documents quality-gates' over-broad description so baseline false-positive there measures rewrite gain. Near-miss clusters were chosen from the gap analysis's flagged collisions.
