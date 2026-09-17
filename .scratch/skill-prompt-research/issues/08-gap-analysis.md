# Produce the per-skill gap analysis against SOTA

Type: research
Status: resolved
Blocked by: 02

## Question

Apply the SOTA survey findings to the corpus (13 SKILL.md files + skill-creator template): for each skill, enumerate the gaps between its prompt material (frontmatter description, body, references/ prose) and documented best practice, citing the specific finding each gap rests on. Rank gaps by expected impact on trigger selection and instruction clarity. No fixes proposed here — that is ticket 10's job. Deliverable: a FINDINGS doc linked from this ticket.

## Answer

Resolved 2026-09-17 by research subagent. FINDINGS on throwaway branch `research/gap-analysis` @`efdfe22` — `/tmp/opencode/ws-gap-analysis/FINDINGS.md` (181 lines, not committed to main tree). All 14 targets scanned against the survey findings; per-skill gap counts + impact ranking + strengths-to-preserve are in the doc.

Corpus-wide top-5 gaps: (1) no non-trigger/scope-boundary clause in ANY of the 13 descriptions (+template); (2) model-sizing data triplicated with diverging rows (local-models ↔ env-macos ↔ capability-matrix.md); (3) skill-creator + template propagate the description-craft gap (keyword front-loading, negatives, query protocol all absent) into every future skill; (4) agent-onboard CN trigger phrases dead in body (unselectable pre-trigger); (5) memory-system generic multi-agent description over opencode-only body misfires on other hosts. Not verified there: empirical trigger runs (harness ticket), uncited corpus stats left unfetched per offline policy.
