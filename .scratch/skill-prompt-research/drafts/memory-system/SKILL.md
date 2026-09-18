---
name: memory-system
description: Wire durable global and project memory (MEMORY.md via opencode `instructions`) so standing preferences and pitfalls persist. Use when preferences, corrections, or failure modes must survive compaction and sessions, or when the agent keeps forgetting repeat context. Do NOT use to shrink bloated context — that is context-diet.
license: Apache-2.0
---

# Memory System

Token budget: two `MEMORY.md` files loaded via config `instructions`; skills and history stay out until referenced.

opencode-specific: this skill wires `~/.config/opencode/MEMORY.md` + `.opencode/MEMORY.md` through `opencode.json`. On other hosts, keep the same two-tier shape but adapt the file paths and config mechanism first.

- Global `~/.config/opencode/MEMORY.md` (autonomous writes: standing prefs, repeated pitfalls, arch constraints).
- Project `.opencode/MEMORY.md` (propose before writing — lands in user repo).

opencode.json: `"instructions": ["~/.config/opencode/MEMORY.md", ".opencode/MEMORY.md"]`. Never store transient branch state, row counts, or one-off details. Project rules may add repo `AGENTS.md` on top; global discovery takes first of `AGENTS.md` → `CLAUDE.md`.

Quality gate: after a compaction/clear, the agent recalls the stored preference without re-asking.
