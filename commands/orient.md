# Command: orient

State-reading and gap-surfacing, plus the deep, tree-gated Focus & Readiness interview —
one command, two depths.

- `/shmorch orient` — shallow orientation: read context/stack/session/plan, check leftover
  work, propose next move. Same path `go` runs automatically after provisioning.
- `/shmorch orient focus` — deep interview: revisit project focus/shape (success, audience,
  anti-decisions, constraints). Re-runnable; updates existing answers.
- `/shmorch orient readiness` — deep interview: SRE-PRR-based production readiness
  (monitoring, security, backups, cost, on-call), scoped to solo/small-project scale.

Both deep-interview variants log dated answers to `docs/project/interview-log.md` and flag
contradictions against prior answers or standing decisions.

## When to run
- `/shmorch orient` — rarely needed directly; `go` already runs it. Useful for a quick
  re-orientation without the rest of `go`'s provisioning checks.
- `/shmorch orient focus|readiness` — periodically, as a project's scope or production
  posture changes, or the first time production-readiness starts to matter.

## Dispatches to
`workflows/orient.md`
