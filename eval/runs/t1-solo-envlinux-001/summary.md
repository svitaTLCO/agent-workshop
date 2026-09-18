# Run t1-solo-envlinux-001 (trial)

suite `8c261a1d0b4e` (56 records, 3 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 15)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-env-linux-p1 | positive | env-linux | env-linux | 5/5 | OK |
| scn-env-linux-p2 | positive | env-linux | env-linux | 5/5 | OK |
| scn-env-linux-p3 | positive | env-linux | env-linux | 5/5 | OK |

axes: accuracy positive: 3/3; prompt 19285 tok; completion 180 tok (reasoning 0); material 18130 tok (mean 1209 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
