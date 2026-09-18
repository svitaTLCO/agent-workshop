# Run t1-solo-skillcreator-001 (trial)

suite `8c261a1d0b4e` (56 records, 6 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 30)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-skill-creator-p1 | positive | skill-creator | skill-creator | 5/5 | OK |
| scn-skill-creator-p2 | positive | skill-creator | skill-creator | 5/5 | OK |
| scn-skill-creator-p3 | positive | skill-creator | skill-creator | 5/5 | OK |
| scn-template-p1 | positive | template-skill | skill-creator | 5/5 | MISS |
| scn-template-p2 | positive | template-skill | skill-creator! | 4/5 | MISS |
| scn-template-p3 | positive | template-skill | skill-creator | 5/5 | MISS |

axes: accuracy positive: 3/6; prompt 38405 tok; completion 388 tok (reasoning 0); material 36095 tok (mean 1203 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
