# Map: skill prompt engineering SOTA

## Destination

A sourced spec proving how state-of-the-art prompt engineering applies to skill authoring: per-skill gap analysis of the whole corpus (13 SKILL.md files + skill-creator template), diff-ready rewrite drafts, and a harness verification protocol (trigger selection + context cost, Baseline vs post) measured on a pinned Azure model with the local galene lane as second ruler. Working spec: `.scratch/skill-prompt-research/spec.md`; on approval the standing standard promotes into `docs/` beside `quality-token-contract.md`. **CLOSED 2026-09-17**: human verdict = option B (promote template scaffold only); standing standard promoted to `docs/skill-authoring-standard.md` (+ one-line `AGENTS.md` pointer); round-1 drafts + verification protocol signed off as the execution-handoff payload.

## Notes

- Domain: agent-skill authoring. Prompt material = frontmatter description, body, `references/` prose; deterministic code is outside the boundary.
- Glossary: `CONTEXT.md`. Prime directive binds every artifact (spec, harness, drafts): token growth without measured quality gain is a regression.
- Substrates: pinned Azure model = ruler (verified `gpt-5.4` family on ai-hub-fantuzzi hub, facts in "Secure a working Azure model endpoint for trials"); local galene via `127.0.0.1:8787` = second lane (facts from "Probe the local model lane"; repair lives in "Fix the local lane config for trials").
- Evidence policy: vendor guidance + published research + clearly labeled synthesis; every finding cited; FACT vs INFERENCE distinguished everywhere.
- Suite freeze: once ticket 05 is approved the scenario suite is immutable; any later edit invalidates comparability and requires a fresh Baseline run.
- Skills every session consults: `/grilling`, `/domain-modeling`, `/research`.

## Decisions so far

<!-- one line per resolved ticket: gist + link; detail lives in the ticket -->

- [Survey state of the art in skill-authoring prompt engineering](issues/02-sota-survey.md) — description is the sole trigger surface with host-imposed char budgets (front-load WHAT/WHEN + explicit non-triggers); imperative bodies; near-miss evals mandatory; FINDINGS on `research/sota-survey` @`dc9a7ef`
- [Probe the local model lane (galene via 127.0.0.1:8787)](issues/03-local-lane-probe.md) — usage accounting available, galene upstream healthy (~0.4s warm), but proxy misrouted to a dead upstream → repair graduated to "Fix the local lane config for trials"; FINDINGS on `research/local-lane-probe` @`333c12d`
- [Draft and approve the scenario suite](issues/05-scenario-suite.md) — approved & frozen 2026-09-17: 56 scenarios in `eval/scenarios.yaml` (42 positive / 8 near-miss / 6 control), global-argmax labels; `scn-nm7` deliberately contests quality-gates' over-broad reach
- [Produce the per-skill gap analysis against SOTA](issues/08-gap-analysis.md) — 14 targets scanned vs survey; headline gaps: no non-trigger clause anywhere, triplicated divergent model-sizing tables, template propagating the description-craft gap, body-only triggers; FINDINGS on `research/gap-analysis` @`efdfe22`
- [Secure a working Azure model endpoint for trials](issues/01-azure-access.md) — creds from radix-db-exporter verified; invokable deployments = `gpt-5.4` / `-mini` / `-nano` (live completions + usage captured); env file at `~/.config/agent-workshop/eval-azure.env`; recipe requires `max_completion_tokens`, `temperature=0` ✓, `response_format json_object` ✓
- [Set the verification policy for rewrite drafts](issues/09-verification-policy.md) — layer-tiered runs (description→affected set, body-only→positives+controls), pair units for the 4 collision pairs, template on a structural proxy gate (no model runs), R-agnostic majority-vote verdicts calibrated to Baseline repeat splits (UNSTABLE flag), adoption = either-axis gain without regression, local lane = non-blocking robustness on the final full-corpus run
- [Write diff-ready rewrite drafts for the corpus](issues/10-rewrite-drafts.md) — all 14 targets rewritten at `.scratch/skill-prompt-research/drafts/` (mirrors `skills/`, diffable per file): non-trigger clauses in every description (CP1), `local-models` table made single source for RAM tiers with `capability-matrix.md` deferring (CP3), CN triggers promoted into agent-onboard frontmatter; 13/13 pass a mirror of `validate-skills.py`; desc total 3014→4890 chars (still under Codex's 8k floor) — per-skill payback adjudicated by harness at 11
- [Fix the local lane config for trials](issues/14-fix-local-lane.md) — headroom.service target repointed DeepSeek→`api-tlco.elettra.ai/v1` (one env line + user-service restart); lane now serves `Galene/LLM` end-to-end through 127.0.0.1:8787: `/v1/models` 200, minimal completion 200 with full `usage` (57 prompt incl. ~50-token wrap, reasoning_tokens populated) — usage pass-through upgraded from INFERENCE to verified
- [Decide the harness architecture](issues/04-harness-design.md) — one protocol, two rulers: direct single structured selection call (json_object + temp=0, bit-deterministic on both lanes), v1 = trigger correctness + context cost with zero judge calls, R=5 under a hard 1,500 Azure / 100 galene campaign cap, cost = raw usage + calibrated material tokens (verdicts on deltas), committed run manifests/results/summary + gitignored raw payloads, `eval/README.md` contract; pre-Baseline suite amendment applied and verified (`template`→`template-skill`, suite sha256 `8c261a1d…`)
- [Build harness v1 (trigger selection + context cost)](issues/06-build-harness.md) — `eval/run.py` CLI (`run`/`score`/`cap`) per locked protocol with manifest pinning of T/suite/catalog/pins/C0s/caps; gate passed 2026-09-17 via smoke-001 (both lanes, planted p1 OK + nm7 documented MISS, 12/12 clean), byte-identical rescore, clean rerun overwrite, raw in `runs/<id>/raw/` gitignored; spend ledger live at azure 8/1,500 · galene 6/100
- [Record the corpus Baseline](issues/07-record-baseline.md) — run `baseline-001` on the pinned ruler (live corpus, full 56 × R=5, 280 calls, all scenarios unanimous): positive 39/42, near-miss 7/8, control 5/6 (91.1%); three deterministic defects to move at 11 — template-skill shadowed by skill-creator 0/3, quality-gates false positives on scn-nm7 and scn-ctl1; cost anchor 737 material tokens/call; galene lane deferred to 11's non-blocking role per 04 caps + 09 policy
- [Run post-enhancement trials and compute deltas](issues/11-post-trials.md) — **round-1 drafts fail the adoption test: 0 of 10 units adopted.** Headline 51/56 → 51/56 with zero flips both directions; all three planted defects persist bit-stably on both rulers (template trio → skill-creator, nm7 + ctl1 → quality-gates); cost 737 → 1205 material tok/call (+63%) with no trigger gain = prime-directive regression as written; template structural proxy gate passes (validator exit 0, WHAT/WHEN + do-NOT + keyword-front-load present); adjudication artifact in `adjudication/trial-deltas-units.json`; ledger 853/1,500 · 86/100
- [Assemble the spec](issues/12-assemble-spec.md) — `spec.md` assembled: sourced SOTA summary, condensed gap analysis, draft pointers, full verification protocol with Baseline/post-trials delta tables (catalog 3,105→5,070 chars pinned in manifests; zero flips, +63% cost, defects persist cross-ruler), and synthesis recommending option B (promote template scaffold only; second-round behavior-targeted rewrites optional); pending human verdict at 13
- [Approve the spec and promote the standing standard](issues/13-approve-promote.md) — human verdict 2026-09-17 ("1. b 2. choose best 3. ok"): option B executed — draft `template/SKILL.md` + `references/checklist.md` promoted (validator 13/13 green), standing standard at `docs/skill-authoring-standard.md` with one-line AGENTS.md pointer + README repo-map entry, all other round-1 drafts parked in `drafts/` as the signed-off execution handoff (round-2 territory = template-skill/skill-creator disambiguation + quality-gates scope, under the V6 cost ceiling); map closed


## Not yet specified

- Model pinning: resolved in 04 (ruler = `gpt-5.4`, R=5; second lane `Galene/LLM` non-blocking)
- Trial spend cap: resolved in 04 (hard 1,500 Azure / 100 galene campaign calls, every run kind counts; ledger `eval/spend.log`)
- Harness v2: an instruction-quality metric beyond trigger/cost — v1's adoption rule cannot adjudicate body-level quality claims (09); revisit after the first post-trial round (11) if such claims recur in drafts
- Promotion mechanics: resolved in 13 (`docs/skill-authoring-standard.md` + one-line `AGENTS.md` rule + README repo-map entry)

## Out of scope

- Third-party installed skills under `~/.agents/skills`
- Automatic trigger routing beyond what agent hosts provide natively
- Installer behavior, deterministic code (`scripts/`), `templates/` bootstrap files
