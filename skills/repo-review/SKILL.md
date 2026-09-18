---
name: repo-review
description: Produce an evidence-backed, decision-ready review of a repository or PR. Use for codebase audits, architecture reviews, security/reliability assessments, and review reports; do NOT use for implementing a requested feature or a narrow bug fix.
license: Apache-2.0
---

# Repository Review

Assess the requested repository or diff and return prioritized findings that a team can act on. Review is read-only: propose changes and verification, but do not edit code unless the user separately asks.

Token budget: load the requested scope, its canonical docs/configuration, and only the code paths needed to substantiate findings. Do not load unrelated trees, full lockfiles, or generic best-practice catalogs.

## Review method

1. State scope, snapshot (commit when available), assumptions, and whether the review is full, focused, or hybrid. Start broad—docs, manifests, entrypoints, tests, CI—then make one targeted pass through material risk boundaries.
2. Infer the product contract from repository evidence. Honor ADRs and documented constraints; call out an apparent conflict rather than silently overriding it.
3. Trace representative entrypoints end-to-end (HTTP, CLI, job, queue, as applicable). Check validation, authorization, errors, timeouts/retries, data boundaries, observability, and recovery.
4. Evaluate only applicable concerns: correctness, security/privacy/supply chain, reliability/data integrity, performance, operability, maintainability, portability, accessibility/UX, and cost. Use version-aware conventions from the detected stack rather than a universal checklist.
5. Try to disprove material findings with an independent check. Run safe, canonical static analysis or tests when available; label unrun or inconclusive checks precisely. Never claim runtime behavior from source alone.

## Evidence and severity

- Cite substantive claims as `[E#] path:line` (plus commit when known), with a short relevant excerpt or command result.
- P0 requires direct exploit/correctness evidence and two independent confirmations. Otherwise downgrade it and explain the missing proof. P1 should have direct evidence and a proportionate verification plan; sample P2 patterns.
- Distinguish confirmed findings, inferences, and unknowns. Do not expose secrets or reproduce sensitive values.

## Deliverable

Lead with a TL;DR: P0/P1/P2 counts, highest-risk area, and first actions. For each material finding include severity, impact, evidence, minimal proposed diff or snippet, alternatives/trade-offs, rollback or migration notes when impactful, verification commands, residual risk, and confidence.

Include only sections justified by the repo and request: stack/intent summary, best-practice gaps, E2E trace and sequence diagram for a critical journey, user-journey checks, debt or deprecation register, doc mismatches, and roadmap. Use a Mermaid architecture diagram when relationships are otherwise unclear; do not add decorative diagrams. In PR mode, prioritize changed lines and immediate dependencies while noting system-level risk.

Before finalizing, check that evidence supports every severity, recommendations do not contradict ADRs or one another, and proposed verification is executable in the target environment.

Quality gate: a review is complete only when every P0/P1 has evidence, an appropriate independent check or explicit limitation, a testable recommendation, and the final contradiction scan is recorded. Validate this skill with `python3 scripts/validate-skills.py` in the repository's approved runtime.
