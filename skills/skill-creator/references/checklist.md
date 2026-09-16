# Skill checklist

- [ ] dirname == `name`, regex `^[a-z0-9]+(-[a-z0-9]+)*$`, 1–64 chars
- [ ] `description` states what + when, 1–1024 chars
- [ ] Body < 500 lines, ideally < 60
- [ ] `Token budget` + `Quality gate` sections present, gate proven with run output
- [ ] `scripts/` executable, no secrets; `references/` for heavy docs
- [ ] `python3 scripts/validate-skills.py` green
- [ ] Install smoke test (project + global) done
