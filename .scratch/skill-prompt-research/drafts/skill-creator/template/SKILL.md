---
name: template-skill
description: TEMPLATE — replace this line with the new skill's description: primary use case + trigger keywords first, then the "use when" phrasings, then a do-NOT clause naming the nearest sibling. 1–1024 chars, target ~300.
license: Apache-2.0
---

# Template Skill

First edits: set frontmatter `name` to the directory name and rewrite the description following its own placeholder — `validate-skills.py` rejects a stale `name`, so rename before anything else.

Token budget: this file only. List what stays unloaded (`references/`, `scripts/`) until needed.

Replace with imperative instructions. Keep under 60 lines; keep `Token budget` / `Quality gate` at the top and bottom, never mid-body; link `references/` and `scripts/` as needed.

Quality gate: state the executable check proving it worked (command + expected outcome).
