# Run t1-pair-cdm-001 (trial)

suite `8c261a1d0b4e` (56 records, 11 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 55)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-context-diet-p1 | positive | context-diet | context-diet | 5/5 | OK |
| scn-context-diet-p2 | positive | context-diet | context-diet | 5/5 | OK |
| scn-context-diet-p3 | positive | context-diet | context-diet | 5/5 | OK |
| scn-mcp-essentials-p1 | positive | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-mcp-essentials-p2 | positive | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-mcp-essentials-p3 | positive | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-memory-system-p1 | positive | memory-system | memory-system | 5/5 | OK |
| scn-memory-system-p2 | positive | memory-system | memory-system | 5/5 | OK |
| scn-memory-system-p3 | positive | memory-system | memory-system | 5/5 | OK |
| scn-nm5 | near-miss | mcp-essentials | mcp-essentials | 5/5 | OK |
| scn-nm6 | near-miss | context-diet | context-diet | 4/5 | OK |

axes: accuracy near-miss: 2/2 / positive: 9/9; prompt 69224 tok; completion 727 tok (reasoning 0); material 65066 tok (mean 1205 per call); 1 error rows

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
