# Skill-prompt rewrite spec — findings & promotion recommendation

Assembled at ticket 12 (2026-09-17). Round-1 drafts **fail the adoption test** (0/10 units); this spec records what was measured, why it failed, and the options tabled for the human decision at ticket 13.

## Evidence base (citation key)

| tag | source |
|---|---|
| `T-nn` | `.scratch/skill-prompt-research/issues/nn-*`.md → its `## Answer` section |
| `RUN <id>` | `eval/runs/<id>/` — committed `manifest.yaml`/`results.jsonl`/`summary.md`, gitignored `raw/`; rescore-verified (`eval/run.py score`) |
| `ART` | `.scratch/skill-prompt-research/adjudication/trial-deltas-units.json` |
| `SOTA` | `research/sota-survey` @`dc9a7ef` `FINDINGS.md` (ticket T-02); its `[F n]` tags cite numbered sources 1–16 in that file; `[I]` = its inference |
| `LANE` | `research/local-lane-probe` @`333c12d` `FINDINGS.md` (ticket T-03) |
| `GAP` | `research/gap-analysis` @`efdfe22` `FINDINGS.md` (ticket T-08): per-target gaps + CP1–CP8; its tags cite SOTA bullets |

Runs inventory: `smoke-001`, `ovr-demo`, `baseline-001` (live corpus anchor), `t1-pair-{evwsl,lmelm,cdm}-001`, `t1-cdm-nm6-retry-001`, `t1-solo-{agentonboard,envdetect,envlinux,qualitygates,shellrtk,skillcreator}-001`, `post-final-001` (draft, full), `post-final-galene-001` (draft, 16-scenario subset). Final spend ledger `eval/spend.log`: **azure 853/1,500 · galene 86/100** [FACT — T-11]. Suite frozen sha256 `8c261a1d…f44e32` (Q7 amendment `q7-amendment.patch`); any further edit invalidates comparability and needs a fresh Baseline + human approval [FACT — T-04 Q7, T-05].

## 1. SOTA findings (summary)

From `SOTA` §1–§3; primary citations live in that file's Sources list.

| theme | finding | basis |
|---|---|---|
| Trigger surface | Description is the sole selection input; body loads only after selection, so triggers placed in bodies cannot influence selection | FACT `[F 1,2,5,8]` |
| Trigger craft | Concrete user-phrasing keywords, primary use case first; deliberately assertive phrasing counters documented under-triggering bias | FACT `[F 2,3,5,8]` |
| Scope boundaries | Encode negatives ("when NOT to trigger") in descriptions; nearest near-misses make top priority | FACT `[F 8]` + corpus application `[I]` |
| Host budgets | Hard list budgets: CC truncates entries at 1,536 chars; Codex caps the whole list at ≤2% of context or 8,000 chars and shortens first; spec caps description at 1,024 chars → front-load WHAT/WHEN + trigger words | FACT `[F 2,5,8]` |
| Body discipline | Loaded bodies persist across turns ("every line is a recurring token cost"); imperative action-first prose; markdown/XML delimiters reduce parse drift | FACT `[F 2,7,10]` |
| Deterministic work | Repeated verbatim steps belong in code (Anthropic) vs instructions-over-scripts (OpenAI) — contested default; corpus data decides | FACT both positions `[F 3,8]` |
| Eval-driven authoring | Positives + near-misses + no-skill controls, repeated runs (selection stochastic), train/tune + held-out accept, objective assertions | FACT `[F 3,8,11]` |
| Phrase fragility | Up to 61.8% performance drop under subtle paraphrase (IFEval++, 46 models; single recent study — direction firm, magnitude model-dependent) | FACT `[F 12]` |
| Position decay | Mid-context instructions retained worst; invariants belong at head/tail | FACT `[F 9]` |
| Progressiveness | Name+description always loaded → body on activation → references/scripts on demand; one-level-deep flat references | FACT `[F 1,5,6]` |
| Open gap | No primary source comparing embedding-based vs LLM-based skill *ranking* — selection eval methodology only | FACT `[SOTA §3]` |

Watchlist (not adopted): Record & Replay authoring, reasoning-model guidance shift (vendor-specific, portability unverified), community-corpus mining (unaudited scale evidence) [`[F 7,8,15,16]`, I].

## 2. Per-skill gap analysis

Full detail (14 targets, 40 gaps, strengths, "could not verify") lives in `GAP`; condensed here. Top-5 corpus-wide [FACT — GAP Summary]:

1. **No description carries an explicit non-trigger/scope boundary** (13/13 + template placeholder) — makes all five near-miss pairs undecidable at selection time (`S4,O1,A1,P1`).
2. **Model-sizing data triplicated with diverging rows** (local-models body × env-macos ladder × `capability-matrix.md` × env-wsl notes) — whichever loads first wins.
3. **skill-creator + template propagate gap 1 systematically** — requirements cover structural lint only; keyword front-loading, negatives, 20-query protocol absent.
4. **agent-onboard CN triggers unreachable** (`开箱/初始化/…` in body, which loads post-selection).
5. **memory-system over-promises** — host-neutral description over an opencode-only body.

Per target: highest-impact gap and counts in `GAP` summary table; cross-corpus patterns CP1 (no negative clauses), CP2 (parity boilerplate ×4), CP3 (multi-owned tables), CP4 (negatives in wrong tier), CP5–CP7 (voice compliant, invariant anchoring conformant, references conformant), CP8 (always-loaded tier ≈2.75k chars, fits published budgets with margin) [FACT — GAP Cross-corpus]. Static analysis caveat: rankings predate harness; truncation mechanics are version-specific [FACT — GAP "Could not verify", SOTA M4].

## 3. Rewrite drafts (round 1)

Location: `.scratch/skill-prompt-research/drafts/**`, mirrors `skills/` layout one-for-one — diff any pair directly (`diff skills/<p> .scratch/skill-prompt-research/drafts/<p>`). 14 SKILL.md/SKILL-template files + 2 reference files [FACT — T-10].

Corpus-wide moves [FACT — T-10]: CP1 non-trigger clauses added to all 13 descriptions (decision-vs-mount, store-vs-shrink, model-pick-vs-setup, windows↔wsl pairing, quality-gates yields-to-task-skills); CP2 parity lines standardized; CP3 `local-models` table designated single source for RAM tiers (union of pre-existing entries, dated `Tags dated 2026-09`); CP4 selection-level negatives moved from bodies to descriptions; agent-onboard CN triggers promoted into frontmatter + duplicate body list deleted; uncited metric lines removed; shell-rtk cheat-sheet fence `bash`→`text`; quality-gates step 4 imperativized + evidence exemplar added.

Size delta (desc chars / body lines) [FACT — T-10]: agent-onboard +236/−2 · context-diet +229/−2 · env-detect +120/0 · env-linux +107/0 · env-macos +75/0 · env-windows +92/−9 · env-wsl +112/0 · local-models +135/0 · mcp-essentials +250/0 · memory-system +177/+2 · quality-gates +138/−3 · shell-rtk +105/+2 · skill-creator +100/+2; catalog total 3,014→4,890 desc chars (still under Codex's 8k floor; ~62% deliberate growth). Constraints verified [FACT — T-10]: mirror of `validate-skills.py` 13/13 valid; Token-budget/Quality-gate present and P3-positioned; QGs preserved verbatim except skill-creator's; no facts invented.

**Round-1 verdict: none of this paid back.** Measured outcome in §4.

## 4. Verification protocol & measured results

### Protocol (locked T-04, policy T-09)

Direct single structured selection call per trial scenario (system = pinned template T + neutral `- name: description` catalog; user = verbatim frozen prompt); `temperature=0`, `max_completion_tokens=256`, `response_format json_object`, identical both rulers [FACT — T-04 Q1]; R=5 (noise floor ≈0 at pin; repeats = drift detection); ruler = pinned `gpt-5.4` Azure deployment, second lane `Galene/LLM` via 127.0.0.1:8787 as **non-blocking robustness on the final full-corpus pass only** [FACT — T-04, T-09]; hard campaign abort at 1,500 azure / 100 galene calls counting every run kind [FACT — T-04 Q3]; cost = raw `usage` + calibrated **material tokens** = prompt − wrapper constant (azure 77 / galene 123, pinned per manifest `RUN baseline-001/manifest.yaml`); verdicts computed on deltas (post − Baseline); strict majority >R/2, non-unanimous flagged UNSTABLE (`!`); layer-tiered trial design (pair units for the 4 collision pairs, template on structural proxy gate without model runs); adoption bar = either-axis gain without regression [FACT — T-09]. Storage: committed manifests/results/summaries + gitignored raw [FACT — T-06].

### Baseline (live corpus, `RUN baseline-001`, 280 calls, zero errors)

| axis | result [FACT — T-07] |
|---|---|
| positive (42) | 39/42 — only miss: template-skill 0/3 (shadowed by skill-creator 5/5 on all three) |
| near-miss (8) | 7/8 — `scn-nm7` false-positive: quality-gates fires on a no-quality-gate task |
| control (6) | 5/6 — `scn-ctl1`: quality-gates selected on a pure no-skill prompt |
| overall | **51/56 (91.1%)**; all 56 unanimous 5/5 (zero UNSTABLE) |
| cost anchor | **737 material tok/call** (median 737.0, max 747); completion ~13/call, 0 reasoning |

Three deterministic bit-stable defects define what round 1 had to move.

### Post-trials delta (draft corpus, `RUN t1-*` + `post-final-001` + `post-final-galene-001`; 1,005 trial calls, one 300 s URLError superseded by `t1-cdm-nm6-retry-001`)

| unit | trigger base→post | cost median Δ | verdict | adopt [FACT — ART] |
|---|---|---|---|---|
| pair env-windows↔env-wsl | 12/13 → 12/13 | 736→1204 | NEUTRAL | no |
| pair local-models↔env-macos | 12/13 → 12/13 | 736→1204 | NEUTRAL | no |
| pair context-diet↔mcp-essentials | 13/14 → 13/14 | 735.5→1203.5 | NEUTRAL | no |
| pair memory-system↔context-diet | 13/14 → 13/14 | 735→1203 | NEUTRAL | no |
| agent-onboard | 10/11 → 10/11 | 735→1203 | NEUTRAL | no |
| env-detect | 8/9 → 8/9 | 735→1203 | NEUTRAL | no |
| env-linux | 8/9 → 8/9 | 736→1204 | NEUTRAL | no |
| quality-gates | 9/11 → 9/11 | 736→1204 | NEUTRAL | no |
| shell-rtk | 8/9 → 8/9 | 736→1204 | NEUTRAL | no |
| skill-creator (+template trio) | 8/12 → 8/12 | 734.5→1202.5 | NEUTRAL | no |

Headline [FACT — T-11, ART]: overall **51/56 → 51/56**, by-kind unchanged (39/42 · 7/8 · 5/6), **zero flips in either direction** across all 56 scenarios; cost **737 → 1205 material tok/call (+468, ≈+63%; max 747→1215)**. All three planted defects persist bit-stably on the draft corpus: `scn-template-p{1,2,3}` still major `skill-creator` (p2 splits 4–1 unit / 3–2 final — same direction, the only non-unanimous scenario in ~1,005 post calls, UNSTABLE-flagged), `scn-nm7` + `scn-ctl1` still select `quality-gates` 5/5 — reproduced identically on galene in the 16-scenario subset (`matches_expected=false` on exactly those five defect scenarios — `scn-ctl1`, `scn-nm7`, `scn-template-p{1,2,3}` — and every row 5/5 agreement between rulers) [FACT — ART `galene_subset`]. Template structural proxy gate (no model runs, per T-09): instantiated throwaway skill from draft scaffold → `validate-skills.py` exit 0 → temp dir removed [FACT — T-11].

Data-quality log [FACT — T-11]: three-way determinism audit passes (Baseline ↔ shared control block ↔ final run, control verdicts identical); every other scenario unanimous; unit-level cost deltas embed whole-corpus catalog growth (each trial call loads the full draft catalog) so they are directional — the corpus-level number is the authoritative cost finding; pre-run estimates printed per guardrail; caps never approached (final 853/1,500 · 86/100).

**What the measurements say:**
- FACT: at temp 0 on `gpt-5.4`, round-1 drafts change no selection among the 56 frozen scenarios despite all 13 descriptions being rewritten (longer + non-trigger clauses; catalog 3,105→5,070 chars).
- FACT: persistence is cross-ruler (galene reproduces the same wrong selections on drafts) — not a single-model quirk.
- INFERENCE (T-11): descriptive additions alone (length + do-NOT clauses) do not move argmax behavior for these prompts; the template stays an indistinguishable placeholder inside `skill-creator`'s territory, and the quality-gates narrowing clause does not overcome its broad existing reach. Round 2 would need behavior-targeting rewrites aimed at the five failing scenarios — and the cost axis must come back down regardless.

## 5. Synthesis & recommendations

Grounding: SOTA says description is the classifier key and authoring is eval-driven (§1); the harness is the eval loop the survey prescribes; round 1 is its first honest output.

**Findings (numbered for ticket 13):**
1. FACT: round-1 description rewrites produced zero measurable trigger movement and +63% per-call cost → prime-directive regression as written; **0 of 10 units adopt**.
2. FACT: the failure mechanism is specific and small — five scenarios, owned by two skill territories (template-skill shadowed by skill-creator; quality-gates over-reach). Everything else in the corpus already resolves correctly at Baseline and remains correct.
3. FACT: the one artifact with positive verification is the **structural template scaffold** (proxy gate passed; its placeholder line now carries keyword-front-load, WHAT/WHEN ordering, and a do-NOT-nearest-sibling slot) [T-10, T-11] — addressing GAP headline #3 (the propagator) without model risk.
4. INFERENCE: cost reduction requires shrinking competing description text (catalog 4,890→back toward 3,014-char regime), i.e. round-2 edits should shorten before they extend; length is currently working against us on every call.
5. FACT/OPEN: the frozen suite has no train/holdout split (SOTA P7 recommends tune-on-train/accept-on-held-out); carving one out now edits the suite → fresh Baseline + human approval required.

**Options for ticket 13 (human decides):**
- **A — Second-round, behavior-targeted drafts**: rewrite only the two failing territories (template-skill vs skill-creator disambiguation; quality-gates scope) with distinct trigger domains and shortened competing text; keep the hard cost ceiling: net per-call material tokens must not exceed Baseline's 737 unless offset by a measured trigger gain. Requires deciding open item 5 first.
- **B — Promote template scaffold only**: land the draft `skills/skill-creator/template/SKILL.md` + checklist changes now (gate-verified, low-risk, closes GAP #3 propagation); record-and-stop on description rewrites. *(Recommended: it is the only empirically supported artifact, costs nothing at selection time beyond a placeholder improvement, and leaves the corpus at Baseline behavior.)*
- **C — Record-and-stop**: archive round 1 as failed; revisit when new evidence appears (e.g. harness v2 instruction-quality metrics, map fog).

Watchlist unchanged (§1). Out-of-sphere follow-ups if promoted: validator blind spots (template escapes `skills/*/SKILL.md` glob; QG position asserted by presence only) and promotion mechanics (docs placement + AGENTS.md wording) — both listed in map "Not yet specified".
