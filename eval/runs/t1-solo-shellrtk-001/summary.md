# Run t1-solo-shellrtk-001 (trial)

suite `8c261a1d0b4e` (56 records, 3 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 15)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-shell-rtk-p1 | positive | shell-rtk | shell-rtk | 5/5 | OK |
| scn-shell-rtk-p2 | positive | shell-rtk | shell-rtk | 5/5 | OK |
| scn-shell-rtk-p3 | positive | shell-rtk | shell-rtk | 5/5 | OK |

axes: accuracy positive: 3/3; prompt 19225 tok; completion 210 tok (reasoning 0); material 18070 tok (mean 1205 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
