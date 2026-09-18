# Skill authoring standard

Normative rules for skill prompt material (`name`, `description`, body, `references/` prose) in this repo. Token-budget/quality-gate contract: `docs/quality-token-contract.md`. Evidence base and measured anchors: `.scratch/skill-prompt-research/spec.md` (citations to SOTA sources live there).

## Description (the selection surface)

Selection happens on `description` alone; the body loads only after selection, so nothing in the body can influence it.

- **D1** All selection content lives in the description: primary use case + trigger keywords, "use when" phrasings, and scope boundaries. Never restate triggers in the body.
- **D2** Order: primary use case first, then concrete trigger keywords matching how users actually phrase tasks, then an explicit do-NOT clause naming the nearest near-miss sibling skill.
- **D3** 1–1024 chars, target ~300. Hosts truncate always-loaded lists (Claude Code 1,536 chars per entry; Codex ≤8,000-char list budget), so key content must survive front-truncation.
- **D4** One job per skill. Run an overlap scan against existing descriptions before adding or changing one; resolve collisions via do-NOT clauses or by splitting the job.
- **D5** Descriptions are eval-driven, not vibe-driven: any change to a selection trigger passes § Verification before promotion.

## Body

- **B1** Imperative, action-first: state what to do, with explicit inputs/outputs; give constraints a one-clause reason instead of stacked ALL-CAPS imperatives.
- **B2** ≤60 lines ideal, ≤500 hard. A loaded body persists across turns — every line is a recurring token cost, not a one-time one.
- **B3** Anchor invariants at head/tail: `Token budget` near the top, `Quality gate` at the bottom, never mid-body (mid-context instructions are retained worst).
- **B4** Include one input→output example where output shape matters.

## References & scripts

- **R1** `references/` stay flat, one level deep, small; each file opens with a one-line purpose ("load when …").
- **R2** Promote to `scripts/` only steps that repeat verbatim across runs (deterministic work); keep instructions first elsewhere.
- **R3** Every data table has exactly one source of truth in the corpus; cross-skill duplication is divergence debt — point, don't copy.

## Verification (promotion gate)

Any change affecting selection behavior (descriptions, new skills, collision edits) is measured with the `eval/` harness before promotion:

- **V1** Frozen suite `eval/scenarios.yaml` (sha pinned per run manifest): positives + near-misses + no-skill controls with global-argmax labels. Editing the suite breaks comparability → fresh Baseline + human approval.
- **V2** Ruler = pinned Azure `gpt-5.4` deployment (`temperature=0`, `json_object`, R=5 repeats, strict majority >R/2, non-unanimous flagged UNSTABLE). Second lane = local `Galene/LLM` via 127.0.0.1:8787, non-blocking robustness evidence only.
- **V3** Cost = raw `usage` + calibrated material tokens (prompt tokens − wrapper constant; azure 77 / galene 123). Verdicts on deltas vs the Baseline run, never absolutes. Spend caps: 1,500 azure / 100 galene campaign calls, every run kind counted (`eval/spend.log`).
- **V4** Adoption bar: gain on at least one axis (trigger correctness or context cost) without regressing the other.
- **V5** Measured anchors (`baseline-001`, 2026-09-17): overall 51/56 — positive 39/42, near-miss 7/8, control 5/6 — at 737 material tokens/call. Standing defects the suite holds open: `scn-template-p{1,2,3}` (template-skill shadowed by skill-creator) and `scn-nm7`/`scn-ctl1` (quality-gates over-reach). Any future rewrite must move these.
- **V6** Round-1 lesson (measured 2026-09-17, round-1 drafts): lengthening all 13 descriptions + adding do-NOT clauses produced zero selection movement (51/56 → 51/56, zero flips on both rulers) while raising cost +63% (737 → 1205 material tok/call). Shorten competing text before extending it; net per-call cost may not rise without a measured trigger gain.

## Watchlist (do not adopt yet)

Demonstration-based authoring (Record & Replay); reasoning-model guidance shifts (vendor-specific, portability unverified); community-corpus mining (unaudited scale); embedding-vs-LLM skill ranking (no primary source found). Revisit only when eval data demands it.
