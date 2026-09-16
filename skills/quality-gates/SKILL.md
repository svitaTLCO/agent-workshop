---
name: quality-gates
description: Apply definition of done and verification ladder to any coding task. Use when implementing, fixing, refactoring, or reviewing — or when output quality is in doubt.
license: Apache-2.0
---

# Quality Gates

Token budget: this file only (~40 lines). Load task-specific skills on demand, not upfront.

## Ladder (in order, stop when the rung doesn't apply)

1. **Acceptance first.** One sentence of done + observable checks. Ambiguous? Ask one focused question, else state the conservative assumption.
2. **Reproduce / baseline.** Bugs: steps + expected vs observed + evidence. Features: smallest scope that satisfies acceptance.
3. **Edit small.** One coherent change; match repo conventions; no unrelated refactors.
4. **Prove by running:**
   - focused test for the changed path,
   - lint/type/build on the affected path,
   - broader suite only with wider blast radius.
5. **Report evidence.** Commands + outcomes; label pre-existing failures; never "should work".
6. **Adversarial pass.** Secrets, error/cleanup paths, compat, accidental files, weak tests.

Quality gate: all applicable rungs green with quoted evidence. Otherwise the task is not done.
