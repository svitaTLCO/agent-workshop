# agent-workshop

Workshop for building agent skills; vocabulary for the skill-prompt research effort and its measurements.

## Language

**Corpus**:
The 13 SKILL.md files under `skills/` plus `skill-creator`'s template SKILL.md — everything audited and enhanced by this effort.
_Avoid_: inventory, skill set

**Prompt material**:
The text layers an LLM reads when using a skill: frontmatter description, body, and `references/` prose. Deterministic code (`scripts/`) is not prompt material.
_Avoid_: content (too broad), copy

**Trigger layer**:
A skill's frontmatter (`name` + `description`): the always-loaded text that decides whether an agent loads the skill at all.

**Instruction layer**:
The skill body: what the agent reads after loading and follows to act.

## Measurement

**Harness**:
The dedicated evaluation component (top-level `eval/`, never shipped by the installer) that runs the corpus against the scenario suite.
_Avoid_: test suite (collides with installer tests), benchmark

**Scenario suite**:
A fixed set of trial prompts — per-skill positives, cross-skill near-misses, and no-skill controls — used to grade the corpus.

**Trigger selection**:
Harness metric: for a scenario, the agent loads the right skill, or correctly loads none.

**Context cost**:
Harness metric: prompt-material tokens the agent pulls while handling a scenario.

**Baseline**:
Harness readings of the corpus taken before any enhancement; every proposal reports its delta against this.

## Artifact

**Spec**:
The effort's destination artifact: sourced SOTA findings, per-skill gap analysis, concrete rewrite drafts, and the harness verification protocol.
_Avoid_: report (implies no follow-through), plan (implies no findings)
