---
name: mcp-essentials
description: Mount the smallest set of MCP servers a running task actually needs — live docs, files, prod errors, repo metadata — fetched at runtime, never pasted into prompts. Use when a task needs live external data and its server set is undecided. Skip filesystem MCP when the host's built-in file tools cover the need. Deciding whether persistent context may grow at all is context-diet's call, not this skill's.
license: Apache-2.0
---

# MCP Essentials

Token budget: this file only. Each server below loads only on demonstrated need — never pre-mount all.

Prefer runtime fetch over prompt paste.

- Docs: fetch current SDK/API docs through Context7 at use time instead of pasting them.
- Files: mount filesystem MCP scoped to needed dirs only, and only if the host lacks built-in Read/Grep/Bash-class file tools.
- Quality/ops: mount Sentry (prod errors), SonarQube (security), Aspire/OpenTelemetry (runtime logs/traces) only when the task inspects live behavior, not just code.
- Rule: start with zero, add one per need, drop when done. Record the set per project in `AGENTS.md` so `agent-onboard` reproduces it.

Quality gate: the task completes with the fewest servers that could satisfy it — each mounted server cited in the final report.
