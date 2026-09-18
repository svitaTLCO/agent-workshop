# Run post-final-galene-001 (trial)

suite `8c261a1d0b4e` (56 records, 16 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## galene (calls 80)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-context-diet-p1 | positive | context-diet | context-diet | 5/5 | OK |
| scn-env-macos-p1 | positive | env-macos | env-macos | 5/5 | OK |
| scn-env-windows-p1 | positive | env-windows | env-windows | 5/5 | OK |
| scn-env-wsl-p1 | positive | env-wsl | env-wsl | 5/5 | OK |
| scn-local-models-p1 | positive | local-models | local-models | 5/5 | OK |
| scn-mcp-essentials-p1 | positive | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-memory-system-p1 | positive | memory-system | memory-system | 5/5 | OK |
| scn-quality-gates-p1 | positive | quality-gates | quality-gates | 5/5 | OK |
| scn-quality-gates-p2 | positive | quality-gates | quality-gates | 5/5 | OK |
| scn-quality-gates-p3 | positive | quality-gates | quality-gates | 5/5 | OK |
| scn-template-p1 | positive | template-skill | skill-creator | 5/5 | MISS |
| scn-template-p2 | positive | template-skill | skill-creator | 5/5 | MISS |
| scn-template-p3 | positive | template-skill | skill-creator | 5/5 | MISS |
| scn-nm5 | near-miss | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-nm7 | near-miss | (none) | quality-gates | 5/5 | MISS |
| scn-ctl1 | control | (none) | quality-gates | 5/5 | MISS |

axes: accuracy control: 0/1 / near-miss: 1/2 / positive: 10/13; prompt 107445 tok; completion 14945 tok (reasoning 14055); material 97605 tok (mean 1220 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
