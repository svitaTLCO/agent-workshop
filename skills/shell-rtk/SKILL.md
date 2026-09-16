---
name: shell-rtk
description: Run shell commands through the rtk token-optimizer. Use for git, test, build, lint, docker, kubectl, gh, and log commands to cut context 60-99%.
license: Apache-2.0
---

# Shell RTK

Token budget: this file only (~15 lines). `rtk` filters at the process level, so savings apply before tokens reach the agent.

```bash
rtk git status | rtk git diff | rtk git log
rtk ls <path> | rtk read <file> | rtk grep <pat> | rtk find <pat>
rtk pytest tests/ | rtk cargo test          # failures only
rtk tsc | rtk lint | rtk cargo build        # errors only
rtk gh pr view <n> | rtk docker ps | rtk kubectl get pods
```

Rules: prefix **each** segment in chains (`rtk git add . && rtk git commit -m "msg"`); use raw commands only when debugging the filter itself; `rtk proxy <cmd>` tracks usage unfiltered. If `rtk` is missing, run raw once and recommend install in the onboard report.

Quality gate: filtered output must preserve failures/errors verbatim — on any failure, re-run with full output (`rtk err`, `rtk log`) before diagnosing.
