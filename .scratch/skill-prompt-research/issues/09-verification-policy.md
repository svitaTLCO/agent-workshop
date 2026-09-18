# Set the verification policy for rewrite drafts

Type: grilling
Status: resolved
Blocked by: 08

## Question

Full harness verification of every rewrite draft may exceed sensible budget. Decide the policy: which drafts get full pre/post verification (risk-weighted — trigger-layer changes? skills with weak Baseline numbers? the template, whose effect multiplies into every future skill?) versus spot-checked ones, and what delta threshold counts as "improved" given the noise floor implied by the repeat count. HITL decision; record the thresholds.

## Answer

Resolved 2026-09-17 (grilling round; human approved all seven recommendations). The rules below are **R-agnostic**: the noise floor is measured from the Baseline's own repeat splits, so whatever repeat count "Decide the harness architecture" (04) pins does not invalidate this policy.

**Tiers (which drafts run where):**

- **T1 (full)** — draft changes the frontmatter description → affected set = the skill's 3 own positives + near-misses whose cluster documents it as a collision partner + all 6 controls.
- **T2 (light)** — body/references-only, description byte-identical → own 3 positives + controls only. Near-misses are provably unaffected: selection reads frontmatter alone.
- **Bump** — any target scoring <2/3 on its own positives at Baseline is promoted to T1 for its draft regardless of layer.
- **Pair units** — the four documented collision pairs (env-windows↔env-wsl, local-models↔env-macos, context-diet↔mcp-essentials, memory-system↔context-diet) where both members' drafts touch descriptions are verified together: both diffs applied, affected set = union of both skills', verdict attaches to the pair. A half-applied pair would read as spurious regression.
- **Template** — no model runs: structural proxy gate only (instantiation from the new scaffold passes `validate-skills.py` and carries WHAT/WHEN guidance, a negative-clause slot, and keyword-front-load hints). Suite stays frozen — no synthetic 15th target. `skill-creator` takes the normal tiers (it is a corpus member).
- **Final full-corpus run** — after all drafts land, one complete 56-scenario run on the patched corpus: captures cross-draft interactions (supersedes solo/pair verdicts wherever they conflict) and supplies the spec's headline before/after number.
- **Guardrail** — the harness prints a pre-run estimate (scenario-runs × repeats × prompt-token ceiling) and stops above it for approval; the dollar ceiling itself is 04's spend-cap decision.

**Verdict thresholds:**

- Per scenario: majority of R repeats decides. Any scenario split across Baseline repeats is flagged **UNSTABLE** (the measured noise floor — glossary term now in `CONTEXT.md`).
- Unit verdict — **IMPROVED**: scenario-majority correctness up ≥1, down 0, and the gain does not rest solely on flipping an UNSTABLE scenario. **REGRESSED**: net scenario-majority loss. **NEUTRAL**: otherwise.
- **Context cost**: REDUCED = median(post) < median(baseline) AND max(post) ≤ max(baseline). No minimum % — magnitude reported, direction decides. Cost growth is adoptable only alongside a demonstrated trigger improvement (prime directive).
- **Adoption**: adopt iff IMPROVED on trigger OR REDUCED on cost, with the other axis not regressed. `scn-nm7` (contested label) scores as a plain scenario — no exemption.
- **Second lane** (galene @ `127.0.0.1:8787`): non-blocking robustness evidence — local-lane run of the final post-corpus suite only, cited as cross-model generalization. Verdicts stay single-ruler (pinned Azure model).

Scale: baseline 56×R + ~14 units at 9–15 affected scenarios each + final 56×R ≈ 270×R Azure scenario-runs (~1350 at R=5); local-lane runs are free.
