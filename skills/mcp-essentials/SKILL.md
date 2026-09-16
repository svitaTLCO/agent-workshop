---
name: mcp-essentials
description: Attach the smallest useful MCP set per task. Use when the agent needs live docs, files, prod errors, or repo metadata without pasting blobs into prompts.
license: Apache-2.0
---

# MCP Essentials

Token budget: this file only. Each server below loads only on demonstrated need — never pre-mount all.

Prefer runtime fetch over prompt paste.

- Docs: Context7 (current SDK/API docs — pairs with agent skills; evals show +accuracy, −63% tokens vs stale prompting).
- Files: filesystem MCP scoped to needed dirs only.
- Quality/ops: Sentry (prod errors), SonarQube (security), Aspire/OpenTelemetry (runtime logs/traces for debugging — agent inspects behavior, not just code).
- Rule: start with zero, add one per need, drop when done. Record the set per project in `AGENTS.md` so `agent-onboard` reproduces it.

Quality gate: the task completes with the fewest servers that could satisfy it — each mounted server cited in the final report.
