# Run post-final-001 (trial)

suite `8c261a1d0b4e` (56 records, 56 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 280)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-agent-onboard-p1 | positive | agent-onboard | agent-onboard | 5/5 | OK |
| scn-agent-onboard-p2 | positive | agent-onboard | agent-onboard | 5/5 | OK |
| scn-agent-onboard-p3 | positive | agent-onboard | agent-onboard | 5/5 | OK |
| scn-context-diet-p1 | positive | context-diet | context-diet | 5/5 | OK |
| scn-context-diet-p2 | positive | context-diet | context-diet | 5/5 | OK |
| scn-context-diet-p3 | positive | context-diet | context-diet | 5/5 | OK |
| scn-env-detect-p1 | positive | env-detect | env-detect | 5/5 | OK |
| scn-env-detect-p2 | positive | env-detect | env-detect | 5/5 | OK |
| scn-env-detect-p3 | positive | env-detect | env-detect | 5/5 | OK |
| scn-env-linux-p1 | positive | env-linux | env-linux | 5/5 | OK |
| scn-env-linux-p2 | positive | env-linux | env-linux | 5/5 | OK |
| scn-env-linux-p3 | positive | env-linux | env-linux | 5/5 | OK |
| scn-env-macos-p1 | positive | env-macos | env-macos | 5/5 | OK |
| scn-env-macos-p2 | positive | env-macos | env-macos | 5/5 | OK |
| scn-env-macos-p3 | positive | env-macos | env-macos | 5/5 | OK |
| scn-env-windows-p1 | positive | env-windows | env-windows | 5/5 | OK |
| scn-env-windows-p2 | positive | env-windows | env-windows | 5/5 | OK |
| scn-env-windows-p3 | positive | env-windows | env-windows | 5/5 | OK |
| scn-env-wsl-p1 | positive | env-wsl | env-wsl | 5/5 | OK |
| scn-env-wsl-p2 | positive | env-wsl | env-wsl | 5/5 | OK |
| scn-env-wsl-p3 | positive | env-wsl | env-wsl | 5/5 | OK |
| scn-local-models-p1 | positive | local-models | local-models | 5/5 | OK |
| scn-local-models-p2 | positive | local-models | local-models | 5/5 | OK |
| scn-local-models-p3 | positive | local-models | local-models | 5/5 | OK |
| scn-mcp-essentials-p1 | positive | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-mcp-essentials-p2 | positive | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-mcp-essentials-p3 | positive | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-memory-system-p1 | positive | memory-system | memory-system | 5/5 | OK |
| scn-memory-system-p2 | positive | memory-system | memory-system | 5/5 | OK |
| scn-memory-system-p3 | positive | memory-system | memory-system | 5/5 | OK |
| scn-quality-gates-p1 | positive | quality-gates | quality-gates | 5/5 | OK |
| scn-quality-gates-p2 | positive | quality-gates | quality-gates | 5/5 | OK |
| scn-quality-gates-p3 | positive | quality-gates | quality-gates | 5/5 | OK |
| scn-shell-rtk-p1 | positive | shell-rtk | shell-rtk | 5/5 | OK |
| scn-shell-rtk-p2 | positive | shell-rtk | shell-rtk | 5/5 | OK |
| scn-shell-rtk-p3 | positive | shell-rtk | shell-rtk | 5/5 | OK |
| scn-skill-creator-p1 | positive | skill-creator | skill-creator | 5/5 | OK |
| scn-skill-creator-p2 | positive | skill-creator | skill-creator | 5/5 | OK |
| scn-skill-creator-p3 | positive | skill-creator | skill-creator | 5/5 | OK |
| scn-template-p1 | positive | template-skill | skill-creator | 5/5 | MISS |
| scn-template-p2 | positive | template-skill | skill-creator! | 3/5 | MISS |
| scn-template-p3 | positive | template-skill | skill-creator | 5/5 | MISS |
| scn-nm1 | near-miss | env-windows | env-windows | 5/5 | OK |
| scn-nm2 | near-miss | local-models | local-models | 5/5 | OK |
| scn-nm3 | near-miss | env-linux | env-linux | 5/5 | OK |
| scn-nm4 | near-miss | agent-onboard | agent-onboard | 5/5 | OK |
| scn-nm5 | near-miss | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-nm6 | near-miss | context-diet | context-diet | 5/5 | OK |
| scn-nm7 | near-miss | (none) | quality-gates | 5/5 | MISS |
| scn-nm8 | near-miss | quality-gates | quality-gates | 5/5 | OK |
| scn-ctl1 | control | (none) | quality-gates | 5/5 | MISS |
| scn-ctl2 | control | (none) | (none) | 5/5 | OK |
| scn-ctl3 | control | (none) | (none) | 5/5 | OK |
| scn-ctl4 | control | (none) | (none) | 5/5 | OK |
| scn-ctl5 | control | (none) | (none) | 5/5 | OK |
| scn-ctl6 | control | (none) | (none) | 5/5 | OK |

axes: accuracy control: 5/6 / near-miss: 7/8 / positive: 39/42; prompt 358950 tok; completion 3606 tok (reasoning 0); material 337390 tok (mean 1205 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
