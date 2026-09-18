# Run t1-cdm-nm6-retry-001 (trial)

suite `8c261a1d0b4e` (56 records, 1 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 5)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-nm6 | near-miss | context-diet | context-diet | 5/5 | OK |

axes: accuracy near-miss: 1/1; prompt 6430 tok; completion 65 tok (reasoning 0); material 6045 tok (mean 1209 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
