# Map: skill prompt engineering SOTA

## Destination

A sourced spec proving how state-of-the-art prompt engineering applies to skill authoring: per-skill gap analysis of the whole corpus (13 SKILL.md files + skill-creator template), diff-ready rewrite drafts, and a harness verification protocol (trigger selection + context cost, Baseline vs post) measured on a pinned Azure model with the local galene lane as second ruler. Working spec: `.scratch/skill-prompt-research/spec.md`; on approval the standing standard promotes into `docs/` beside `quality-token-contract.md`.

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

## Not yet specified

- Model pinning: pick the ruler from the verified set (`gpt-5.4` family) + repeat counts — decided in "Decide the harness architecture" (local-lane model is settled: `Galene/LLM`)
- Trial spend cap: budget ceiling for Azure runs — once endpoint pricing is known (01)
- Harness v2: a task-completion quality metric — only if gap analysis (08) surfaces claims worth testing beyond trigger/cost
- Promotion mechanics: exact `docs/` placement and the `AGENTS.md` rule wording — once spec content is stable (12)

## Out of scope

- Third-party installed skills under `~/.agents/skills`
- Automatic trigger routing beyond what agent hosts provide natively
- Installer behavior, deterministic code (`scripts/`), `templates/` bootstrap files
