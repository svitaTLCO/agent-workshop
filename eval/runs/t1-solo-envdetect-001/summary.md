# Run t1-solo-envdetect-001 (trial)

suite `8c261a1d0b4e` (56 records, 3 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 15)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-env-detect-p1 | positive | env-detect | env-detect | 5/5 | OK |
| scn-env-detect-p2 | positive | env-detect | env-detect | 5/5 | OK |
| scn-env-detect-p3 | positive | env-detect | env-detect | 5/5 | OK |

axes: accuracy positive: 3/3; prompt 19220 tok; completion 195 tok (reasoning 0); material 18065 tok (mean 1204 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
