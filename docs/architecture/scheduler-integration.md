# Scheduler Integration — Architecture

↑ [Architecture](../index.md)

---

## What Problem This Solves

Shmorch is reactive: it wakes up when the developer opens a session, runs when commanded, and closes when told to wrap. That works for direct work, but it creates three failure modes:

1. **Session overrun** — the developer keeps building without wrapping; state drifts; the next session starts cold with no summary.
2. **Sprint drift** — sprint deadlines pass silently; plan.md still shows work "In Progress" from days ago.
3. **Maintenance gaps** — vacuum runs only when manually triggered; stale TODOs and dead code accumulate between sprint boundaries.

A scheduler integration makes Shmorch proactive. Instead of waiting to be invoked, it fires at planned moments: end of a working block, start of a new day, weekly cadence, sprint boundary.

---

## Available Primitives

Claude Code's harness exposes three scheduler tools:

| Tool | What it does |
|------|--------------|
| `CronCreate` | Fires a prompt on a cron schedule. Session-scoped by default; `durable: true` persists to `.claude/scheduled_tasks.json` and survives restarts. Recurring jobs auto-expire after 7 days. |
| `CronList` | Lists all currently scheduled jobs in this session. |
| `CronDelete` | Cancels a job by ID. |

**Session-scoped vs durable** is the primary design axis. Session-scoped jobs die when the Claude session ends — appropriate for in-session hygiene. Durable jobs survive restarts and persist across days — appropriate for recurring rhythms and sprint events.

---

## Three Tiers of Scheduled Events

### Tier 1 — In-Session Hygiene (session-scoped)

These fire during a working session and disappear when it ends.

| Event | Trigger | Prompt behavior |
|-------|---------|-----------------|
| **Wrap reminder** | N hours after SESSION_START | Surface to developer: "You've been in this session for ~3 hours. Run `/shmorch wrap` before you lose context." |
| **Focus check** | Every 90 min | Read `docs/state/plan.md` current task; confirm developer is still on the active task, not sliding into adjacent work. |
| **Commit nudge** | Every 2 hours | Check `git status`; if uncommitted changes exist and last commit was >2h ago, suggest `/shmorch commit`. |

These are short-circuit fires — they prompt once, the developer acts or ignores, and that's it. They don't read heavy state or spawn agents.

### Tier 2 — Cross-Session Rhythms (durable)

These persist across sessions and represent regular project cadences.

| Event | Cron | Prompt behavior |
|-------|------|-----------------|
| **Daily kickoff** | `57 8 * * 1-5` | Read `docs/state/context.md`, `session.md`, `plan.md`. Surface: current sprint day, active tracks, any open blockers, first proposed task. |
| **Weekly vacuum** | `3 9 * * 1` | Run `/shmorch vacuum` with full scan scope. Report findings. |
| **Weekly timelog digest** | `7 9 * * 1` | Run `bash ~/.claude/skills/shmorch/tools/duration.sh week`. Format as table of sessions × tasks × durations. Log to `docs/state/timelog-digest.md`. |
| **Stale track scan** | `17 9 * * 2,4` | Scan `docs/state/tracks/` for any track with `Status: In Progress` that has no timelog entry in the last 72h. Surface to developer for triage. |

**7-day auto-expiry caveat:** CronCreate recurring jobs expire after 7 days. A `/shmorch schedule renew` operation or a session-start check (`go.md`) should detect and re-register durable recurring jobs that have expired. This is the main lifecycle management concern.

### Tier 3 — Sprint Boundary Events (durable, one-shot)

These fire at specific sprint milestones, read from `docs/state/plan.md` or `docs/state/schedule/sprints/`.

| Event | When | Prompt behavior |
|-------|------|-----------------|
| **Sprint review reminder** | 1 day before sprint end date | Surface remaining open tasks. Propose sprint review session or extension. |
| **Sprint retrospective** | Sprint end date | Run `/shmorch wrap` framing; prompt for retrospective notes; update session.md with sprint summary. |
| **Backlog grooming** | First day of new sprint | Read backlog section of plan.md; surface top 5 untagged items; propose prioritization session. |

Sprint events are one-shot (`recurring: false`) — they fire once and auto-delete. Re-created when the new sprint is defined.

---

## What a Scheduled Shmorch Prompt Looks Like

A scheduled prompt is not just "run vacuum" — it needs enough context to orient without requiring the developer to do anything. The template:

```
/shmorch [command]
Context: This is a scheduled [event-name] event, not a direct developer request.
Project: [project name from context.md]
Time: [timestamp]
```

For example, the daily kickoff prompt:

```
/shmorch go daily-kickoff
Context: This is a scheduled daily-kickoff event. Read docs/state/context.md,
docs/state/session.md, and docs/state/plan.md. Present: sprint day number,
active tracks, any open blockers from last session, and 2-3 proposed tasks
ordered by sprint priority. Do not ask what to work on before surfacing these.
```

The `go` workflow already handles this — the argument becomes the SESSION_START timelog detail. The scheduled prompt simply passes the right argument.

---

## Timelog Integration

Scheduled events that fire should be stamped in the timelog so session duration math includes them:

- When a scheduled prompt fires: `SESSION_START | scheduled: [event-name]`
- When developer responds and work ends: `SESSION_END | [summary]`

This is the same flow as a normal session — the scheduler just triggers it automatically. No special timelog changes needed; the go workflow handles stamping.

---

## Proposed `/shmorch schedule` Command

A new command that manages scheduled events with Shmorch-aware semantics. Operations:

```
/shmorch schedule list              — show all active scheduled jobs (name, cron, durable)
/shmorch schedule add [preset]      — add a named preset (wrap-reminder, daily-kickoff, etc.)
/shmorch schedule remove [name]     — cancel a scheduled job by name
/shmorch schedule renew             — re-register any expired durable jobs
/shmorch schedule status            — show which standard events are active vs missing
```

Named presets map to specific cron expressions and prompts from the table above. The developer picks from presets; they don't write raw cron expressions.

Implementation: `commands/schedule.md` dispatches to `workflows/schedule.md`. The workflow wraps `CronCreate`/`CronList`/`CronDelete` with Shmorch naming, stores job IDs to a sidecar file (`.shmorch/scheduled-jobs.json`) so they can be referenced by name across sessions, and handles the 7-day auto-expiry renewal pattern.

---

## Sidecar File: `.shmorch/scheduled-jobs.json`

CronCreate returns an opaque ID. To reference jobs by name (for `remove` and `renew`), a sidecar file tracks the mapping:

```json
{
  "jobs": [
    {
      "name": "daily-kickoff",
      "id": "cron_abc123",
      "cron": "57 8 * * 1-5",
      "durable": true,
      "created": "2026-06-02T18:00:00Z",
      "expires": "2026-06-09T18:00:00Z"
    }
  ]
}
```

The `go.md` workflow checks this file at session start (Step 1b could extend to check scheduler state) and surfaces jobs that have expired or are missing. `.shmorch/scheduled-jobs.json` is gitignored — it's machine-local session state, not project code.

---

## Sprint-Aware Auto-Scheduling

When `/shmorch sprinter` defines a new sprint (including end date), the schedule workflow should auto-create:
- One sprint-review-reminder one-shot job (end_date − 1 day)
- One sprint-retrospective one-shot job (end_date)

This means `sprinter.md` would call `workflows/schedule.md` to register these jobs. No developer action needed — the sprint boundary events appear automatically when the sprint is defined.

Similarly, when a sprint closes, its boundary jobs are cleaned up (CronDelete by name via the sidecar).

---

## Open Questions

1. **Renewal strategy for 7-day expiry** — Should `go.md` check for expired durable jobs on every session start? Or should the weekly vacuum include a `schedule renew`? Checking in `go.md` is more reliable; it adds ~1 CronList call per session which is negligible.

2. **What fires a daily kickoff if Claude isn't running?** — CronCreate only fires while the REPL is idle. If the developer hasn't opened Claude Code, the daily kickoff doesn't fire. This is expected behavior — the scheduler is an in-Claude ambient layer, not a system cron. For true system-level scheduling, the `schedule` skill (remote agents) is the right tool. Clarify which use cases need the `schedule` skill vs in-REPL CronCreate.

3. **Remote agents vs in-REPL prompts** — The harness `schedule` skill supports remote agents that run on a cron schedule independently of an open session. For heavier operations (daily timelog digest, full vacuum run) that should happen even when Claude isn't open, those are remote agent candidates. Lighter in-session nudges (wrap reminder, focus check) are in-REPL CronCreate. Document the boundary more precisely before implementation.

4. **Notification surface** — If a scheduled prompt fires and the developer isn't looking at Claude, should it send a Zulip notification instead? For projects with Zulip connected (DarkBadge), the scheduled prompt could check `context.md` for a Zulip configuration and post to `#scheduled-events` rather than (or in addition to) the inline REPL output.

---

## Phase 1 — Two Concrete Jobs

The first two jobs to implement when this moves to build. Both are registered by `go.md` at session start.

### Job 1: 25-Minute Focus Check

**What it does:** Every 25 minutes, reads `docs/state/plan.md` (current task) and the timelog (last event) and asks: is the current session activity consistent with the plan priority? If drifting — e.g., working on a backlog item when a higher-priority track is active — surfaces a one-line nudge.

**Cron:** `3,28,53 * * * *` (fires at :03, :28, :53 — avoids the :00 and :30 cluster)

**Durable:** yes (persists across session restarts; renewal at session start)

**Prompt when it fires:**
```
/shmorch status focus-check
Read docs/state/plan.md (current task section only) and the last 3 lines of
docs/state/timelog.md. Are we on the active task? If yes, say nothing (output nothing).
If the timelog shows activity outside the current task, surface exactly one line:
"Focus check: [active task] is the plan priority — currently doing [what timelog shows]."
```

The key behavior: **no output if on task**. The check is ambient; it should be invisible when things are going well.

---

### Job 2: 5pm Wrap

**What it does:** At 5pm on weekdays, fires the wrap flow — prompts to commit uncommitted changes, updates session.md with what was done, and closes the timelog with SESSION_END.

**Cron:** `0 17 * * 1-5`

**Durable:** yes

**Prompt when it fires:**
```
/shmorch wrap
Context: This is a scheduled end-of-day wrap. It is 5pm.
Proceed with the full wrap workflow: summarize what was done, check for uncommitted
changes, update docs/state/session.md, stamp SESSION_END in timelog.
```

**Why 5pm and not "after N hours":** A fixed time is predictable — the developer knows it's coming and can plan around it. A duration-based trigger fires at unpredictable times. If the developer isn't working at 5pm, the prompt fires into an idle session harmlessly.

---

### Registration in `go.md`

Both jobs are registered at session start (Step 1 of `go.md`), after the session stamp. The registration flow:

1. Read `.shmorch/scheduled-jobs.json` (sidecar file, gitignored)
2. For each expected job (`focus-check`, `daily-wrap`): check if it exists and is not expired
3. If missing or expired: call `CronCreate` with `durable: true`, write new ID to sidecar, tell the user: "Registered focus-check (every 25 min) and daily-wrap (5pm)."
4. If already active: skip silently

If jobs were expired and re-registered, surface it briefly: "Renewed 2 scheduled jobs (focus-check, daily-wrap) — they expired after 7 days."

---

## Implementation Order

When this moves to build:

1. `commands/schedule.md` + `workflows/schedule.md` — core command/workflow stubs
2. Session-scoped presets first (wrap-reminder, commit-nudge) — lowest stakes, no durable state
3. Sidecar file (`.shmorch/scheduled-jobs.json`) + name→ID mapping
4. Durable presets (daily-kickoff, weekly-vacuum)
5. `go.md` extension — check for expired jobs at session start (Step 1b)
6. `sprinter.md` extension — auto-register sprint boundary jobs when sprint is defined
7. Remote agent option for fire-when-Claude-not-open scenarios (open question 3)

---

## First Reference Project

DarkBadge — the immediate useful case is the wrap-reminder (session overrun is a real pattern) and the daily-kickoff (helps orient when resuming after a gap without re-reading all of session.md manually).
