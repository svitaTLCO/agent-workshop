# Build harness v1 (trigger selection + context cost)

Type: task
Status: open
Blocked by: 04

## Question

Implement `eval/` exactly per the design recorded in 04: runner, metrics, storage, CLI entry. Quality gate: a smoke run over a 2-scenario subset passes on each available lane, raw results land in the agreed storage, reruns overwrite cleanly (idempotent), and the harness declares honest `Token budget:` / `Quality gate:` lines per the repo contract.
