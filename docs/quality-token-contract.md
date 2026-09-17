# Quality–token contract

The repo's promise: **better output, fewer tokens.** This is a cross-cutting invariant for the entire core — skills, scripts, templates, docs, installers, and generated files — not a separate module.

## Token budgets (defaults)

- `AGENTS.md`: ≤ 150 lines project, ≤ 80 global. Over → split into a skill.
- `SKILL.md` body: < 500 lines hard, < 60 ideal. Rest → `references/` (loaded on demand) or `scripts/` (run, not read).
- Skill frontmatter (name + description) is the only always-loaded cost. Descriptions 1–1024 chars, specific enough to trigger correctly and short enough to list dozens.
- Every `SKILL.md` body declares `Token budget` (what stays unloaded by default) + `Quality gate` (the executable check proving it worked); `scripts/validate-skills.py` rejects skills missing either.
- Tool output: `rtk`-filtered by default (failures/errors only). Full logs only on failure, via `rtk log` / `rtk err`.
- MCP: start with zero servers; add one per demonstrated need; drop when done.
- Retrieval: targeted structural search (aim ~5K tokens) over whole-repo dumps. Never pad context "to be safe".

## Quality gates (definition of done)

1. **Reproduce first** (bugs) or **state acceptance** (features) before editing.
2. **Smallest coherent change** — no drive-by refactors; preserve behavior outside scope.
3. **Verify with execution**, never assertion:
   - focused test for the changed path,
   - lint/typecheck/build when on the affected path,
   - broader suite only when blast radius warrants it.
4. **Report evidence**: exact commands + outcomes; pre-existing failures labeled as such. "Should work" is a failure.
5. **Review adversarially**: secrets, error paths, compat, accidental files.

## Measuring

- Quality: gate pass rate, escaped defects, rework turns.
- Tokens: context bytes per task (input), tool-output bytes (use `rtk` savings as proxy), skills loaded per task (fewer = better targeting).
- A change that grows tokens without a measured quality gain is a regression — revert or split it.
