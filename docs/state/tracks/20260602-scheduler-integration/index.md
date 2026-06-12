↑ [Shmorch Plan](../../plan.md)
→ `docs/architecture/scheduler-integration.md` (design doc already written) + new `commands/schedule.md` + `workflows/schedule.md`

# Track: Scheduler integration

**Status:** Open
**Opened:** 2026-06-02
**Domain:** Session infrastructure

## Why

Shmorch has no way to trigger recurring work — sprint reminders, hygiene checks, velocity snapshots — without the developer manually running commands. A three-tier scheduler model covers: in-session hygiene (session-scoped CronCreate), cross-session rhythms (durable CronCreate), and sprint boundary events (one-shot durable).

## What changes

- `commands/schedule.md` + `workflows/schedule.md`
- `.shmorch/scheduled-jobs.json` sidecar for name→ID mapping (persists job IDs across sessions)
- `go.md` extension: check for expired scheduled jobs at session start
- `sprinter.md` extension: auto-register sprint boundary jobs when a sprint opens

**Open question:** remote agents (`schedule` skill) vs in-REPL CronCreate for scenarios where Claude is not open. This blocks implementation.

Design doc: `docs/architecture/scheduler-integration.md` — full three-tier model with open questions.

## Work log

### 2026-06-02
Design doc written. Implementation blocked pending resolution of remote-agent vs CronCreate question.
