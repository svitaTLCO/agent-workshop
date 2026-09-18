# Skill checklist

- [ ] dirname == `name`, regex `^[a-z0-9]+(-[a-z0-9]+)*$`, 1–64 chars
- [ ] `description`: primary use case + trigger keywords first, explicit do-NOT clause naming the nearest near-miss sibling, 1–1024 chars (target ~300)
- [ ] Overlap scan vs existing skill descriptions done; collisions resolved via do-NOT clauses or job split
- [ ] Body < 500 lines, ideally < 60; imperative prose; `Token budget` + `Quality gate` at top/bottom, never mid-body
- [ ] Positives + near-miss scenarios added to `eval/scenarios.yaml` (respecting the suite freeze)
- [ ] `scripts/` executable, no secrets; `references/` for heavy docs
- [ ] `python3 scripts/validate-skills.py` green
- [ ] Install smoke test (project + global) done
