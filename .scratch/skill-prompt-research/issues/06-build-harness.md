# Build harness v1 (trigger selection + context cost)

Type: task
Status: resolved
Blocked by: 04

## Question

Implement `eval/` exactly per the design recorded in 04: runner, metrics, storage, CLI entry. Quality gate: a smoke run over a 2-scenario subset passes on each available lane, raw results land in the agreed storage, reruns overwrite cleanly (idempotent), and the harness declares honest `Token budget:` / `Quality gate:` lines per the repo contract.

## Answer

Built and gated 2026-09-17. Artifacts: `eval/run.py` (single-file CLI: `run` / `score` / `cap`), `eval/README.md` (contract: `Token budget:` raw payloads + per-repeat detail stay out of agent context, only `summary.md`/manifest values are read; `Quality gate:` planted-label smoke + recompute idempotency + `cap` visibility), `eval/.gitignore` (`runs/*/raw/`), committed spend ledger `eval/spend.log`.

Implementation pins, all recorded verbatim in every run manifest: template T (incl. the `%s` catalog slot), suite sha + record count + subset, catalog sha/names/chars + corpus paths, model pins without secrets, R, both hard caps, wrapper constants (azure C0=77 / galene C0=123, empty-catalog provenance under exact T). Selection domain validated per call (anything outside corpus-names ∪ {null} → run-error row). Circuit breaker: 5 consecutive errors → degraded stop (exit 2); cap hit refuses further calls. Rerun on an existing id is a deliberate clean overwrite (spend still counts).

Gate evidence (run `smoke-001`, 2 scenarios × R=3 × both lanes, 12/12 clean calls):

- Planted labels hold on each available lane: `scn-context-diet-p1` verdict `context-diet` 3/3 STABLE-OK on azure **and** galene; `scn-nm7` verdict `quality-gates` 3/3 STABLE-MISS vs expected none — the documented pre-rewrite false-positive reproduced bit-for-bit, i.e. the scorer correctly flags the contended case rather than papering over it. Zero parse/network/out-of-domain error rows.
- Raw landed in agreed storage: 12 payload files in `eval/runs/smoke-001/raw/` (valid JSON incl. `usage`), gitignored via `eval/.gitignore:1`; `manifest.yaml`/`results.jsonl`/`summary.md` tracked; no secret material anywhere in the tree.
- Recompute idempotency: two consecutive `score --id smoke-001` runs → byte-identical `summary.md` (`cmp` clean).
- Clean rerun overwrite: throwaway id `ovr-demo` run twice with different subsets — stale raw payloads gone, results/summary replaced (verified by listing + row count).

Cost axes sanity from the smoke: mean material tokens 734/call (azure) vs 746 (galene) for the live catalog — the ~+58-token galene wrapper offset cancels as designed; galene completion tokens were ~94% reasoning (`1002/1068`), so its cost axis reports raw usage and reasons about material tokens only, matching 04. Cumulative campaign spend after gating: azure 8/1,500, galene 6/100 (all kinds counted, `eval/spend.log`).

Two implementation notes for the record: the recon-era catalog anchor (3,223 chars, 13 entries) measured trailing frontmatter fields through a loose regex; the canonical strict parser yields 3,105 chars for the 14-entry live catalog — per-run manifests now pin the authoritative counts, so the token-ratio anchors remain valid. The Q7-amended suite sha (`8c261a1d…`) is what every run references. No skill-material change was made, so `validate-skills.py` was not in scope this ticket.

Next per map: ticket 07 Baseline (full 56 × R=5 on the pinned `gpt-5.4` ruler ≈ 280 azure calls, within cap).

