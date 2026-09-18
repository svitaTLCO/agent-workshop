---
name: context-diet
description: Keep AGENTS.md, prompts, and mounted context lean — subtract before adding. Use when instruction files or context grow (AGENTS.md too long), when context rots (stale facts leak, compaction hurts recall), or when deciding whether an MCP server or doc belongs in persistent context at all. Do NOT use to store durable facts (memory-system) or to perform mid-task server mounts (mcp-essentials).
license: Apache-2.0
---

# Context Diet

Token budget: this file only (~24 lines). `references/` and `scripts/` stay unloaded until referenced.

Rules:

- Budget the window: `AGENTS.md` ≤ 150 lines project, ≤ 80 global. Details → skill `references/`, determinism → `scripts/`.
- Retrieve just-in-time (structural/code search over whole-repo embeddings); offload before summarizing; compact on thresholds (see opencode `compaction.reserved`).
- Smallest tool set: mount only MCP servers the task needs; load groups dynamically.
- Progressive disclosure: frontmatter always loaded → `SKILL.md` on trigger → `references/`/`scripts/` on demand.
- Never grow `AGENTS.md` to "be safe" — that is the context-rot tax.

Anti-patterns: ever-longer instruction files, whole-repo embedding as "context engineering", maxing the window for insurance, mounting every MCP server at once.

Quality gate: the change this skill informs must pass `quality-gates` with fewer context tokens than the naive alternative — quote both numbers or explain why unmeasurable.
