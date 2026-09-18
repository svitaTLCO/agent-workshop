# Run post-enhancement trials and compute deltas

Type: task
Status: resolved
Blocked by: 07, 09, 10

## Question

Run the frozen scenario suite against the rewrite drafts per the verification policy (09), same lanes and repeat counts as the Baseline (07). Compute per-skill deltas (trigger selection, context cost) with the noise context stated, and flag regressions explicitly. Raw runs archived alongside the Baseline.
## Answer

Executed 2026-09-17 per policy 09. Adjudication artifact: `.scratch/skill-prompt-research/adjudication/trial-deltas-units.json` (per-unit gains/losses, unstable flags, cost medians, determinism audits, galene rows). Runs (ruler `gpt-5.4`, R=5, **draft** corpus, frozen suite sha `8c261a1d…`): four pair-tier runs `t1-pair-{evwsl,lmelm,cdm}-001` (the merged cdm run measures the context-diet overlap of pairs 3+4 once; both pair verdicts derive from that shared data), six solo T1 runs `t1-solo-*-001` (skill-creator unit includes the template trio — the only model-measured surface for the template target, which otherwise sits on the structural proxy gate), final full-corpus `post-final-001` (56 × 5 = 280), plus one 5-call retry block `t1-cdm-nm6-retry-001`. Azure trial spend 565 calls → ledger **853/1,500**. Galene non-blocking robustness subset `post-final-galene-001` (16 decision-hinge scenarios × 5 = 80) → ledger **86/100**.

Template structural proxy gate (no model runs, per 09): instantiated a throwaway skill from the draft scaffold into `skills/`, ran the canonical `validate-skills.py` → exit 0 (`ok tmpl-gate-check`), removed the temp dir (`skills/` clean again); the draft placeholder line carries all three required properties (keyword front-load, WHAT/WHEN ordering, do-NOT nearest-sibling slot). Gate passes.

### Result — no unit clears the adoption bar

| unit | trigger base→post | verdict | cost median Δ | adopt |
|---|---|---|---|---|
| pair env-windows↔env-wsl | 12/13 → 12/13 | NEUTRAL | 736→1204 | n |
| pair local-models↔env-macos | 12/13 → 12/13 | NEUTRAL | 736→1204 | n |
| pair context-diet↔mcp-essentials | 13/14 → 13/14 | NEUTRAL | 735→1204 | n |
| pair memory-system↔context-diet | 13/14 → 13/14 | NEUTRAL | 735→1203 | n |
| agent-onboard | 10/11 → 10/11 | NEUTRAL | 735→1203 | n |
| env-detect | 8/9 → 8/9 | NEUTRAL | 735→1203 | n |
| env-linux | 8/9 → 8/9 | NEUTRAL | 736→1204 | n |
| quality-gates | 9/11 → 9/11 | NEUTRAL | 736→1204 | n |
| shell-rtk | 8/9 → 8/9 | NEUTRAL | 736→1204 | n |
| skill-creator (+template trio) | 8/12 → 8/12 | NEUTRAL | 734→1203 | n |

Headline (full corpus, 09's before/after number): **overall 51/56 → 51/56** (positive 39/42, near-miss 7/8, control 5/6 unchanged); **zero flips in either direction** across all 56 scenarios; context cost **737 → 1205 material tokens/call (+468, ≈+63%**, max 747→1215). The three planted Baseline defects persist bit-stably on the draft corpus: `scn-template-p{1,2,3}` still major `skill-creator` (p2 splits 4-1 in the unit run, 3-2 in the final run — same direction, UNSTABLE-flagged, the only non-unanimous scenario in ~1,005 post calls), `scn-nm7` and `scn-ctl1` still select `quality-gates` 5/5 — and on galene too (identical pattern across both rulers in the 16-scenario subset).

**Adoption ruling (explicit): 0 of 10 units adopted.** Trigger axis: flat everywhere; cost axis: grew everywhere with no minimum-% exemption because no demonstrated trigger improvement accompanies the growth — the prime directive makes the round-1 rewrite package a regression as written.

### What the measurements actually say (FACT vs INFERENCE)

- FACT: at temp 0 on `gpt-5.4`, the round-1 drafts change no selection among the 56 frozen scenarios despite all 13 descriptions being rewritten (longer, with non-trigger clauses; catalog 3,105 → 5,070 chars).
- FACT: the persistence is cross-ruler — galene reproduces the same wrong selections on the draft corpus, so this is not a single-model quirk (non-blocking evidence per 09).
- INFERENCE: descriptive additions alone (length + do-NOT clauses) do not move argmax behavior for these prompts; specifically, the template stays an indistinguishable placeholder from `skill-creator`'s territory (both carry meta-placeholder text, neither owns a WHAT/WHEN domain), and the quality-gates narrowing clause does not overcome its broad existing reach. A second drafting round would need *behavior-targeting* rewrites (distinct trigger domains, shortened competing text) aimed at the five failing scenarios, and even then the cost axis must come back down — the current drafts make every one of the 56 calls more expensive.

### Data-quality & deviation log

- One network timeout (URLError @300s) hit `scn-nm6` repeat 5 in the cdm run; the clean 5-repeat retry block supersedes it in adjudication (sequential source precedence recorded in the artifact). No other error rows across 1,005 trial calls.
- Determinism audits all pass: control verdicts identical across Baseline ↔ shared control block (P1 run) ↔ final full-corpus run; every other scenario unanimous except `scn-template-p2` above. The shared-control-block design (controls measured once, referenced by all units) rests on the Q2 determinism decision and is validated by that three-way audit.
- Cost-axis caveat: each unit's cost delta embeds whole-corpus catalog growth (every trial call loads the full draft catalog), so unit-level cost numbers are directional; the corpus-level statement above is the authoritative cost finding.
- Ledger discipline held: every run kind counted (`eval/spend.log`), pre-run estimates printed per 09 guardrail, caps never approached (853/1,500 · 86/100).

Consequence for 12/13: the spec must present round 1 as **failing the adoption test with the mechanism explained**, and 13 puts the choices to the human (second-round behavior-targeted drafts; promote only the structural template scaffold, which passed its gate; or record-and-stop). Raw archive: `eval/runs/{t1-pair-evwsl,t1-pair-lmelm,t1-pair-cdm,t1-cdm-nm6-retry,t1-solo-agentonboard,t1-solo-envdetect,t1-solo-envlinux,t1-solo-qualitygates,t1-solo-shellrtk,t1-solo-skillcreator,post-final,post-final-galene}-001/`.
