# Decide the harness architecture

Type: grilling
Status: resolved
Blocked by: 01, 14

## Question

Fix the design of `eval/` (the harness: top-level component, never shipped by the installer):

- Runner mechanics: how a trial "session" is simulated — direct chat completions with skill frontmatter presented as the host would see it, versus headless agent CLI sessions — and where each stands on fidelity/cost
- Metric formalizations: trigger-selection scoring (positives, cross-skill near-misses, no-skill controls) and the context-cost accounting definition
- Storage layout for raw runs and results
- Reproducibility knobs: model pins (from 01), repeat counts, seeded ordering
- The harness's own `Token budget:` / `Quality gate:` declarations (repo contract)

Inputs: SOTA findings (does published practice prescribe evaluation methods?), Azure facts (01), local-lane facts (03). Resolves as the spec ticket 06 executes. HITL: decisions go to the human in a grilling round.

## Recon (2026-09-17, pre-decision calibration probes — excluded from Baseline and any spend cap)

Five ruler calls (`gpt-5.4`, deployment-pin + api-version from `~/.config/agent-workshop/eval-azure.env`, `temperature=0`, `response_format json_object`, provisional selection template below). All HTTP 200; raw responses at `/tmp/opencode/probe-{c0,p1,p2,p3,p2b}.json` (outside repo, no secrets in them).

FACTS:

- Fixed wrapper constant **C₀ = 77 prompt tokens** (identical template, empty skill catalog, trivial user prompt) → Q4's per-model calibration constant for the Azure lane, measured rather than estimated.
- Live-corpus description catalog = **3,223 chars** (13 skills, name+description bullets); a full trial call consumes **≈885–887 prompt tokens**, i.e. catalog + scenario prompt ≈ 809 material tokens over C₀. Cost model for Q3 is now concrete: 1,500-call ceiling ≈ ≤1.4M input tokens total.
- Structured selection mechanics work: JSON-only replies parsed cleanly on all five calls, ~2 s wall time each; exact-match scoring needs no judge.
- Trial correctness against frozen labels (live pre-rewrite corpus): `scn-context-diet-p1` (positive) → `context-diet` ✓; `scn-ctl2` (control) → null ✓; `scn-nm7` (near-miss, verbatim suite string, re-run once to match the frozen prompt exactly) → `quality-gates` ✗ vs expected null. This is the outcome the suite note predicts verbatim ("baseline false-positive expected here, drop measured after rewrite (gap #5)") — the un-rewritten corpus fails its own deliberate contended label, so the post-trial run has a real regression signal to measure (ticket 10's draft adds the yield-to-task-skill precedence clause to quality-gates' description).

Provisional selection template T (final wording locks into the 06 run manifest; numbers above are directional, not Baseline readings):

```
You are an agent that can load specialized skill instructions by name. Read the user's request. If a listed skill is clearly applicable to the task, select it; if none applies, select nothing. Select at most one skill.

Available skills:
{catalog: "- <name>: <description>" bullets}

Respond with JSON only: {"skill": "<name>"} or {"skill": null}
```

## Recon addendum (2026-09-17 — determinism probe + corpus cost scale; same exclusions apply)

Determinism/noise (five bit-identical replays, same pin, temp=0, json_object; raw at `/tmp/opencode/det-*.json`):

- Raw output **bit-identical across identical replays** (`scn-context-diet-p1` ×3, `scn-nm7` ×2); usage identical too (887/13 and 885/13 pt/ct). Near-term noise floor at this pin ≈ 0 — recorded for Q3/Q4: repeats buy drift detection over time/config, not sampling-average; Baseline repeat splits (ticket 09's UNSTABLE calibration) should read clean.
- Contended label `scn-nm7` reproduces the predicted `quality-gates` false-positive 2/2 on the verbatim string — robust to phrasing.

Corpus cost scale (local, deterministic; all 14 targets; drafts mirror complete incl. `skill-creator/template/SKILL.md`; per-target deltas live in ticket 10's Answer table):

- Descriptions: live 3,157 chars → draft 4,854 chars (**+54%** — the deliberate CP1 purchase); by the measured catalog anchor (~0.251 tok/char) a full-corpus trial call grows from ≈886 to ≈1,300 prompt tokens on the ruler (estimate; exact values come from the Baseline).
- Bodies: live 293 → 263 lines (**−10%**); largest deltas: env-windows −9, quality-gates −3, skill-creator(template) 9→11, memory-system/shell-rtk/skill-creator +2 each.
- Net shape the post-trial run must capture: ~+40% trigger-layer tokens bought against −10% instruction-layer — Q3's budget and Q4's axes have to accommodate exactly this kind of delta.

## Recon addendum 2 (2026-09-17 — capacity, body-cost anchor, frozen-suite strict parse; same exclusions apply)

- **No rate-limit risk** (deployment response headers, raw `/tmp/opencode/rc-hdr.json`): limits 10,000 req/min + 1,000,000 tok/min, renewal period 60 s. The entire proposed campaign (Baselines + post-trials, even at R=5 × both corpora ≈ a few thousand calls) is <50% of one minute's quota — Q3's call cap is purely a spend/budget guard, never a technical constraint.
- **Body-inclusion anchor C₁ shape** (`/tmp/opencode/rc-body.json`): appending the live `context-diet` body (1,189 chars) to a full-catalog trial call costs **+283 prompt tokens** (887→1,170), selection fidelity unchanged — matches the ~0.24 tok/char catalog anchor. Available whenever the v1 scope (Q1/Q2) ever grows past description-only trials.
- **Frozen suite strict parse** (PyYAML, planned runner schema: flat records, scalar-or-list `target`, nullable `expected`): 56 records, unique ids, kinds 42 positive / 8 near-miss / 6 control; prompt sizes 8–103 chars (avg 62 — negligible against the catalog); all 8 near-miss expectation sets internally consistent (7 expect the contended winner, `scn-nm7` expects none, all 6 controls expect none). **One genuine defect found:** `scn-template-p1..p3` carry `target`/`expected` = `template`, but the corpus material's frontmatter name is `template-skill` (`skills/skill-creator/template/SKILL.md`) — the suite's label space and the catalog name space disagree on exactly one target. Exact-match scoring cannot reconcile this without either amending the frozen suite (human approval required by its own freeze governance) or the harness inventing an alias. New pending decision Q7 (below).

## Pending decisions (round 1 posted + Q7 added)

Q1 direct-API single structured selection call · Q2 no judge in v1 (trigger + cost only) · Q3 R=5, hard abort 1,500 ruler / 100 galene calls · Q4 raw usage + calibrated material tokens (verdicts on deltas) · Q5 committed run manifests/results/summary, gitignored raw payloads · Q6 short `eval/README.md` contract (Token budget + Quality gate) · **Q7 label-space fix for the template target — recommendation: pre-Baseline amendment of `eval/scenarios.yaml` changing `scn-template-p{1,2,3}` `target`/`expected` from `template` to `template-skill` plus a dated amendment note under the FROZEN header (zero comparability loss since no Baseline exists yet; alternatively keep the label and have the runner alias the catalog entry — inferior, hides the mismatch)**. Human decides.

## Recon addendum 3 (2026-09-17 — second-ruler feasibility probe on the identical proposed mechanic; local calls, excluded from all caps)

Galene lane (`127.0.0.1:8787`, model `Galene/LLM`) run with the *same* canonical request as the Azure probes (verbatim suite prompts, same template T, live 13-skill catalog, temp=0, `max_completion_tokens`, `response_format json_object`; raw at `/tmp/opencode/gal-*-json`):

- **Mechanic parity confirmed**: the lane accepts the exact same parameters (no per-lane parameter mapping needed); `scn-context-diet-p1` → `context-diet` ✓, `scn-ctl2` → null ✓ — the 27B lane handles the selection task correctly. The "one protocol, two rulers" premise of Q1/Q5 now has evidence on both sides.
- **Lane overhead anchor**: prompt_tokens 944/942 vs Azure 885–887 for byte-identical inputs → ≈+58-token fixed wrapper on this lane (supersedes ticket 03's ~50 estimate for this template); completion 81/80 tokens of which **~88% is reasoning** (visible answer ≈9–10 tokens) — Q4 must report the reasoning breakdown on this lane or completion cost is opaque.
- **Determinism holds here too**: full responses equal modulo `id`/`created`/`system_fingerprint` across repeats (repeat latency 0.02–0.04 s, i.e. cached). Parser note: this lane prefixes content with newlines (`\n\n{"skill": ...}`) — the scorer must strip whitespace before JSON parse.

## Recon addendum 4 (2026-09-17 — failure-mode battery + Q7 artifact staging; 3 ruler calls, excluded from caps)

- **Selection domain is empirically closed** (raw `/tmp/opencode/rb-*.json`): degenerate one-word input → null; ambiguous two-skill request → exactly one valid argmax name; off-domain technical question → null. Across all Azure selection probes so far, no out-of-catalog value, no unparseable payload under temp=0 + json_object. Protocol still mandates defensive rejection (untrusted output) — but raw-row schema can safely assume values ∈ corpus-names ∪ {null} in normal operation; anything else marks a run-error row (feeds Q5/Q6).
- **Q7 amendment staged and pre-verified** at `.scratch/skill-prompt-research/q7-amendment.patch` (1,624 B; 3 label pairs + dated FROZEN-header note). Dry-applied on a throwaway copy: parses clean, 56 records intact, trio targets/expecteds = `template-skill`, strict schema pass. On human approval: `patch -p1 < .scratch/skill-prompt-research/q7-amendment.patch` from repo root. Nothing written to `eval/` yet.

## Answer (2026-09-17 — HITL grilling round 1 + Q7 approved; user verbatim: "1. a 2. deterministic 3. ok 4. ok 5. ok 6. ok 7. ok")

Locked protocol for `eval/` v1 (executed by ticket 06; evidence in Recon addenda 1-4):

1. **Mechanics** — direct chat-completions, one structured selection call per trial scenario. Catalog = live frontmatter `name`+`description` bullets presented neutrally; fixed selection template T (verbatim copy in Recon above, re-pinned into every run manifest); `temperature=0` + `response_format json_object`, identical on both rulers (parity measured). Host wrapper differences absorbed by measured constants: C₀ Azure = 77 prompt tokens; galene ≈ +58 over Azure for byte-identical inputs. Logged known gaps: real-host truncation behavior (our catalogs sit under typical budgets), CLI-session fidelity intentionally out of v1 scope.
2. **v1 scope** — trigger-selection correctness (exact match vs frozen global-argmax labels) + context cost only; **zero judge calls**. Instruction-layer quality claims defer to harness v2 (map fog) if they recur after first post-trials.
3. **Reproducibility & cap** — R = 5 repeats per scenario (noise floor measured ≈ 0 at this pin; repeats serve drift detection); trial order = yaml file order (seeded/deterministic); **hard campaign abort at 1,500 Azure + 100 galene calls**, all run kinds counting (smoke included); deployment quota (10k req/min, 1M tok/min) confirmed non-binding.
4. **Cost accounting** — raw `usage` per call (prompt/completion tokens, reasoning breakdown where exposed) plus calibrated **material tokens** = prompt − model wrapper constant (per-model, pinned in manifest); verdicts computed on **deltas** (post − Baseline), never absolutes; galene lane must report reasoning share (~88% of completions measured).
5. **Storage** — `eval/runs/<run-id>/{manifest.yaml, results.jsonl, summary.md}` committed; raw API payloads in gitignored `raw/`. Manifest pins: model/deployment/api-version, date, template T verbatim, suite SHA, R, caps, run-kind (`smoke` | `baseline` | `trial`). Raw row schema: selected value ∈ {corpus names} ∪ {null}; anything else is a run-error row (defensive rejection stays mandated).
6. **Harness contract** — short `eval/README.md` carrying `Token budget:` (raw payloads + per-scenario traces stay out of context by default) and `Quality gate:` (planted-label smoke + recompute idempotency: rescoring the same `results.jsonl` reproduces `summary.md`).
7. **Q7 applied pre-Baseline**: `eval/scenarios.yaml` amended via staged patch (`scn-template-p{1,2,3}` `template` → `template-skill` + dated FROZEN note); post-amendment suite sha256 = `8c261a1d…f44e32`, strict parse re-verified (56 records, kinds 42/8/6, zero bad labels). Zero comparability loss — no Baseline existed yet.

Downstream bindings: 06 builds exactly this; 07's Baseline is the full suite × R=5 on the ruler (galene lane reserved for the final robustness pass per 09); 11 measures deltas of `.scratch/skill-prompt-research/drafts/` against it.
