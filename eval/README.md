# eval/ — skill-trigger evaluation harness (v1)

Locked protocol: `.scratch/skill-prompt-research/issues/04-harness-design.md` (Answer). Suite:
`scenarios.yaml` (amended-and-frozen; any edit invalidates comparability and needs a fresh Baseline).

One protocol, two rulers: identical canonical request (`temperature=0`, `response_format=json_object`,
`max_completion_tokens=256`) sent to the pinned Azure deployment `gpt-5.4` (lane `azure`) and the local
galene lane `Galene/LLM` via `127.0.0.1:8787/v1` (lane `galene`). Catalog = frontmatter
`name`+`description` bullets, live corpus (`skills/`) or post-rewrite corpus (`.scratch/skill-prompt-research/drafts/`),
always 14 entries incl. `template-skill`. Selection domain: corpus names ∪ null; anything else is a
run-error row. Verdict = strict majority over repeats; UNSTABLE when not unanimous. Cost axes: raw
`usage` plus **material tokens** = prompt − lane wrapper constant (`C0`: azure 77 / galene 123,
empty-catalog measurements under the exact template, pinned in every manifest).

## Contract

Token budget: raw API payloads (`runs/*/raw/`) and per-repeat trace detail stay out of agent context by
default — agents read `summary.md` and manifest values only. Context cost of one trial ≈ catalog tokens
(~810 live / ~1,220 draft by measured anchor) + scenario prompt; anchors re-pinned per run in manifests.

Quality gate (all must pass before any Baseline/trial numbers are cited):
1. Planted-label smoke: `python3 eval/run.py run --id smoke-N --lane both --kind smoke
   --scenarios scn-context-diet-p1,scn-nm7` → zero error rows; `scn-context-diet-p1` verdict
   `context-diet` (STABLE) on each available lane; `scn-nm7` verdict `quality-gates` (STABLE, MISS vs
   expected none — the documented pre-rewrite false-positive the drafts exist to remove).
2. Recompute idempotency: `python3 eval/run.py score --id <run-id>` twice → byte-identical `summary.md`.
3. Cap visibility: `python3 eval/run.py cap` — hard campaign abort at **1,500 azure / 100 galene calls**;
   every call (smoke included) appends to the committed `spend.log` ledger; the runner refuses further
   calls at the cap.

## Usage

    python3 eval/run.py run --id baseline-001 --lane azure --kind baseline        # full suite x R=5
    python3 eval/run.py run --id trial-001   --lane azure --kind trial --corpus draft
    python3 eval/run.py run --id probe-xyz   --lane galene --kind smoke --r 1 --scenarios scn-ctl2
    python3 eval/run.py score --id baseline-001      # rescore (deterministic)
    python3 eval/run.py cap                         # cumulative spend vs caps

R defaults to 5 for baseline/trial, 3 for smoke. Rerunning a run-id overwrites its directory cleanly
(spend still counts). Exit codes: 0 ok, 1 setup error, 2 degraded stop (consecutive errors / cap hit).

## Storage

`runs/<id>/{manifest.yaml, results.jsonl, summary.md}` — committed (reproducible, auditable).
`runs/<id>/raw/` — gitignored API payloads. `spend.log` — committed call ledger (no secrets).
Manifests pin model/deployment pins, date, template T verbatim, suite SHA, catalog SHA, R, caps, C0s.
Secrets never live here: Azure creds in `~/.config/agent-workshop/eval-azure.env`, galene key in
`~/.local/share/opencode/auth.json`.
