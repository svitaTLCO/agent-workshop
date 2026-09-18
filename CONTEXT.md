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

**Trial**:
The R repeat calls of one scenario on one lane (R=5 default), adjudicated by strict majority vote: ties yield no verdict, non-unanimous splits flag the scenario UNSTABLE. (The run *kind* named trial means a run against the post-rewrite corpus.)

**Run**:
One harness invocation over a suite subset on one or more lanes, identified by run-id and stored under `eval/runs/` (committed manifest/results/summary; gitignored raw payloads). Every call of every kind counts toward the campaign caps.

**Lane**:
An evaluation ruler: the pinned Azure deployment `gpt-5.4` (`azure`) or the local galene endpoint `Galene/LLM` (`galene`). Both receive byte-identical canonical requests; readings are never pooled across lanes.

**Material tokens**:
Prompt tokens attributable to task content: measured prompt tokens minus the lane's wrapper constant C0 (tokens consumed by the template and an empty catalog). Isolates corpus cost from fixed framing in cross-corpus comparisons.

**Baseline**:
Harness readings of the corpus taken before any enhancement; every proposal reports its delta against this.

**Noise floor**:
Measured trial instability: a scenario split across Baseline repeats is UNSTABLE; a gain resting solely on flipping an UNSTABLE scenario is inconclusive.

**Verdict**:
A rewrite draft's pre/post comparison against the Baseline classified as IMPROVED, NEUTRAL, or REGRESSED.
_Avoid_: result, score

## Artifact

**Spec**:
The effort's destination artifact: sourced SOTA findings, per-skill gap analysis, concrete rewrite drafts, and the harness verification protocol.
_Avoid_: report (implies no follow-through), plan (implies no findings)
