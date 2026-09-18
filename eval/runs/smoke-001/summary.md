# Run smoke-001 (smoke)

suite `8c261a1d0b4e` (56 records, 2 in this run) - corpus `live` - R=3 - template T pinned in manifest

## azure (calls 6)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-context-diet-p1 | positive | context-diet | context-diet | 3/3 | OK |
| scn-nm7 | near-miss | (none) | quality-gates | 3/3 | MISS |

axes: accuracy near-miss: 0/1 / positive: 1/1; prompt 4866 tok; completion 78 tok (reasoning 0); material 4404 tok (mean 734 per call)

## galene (calls 6)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-context-diet-p1 | positive | context-diet | context-diet | 3/3 | OK |
| scn-nm7 | near-miss | (none) | quality-gates | 3/3 | MISS |

axes: accuracy near-miss: 0/1 / positive: 1/1; prompt 5217 tok; completion 1068 tok (reasoning 1002); material 4479 tok (mean 746 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
