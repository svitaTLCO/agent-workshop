# Run t1-pair-evwsl-001 (trial)

suite `8c261a1d0b4e` (56 records, 13 in this run) - corpus `draft` - R=5 - template T pinned in manifest

## azure (calls 65)

| scenario | kind | expected | verdict | k/R | status |
|---|---|---|---|---|---|
| scn-env-windows-p1 | positive | env-windows | env-windows | 5/5 | OK |
| scn-env-windows-p2 | positive | env-windows | env-windows | 5/5 | OK |
| scn-env-windows-p3 | positive | env-windows | env-windows | 5/5 | OK |
| scn-env-wsl-p1 | positive | env-wsl | env-wsl | 5/5 | OK |
| scn-env-wsl-p2 | positive | env-wsl | env-wsl | 5/5 | OK |
| scn-env-wsl-p3 | positive | env-wsl | env-wsl | 5/5 | OK |
| scn-nm1 | near-miss | env-windows | env-windows | 5/5 | OK |
| scn-ctl1 | control | (none) | quality-gates | 5/5 | MISS |
| scn-ctl2 | control | (none) | (none) | 5/5 | OK |
| scn-ctl3 | control | (none) | (none) | 5/5 | OK |
| scn-ctl4 | control | (none) | (none) | 5/5 | OK |
| scn-ctl5 | control | (none) | (none) | 5/5 | OK |
| scn-ctl6 | control | (none) | (none) | 5/5 | OK |

axes: accuracy control: 5/6 / near-miss: 1/1 / positive: 6/6; prompt 83340 tok; completion 795 tok (reasoning 0); material 78335 tok (mean 1205 per call)

Verdict = strict majority over repeats (>R/2); `!` = non-unanimous repeats (UNSTABLE); NO-MAJORITY = tie (no strict majority), including ties involving null.
material tokens = prompt_tokens - lane wrapper constant (manifest). Rescoring is deterministic over results.jsonl.
