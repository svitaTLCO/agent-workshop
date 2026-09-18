# Record the corpus Baseline

Type: task
Status: resolved
Blocked by: 05, 06, 14

## Question

Run the frozen scenario suite against the untouched corpus on both lanes (pinned Azure ruler + local lane) at the agreed repeat count. Produce the Baseline artifact: per-skill trigger-selection scores and context costs, raw runs archived so every number reproduces from stored data. This is the anchor every later delta reports against.
## Answer

Recorded 2026-09-17 as run `eval/runs/baseline-001` (kind `baseline`, live untouched corpus, full frozen suite sha `8c261a1d…`, R=5, single-lane on the pinned ruler `gpt-5.4`: **280 azure calls**, zero error rows, spend ledger now azure 288/1,500 · galene 6/100). Manifest pins template T verbatim, suite/catalog shas, model pin, wrapper constants, caps. Every number below reproduces from the archived `results.jsonl` + `raw/` via `python3 eval/run.py score --id baseline-001` (byte-identical rescores verified twice).

Lane note (deviation from the ticket's "both lanes" wording, resolved by the locked protocol): 04's caps give galene 100 campaign-wide calls — less than one R=5 pass of the 56-suite (280) — and 09 assigns the local lane a non-blocking robustness role on the final full-corpus pass only. The anchor therefore runs on the ruler alone; galene numbers will appear in the 11 trials, never merged into this Baseline.

### Trigger selection (strict majority over R=5; all 56 scenarios unanimous 5/5 — zero UNSTABLE, so the noise floor is empty at Baseline)

| axis | result | detail |
|---|---|---|
| positive (42) | **39/42** | every skill scores 100% on its own positives except `template-skill` **0/3** |
| near-miss (8) | **7/8** | sole miss `scn-nm7` (quality-gates fires on a no-quality-gate task — the planted contended case) |
| control (6) | **5/6** | sole miss `scn-ctl1`: quality-gates selected on a pure no-skill prompt |

Overall 51/56 (91.1%). Per target: agent-onboard 4/4, context-diet 4/4, env-* 3–4/each, local-models 4/4, mcp-essentials 4/4, memory-system 3/3, quality-gates 4/4, shell-rtk 3/3, skill-creator 3/3, template-skill 0/3, (none) 5/7.

Three deterministic, bit-stable defects define what the drafts must move at 11:
1. **Template shadowing**: `scn-template-p1..p3` pick `skill-creator` 5/5 instead of `template-skill` — the generic template description loses every collision with its parent skill (measured proof of gap 08's template finding).
2. **quality-gates over-reach, precision side**: false positives on both a near-miss (`scn-nm7`) and a pure control (`scn-ctl1`); its recall is intact (positives + nm8 all correct).
3. No other bleed: every cross-skill near-miss resolves to the right skill.

### Context cost (anchor values)

Live-catalog cost on the ruler: **material 206,350 tokens / 280 calls = 737 per call** (catalog-dominated; wrapper C0=77 subtracted per protocol); completion 3,610 total (~13/call, reasoning 0 — the ruler emits no reasoning tokens on this structured task). These are the denominators every draft delta reports against at 11.

### Recording notes (honesty log)

- First scoring pass mislabeled unanimous-null verdicts as NO-MAJORITY (tie vs. legitimate null-majority conflation in the scorer): controls read 0/6. Fixed `score_lane`/`write_summary` (explicit `tied` flag; `!` suffix now marks non-unanimous splits), then **re-derived the same archived raw data** — no API calls: controls correctly read 5/6. Smoke-001 data rows were unaffected (only the legend line changed).
- Raw payloads (280 files) are gitignored per `eval/.gitignore`; `manifest.yaml`/`results.jsonl`/`summary.md` are committed-by-contract artifacts ready to be tracked.

Anchor status: valid and reusable for 11 until any of {corpus files, suite yaml, template T, ruler pin} changes — which would require a fresh Baseline plus human approval.

