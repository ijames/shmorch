# Workflow: Navigate

Surface the right next task from a structured, project-aware view of open work.
Use at session start, after completing a task, or any time priorities are unclear.

Navigate is not a plan.md reader. It is an active orientation step: it reads the plan,
derives the project's domain areas from architecture docs, maps tasks to domains, looks
up the relevant functions in the actual code, and presents a navigable picture.

## When to use
- At session start to choose what to work on
- After completing a task to pick the next one
- Any time priorities feel unclear or you need orientation

## Inputs
- `docs/architecture/domains.md` (or derive from `docs/architecture/` if absent)
- `docs/state/plan.md`

## Roles
- None — runs inline

---

## Step 1 — Derive domain areas

Read `docs/architecture/domains.md` for this project's domain decomposition —
functional purpose, technical ownership, and current balance per domain.

If `docs/architecture/domains.md` does not exist: derive domains from
`docs/architecture/` and the actual directory structure, then prompt the user
to confirm before proceeding. Once confirmed, write `docs/architecture/domains.md`
so future sessions don't re-derive from scratch.

---

## Step 2 — Map tasks to domains

For each open item in `docs/state/plan.md`, assign it to a domain. One item can
span two domains — list it in both but note the primary one.

Also note, per domain, the current **balance**:

- **Design-heavy** — the what or how isn't settled; most work is spec/design/decisions
- **Implementation-heavy** — approach is clear; most work is coding and testing
- **Mixed** — some tasks ready to build, others still being designed
- **Maintenance** — doc gaps, test gaps, curation for this domain

---

## Step 3 — Present the domain view

Show one line per populated domain, with counts and balance signal. Example:

```
Account Handling       [Design-heavy]  1 task — AccountCollector (spec written, phase 1 unstarted)
Order Loop             [Maintenance]   2 items — doc gap + 1 known bug (AWAIT_TIMED_OUT on cancel)
Order Types            [Mixed]         1 ready-to-build (BUYC test gap), 1 design needed (OCO)
Schwab Endpoints       [Maintenance]   endpoint verification backlog
Market & Pricing       [Clean]         no open items
UI & Templates         [Mixed]         Trades tab (live), positions polling (backlog)
Infrastructure         [Maintenance]   task-store evaluation, workflow tooling just updated
```

Ask: **"Which domain, or a specific item?"** — one question, wait.

---

## Step 4 — Drill down into a domain

When the user selects a domain:

1. List the open tasks in that domain
2. For each task: look up the relevant functions in the actual code
   - Read the relevant files or grep for the entry points
   - Surface: function names, file paths, approximate line counts affected
   - Note what phase the task is in (design / spec written / ready to build / test gap)
3. Show the balance: how much of this domain is design work vs. implementation vs. maintenance

Example drill-down for **Account Handling**:

```
Account Handling — Design-heavy

· AccountCollector refactor (spec written, Phase 1 unstarted)
  Phase: Ready to build (Phase 1 only — alongside existing code, no removals)
  Functions touched:
    Biz::getAccounts()           biz.php:~340    — to be replaced by AccountCollector::fetchAll()
    Biz::getAccountHash()        biz.php:~390    — to be replaced by AccountCollector::getHash()
    Biz::refreshFunds()          biz.php:~420    — will delegate to AccountCollector::refreshAccount()
    Account::__construct()       account.php:~30 — no change needed (already a value object)
  New file: htdocs/models/account_collector.php
  Tests needed: AccountCollectorTest (new)

Branch options: Build (Phase 1) · Analyze (re-read spec first) · Break out (Phase 1 sub-tasks)
```

---

## Step 5 — Offer branching verbs

From any task or cluster, offer the most appropriate branches. Lead with the 2-3 that fit — don't present all nine unless asked.

| Branch | When appropriate | Routes to |
|--------|-----------------|-----------|
| **Spec** | Outcome is unclear — "what exactly are we building?" | Spec workflow |
| **Design** | Outcome clear; approach has open decisions | Design workflow |
| **Analyze** | Need to understand existing code before deciding | Analyze workflow |
| **Test** | TDD — write failing tests before implementation | Build (tests-first) |
| **Build** | Outcome and approach both clear | Build workflow |
| **Break out** | Task too large; needs sub-tasks first | Decompose → update plan.md → re-navigate |
| **Consolidate** | Multiple items that are really one thing | Merge → update plan.md → re-navigate |
| **Curate** | Docs/Zulip/tests out of sync with this domain | Curate workflow |
| **Defer** | Not ready or not worth it now | Move to backlog with reason |

**Read the task and lead with the right verb.** If AccountCollector Phase 1 is specced and the approach is settled, lead with "Build — want to start on Phase 1?" not the full menu.

---

## Step 6 — Decompose or consolidate (if chosen)

### Break out
1. List natural sub-tasks — ask user to confirm or adjust
2. Write sub-tasks to `docs/state/plan.md` under the parent, with file/function references
3. Re-navigate to the first sub-task

### Consolidate
1. Identify the unifying theme and propose a merged outcome statement
2. Update `docs/state/plan.md` — remove old items, add merged one with references
3. Navigate to the merged item

---

## Step 7 — Execute

Stamp: `bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "navigate → <workflow>"`
Enter the target workflow.
On return: offer to navigate again, or suggest wrapping if the session has been long.

