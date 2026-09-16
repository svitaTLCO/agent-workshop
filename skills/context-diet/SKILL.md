---
name: context-diet
description: Keep AGENTS.md and prompts lean with subtractive context engineering. Use when writing instruction files, when context rots, or before adding MCP servers and docs.
license: Apache-2.0
---

# Context Diet

Token budget: this file only (~25 lines). `references/` and `scripts/` stay unloaded until referenced.

Evidence (2026): maintained context files → 40% fewer errors; 5K targeted tokens beat 100K dumps; one distractor drops precision; models degrade well before 1M tokens.

Rules:

- Budget the window: `AGENTS.md` ≤ 150 lines project, ≤ 80 global. Details → skill `references/`, determinism → `scripts/`.
- Retrieve just-in-time (structural/code search over whole-repo embeddings); offload before summarizing; compact on thresholds (see opencode `compaction.reserved`).
- Smallest tool set: mount only MCP servers the task needs; load groups dynamically.
- Progressive disclosure: frontmatter always loaded → `SKILL.md` on trigger → `references/`/`scripts/` on demand.
- Never grow `AGENTS.md` to "be safe" — that is the context-rot tax.

Anti-patterns: ever-longer instruction files, whole-repo embedding as "context engineering", maxing the window for insurance, mounting every MCP server at once.

Quality gate: the change this skill informs must pass `quality-gates` with fewer context tokens than the naive alternative — quote both numbers or explain why unmeasurable.
