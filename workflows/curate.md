# Workflow: Curate

Keep docs/code/tests and Zulip in parity. Run at session end (part of wrap) and on demand.

## Inputs
- Recent git changes (`git diff --name-only HEAD~10`)
- Zulip channels: Development, Bugs, Features, Schwab (last 7 days)
- `docs/development/decisions.md`
- `docs/state/plan.md`

## Roles
- None — runs inline

## When to use
- End of every session (triggered by `/shmorch wrap`)
- After a significant decision or architectural change
- When Zulip threads have accumulated unextracted findings
- When docs feel stale relative to recent code changes

---

## Step 1 — Zulip scan

1. Fetch recent messages (last 7 days) from: **Development**, **Bugs**, **Features**, **Schwab** channels
2. For each thread, ask: does it contain a decision, architectural finding, bug, or design constraint not yet captured in `decisions.md` or `plan.md`?
3. Promote findings:
   - Architectural decisions → `docs/development/decisions.md`
   - Bugs or tasks not in plan → `docs/state/plan.md` Known Bugs or Backlog
   - Nothing new → skip
4. Reply on the Zulip thread with: `↳ captured in decisions.md [date]` so it isn't re-extracted next session

---

## Step 2 — Code↔doc parity check

1. Get recently changed files: `git diff --name-only HEAD~10`
2. For each changed file in `htdocs/service/` or `htdocs/models/`:
   - Is there a corresponding entry in `docs/architecture/`?
   - If a public method was added, removed, or renamed: is the API summary in `docs/state/context/*.api.md` current?
3. For each changed template in `htdocs/templates/`: is `docs/architecture/template-architecture.md` current?
4. For each closed track: has its outcome been written to `docs/tracks/`? If not, flag it.
5. Flag all gaps — add to `docs/state/plan.md` as quick fixes, don't silently skip

---

## Step 3 — Test↔code parity check

1. For each new or changed public method in recent commits: does a test exist?
2. Run the full test suite — confirm no regressions
3. Flag untested new public methods in `docs/state/plan.md`

---

## Output
- `docs/development/decisions.md` — updated with any promoted Zulip findings
- `docs/state/plan.md` — updated with doc/test gaps flagged as quick fixes
- Zulip replies on extracted threads
- No silent gaps: if something is missing, it's in the plan, not ignored
