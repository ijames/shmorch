# Command: personal-eval (alias: pe)

Burn down the `~/.shmorch/personal-profile` session backlog in a small, cost-capped
batch — extracting persona evidence from Claude Code session transcripts into the
profile's `sessions/` and section files.

Not a shmorch project artifact — `~/.shmorch/personal-profile` is a separate,
non-public repo (own README, own pipeline). This command only orchestrates the batch
run so it works the same way from any CLI shmorch runs under.

## When to run
- Manually, to work through the unprocessed-session backlog (`pe`, `pe scan <N>`)
- Manually, to run a strong-tier interpretive pass over the accumulated profile
  (`pe analyze`) — separate from backlog burn-down, produces a dated
  `analysis/<date>-analysis.md` rather than touching the section files
- Never automatically — batch size and model tier are cost-sensitive, always confirm

## Dispatches to
`workflows/personal-eval.md`
