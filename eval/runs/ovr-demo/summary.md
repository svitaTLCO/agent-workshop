# Run ovr-demo (smoke)

suite `8c261a1d0b4e` (56 records, 1 in this run) - corpus `live` - R=1 - template T pinned in manifest

## azure (calls 1)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-context-diet-p1 | positive | context-diet | context-diet | 1/1 | OK |

axes: accuracy positive: 1/1; prompt 812 tok; completion 13 tok (reasoning 0); material 735 tok (mean 735 per call)

Verdict = strict majority over repeats (>R/2); UNSTABLE = not unanimous; NO-MAJORITY = tie.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
