# Run t1-solo-agentonboard-001 (trial)

suite `8c261a1d0b4e` (56 records, 5 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 25)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-agent-onboard-p1 | positive | agent-onboard | agent-onboard | 5/5 | OK |
| scn-agent-onboard-p2 | positive | agent-onboard | agent-onboard | 5/5 | OK |
| scn-agent-onboard-p3 | positive | agent-onboard | agent-onboard | 5/5 | OK |
| scn-nm3 | near-miss | env-linux | env-linux | 5/5 | OK |
| scn-nm4 | near-miss | agent-onboard | agent-onboard | 5/5 | OK |

axes: accuracy near-miss: 2/2 / positive: 3/3; prompt 32035 tok; completion 320 tok (reasoning 0); material 30110 tok (mean 1204 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
