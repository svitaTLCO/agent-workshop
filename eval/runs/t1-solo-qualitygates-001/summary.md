# Run t1-solo-qualitygates-001 (trial)

suite `8c261a1d0b4e` (56 records, 5 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 25)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-quality-gates-p1 | positive | quality-gates | quality-gates | 5/5 | OK |
| scn-quality-gates-p2 | positive | quality-gates | quality-gates | 5/5 | OK |
| scn-quality-gates-p3 | positive | quality-gates | quality-gates | 5/5 | OK |
| scn-nm7 | near-miss | (none) | quality-gates | 5/5 | MISS |
| scn-nm8 | near-miss | quality-gates | quality-gates | 5/5 | OK |

axes: accuracy near-miss: 1/2 / positive: 3/3; prompt 32035 tok; completion 325 tok (reasoning 0); material 30110 tok (mean 1204 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
