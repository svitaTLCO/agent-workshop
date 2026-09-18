# Run t1-pair-lmelm-001 (trial)

suite `8c261a1d0b4e` (56 records, 7 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 35)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-env-macos-p1 | positive | env-macos | env-macos | 5/5 | OK |
| scn-env-macos-p2 | positive | env-macos | env-macos | 5/5 | OK |
| scn-env-macos-p3 | positive | env-macos | env-macos | 5/5 | OK |
| scn-local-models-p1 | positive | local-models | local-models | 5/5 | OK |
| scn-local-models-p2 | positive | local-models | local-models | 5/5 | OK |
| scn-local-models-p3 | positive | local-models | local-models | 5/5 | OK |
| scn-nm2 | near-miss | local-models | local-models | 5/5 | OK |

axes: accuracy near-miss: 1/1 / positive: 6/6; prompt 44895 tok; completion 455 tok (reasoning 0); material 42200 tok (mean 1206 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
