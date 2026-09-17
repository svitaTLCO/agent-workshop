# Survey state of the art in skill-authoring prompt engineering

Type: research
Status: resolved

## Question

What is current best practice for prompt engineering in the agent-skill authoring domain specifically — writing frontmatter descriptions that achieve reliable trigger selection, writing bodies that direct agent action well, organizing progressive disclosure (body vs references/scripts) — such that skills load correctly and consume minimal context?

Cover:

- Official vendor guidance (Anthropic Agent Skills, Claude Code skills, OpenAI custom instructions/GPTs, equivalents): what they prescribe and why
- Published research bearing on it: instruction following, system-prompt design, retrieval-augmented prompt loading, formatting/few-shot effects
- Established community practice from mature, high-quality skill repositories

Deliverable: a FINDINGS doc linked from this ticket, organized as (1) established practice — multiple independent sources, (2) vendor-specific recommendations, (3) emerging/uncertain — every claim cited with source URLs, plus a clearly labeled Synthesis section applying the findings to this repo's corpus shape (13 short skills, description-triggered, strict token budgets, rtk-filtered tool output). Distinguish FACT from INFERENCE throughout.

## Answer

Resolved by research subagent. Full findings on throwaway branch `research/sota-survey` (`FINDINGS.md`, commit `dc9a7ef`, not pushed). Headlines: the description is the sole trigger surface and hosts hard-budget it (Claude Code truncates at 1,536 chars; Codex at 8k/2% of context) → front-load primary use case and trigger words; models under-trigger, so WHAT/WHEN must be pushy with explicit trigger phrases AND explicit non-triggers; near-miss eval coverage is mandatory (paraphrase variants cut instruction-following up to 61.8%); bodies want imperative action-first structure, input→output examples, delimiters; keep Token budget/Quality gate lines at body top/bottom (lost-in-middle). Synthesis targets ≤200-char descriptions and mirroring skill-creator's 20-query protocol (8–10 positives + 8–10 near-misses, ≥3 runs/query) into the harness design. Dead ends are recorded in the FINDINGS doc.
