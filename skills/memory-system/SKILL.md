---
name: memory-system
description: Wire durable global and project memory for coding agents. Use when preferences, corrections, or failure modes should survive compaction and sessions.
license: Apache-2.0
---

# Memory System

Token budget: two `MEMORY.md` files loaded via config `instructions`; skills and history stay out until referenced.

- Global `~/.config/opencode/MEMORY.md` (autonomous writes: standing prefs, repeated pitfalls, arch constraints).
- Project `.opencode/MEMORY.md` (propose before writing — lands in user repo).

opencode.json: `"instructions": ["~/.config/opencode/MEMORY.md", ".opencode/MEMORY.md"]`. Never store transient branch state, row counts, or one-off details. Project rules may add repo `AGENTS.md` on top; global discovery takes first of `AGENTS.md` → `CLAUDE.md`.

Quality gate: after a compaction/clear, the agent recalls the stored preference without re-asking.
