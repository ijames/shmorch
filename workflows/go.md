# Workflow: go — entry dispatcher

The single entry point for a Shmorch session. Resolve the skill, detect the repo's
state, run only the phases that apply, then hand off to orientation.

`init` (provision fresh) and `auto-update` / `sync` (provision delta) are the
provisioning engines this routes to — still directly invokable, but **go is the one
door**: "go decides about auto-update, which if never done is just init."

## Inputs
- Optional topic/detail from the invocation args (used as the timelog SESSION_START detail)

## Roles
- None — runs inline (may invoke init / auto-update / discover / orient)

---

## Step 0 — Resolve skill location

Resolve and export `$SHMORCH_HOME` (see `core/portability.md`):
```bash
SHMORCH_HOME="${SHMORCH_HOME:-}"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$(cat .shmorch/home 2>/dev/null || true)"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$HOME/.claude/skills/shmorch"
export SHMORCH_HOME
```

---

## Step 1 — Detect repo state

Cheap probes, in order — this decides which phases run:

- **SELF** — `$SHMORCH_SELF=1`, or the current directory *is* `$SHMORCH_HOME`: this is the skill's own repo. Skip provisioning entirely; go straight to Step 3.
- **UNINITIALIZED** — no `.shmorch/AGENTS.md` and no `docs/state/context.md`: the repo has no Shmorch yet → provision fresh (Step 2a).
- Otherwise read versions:
  ```bash
  PROJECT_VERSION=$(cat .shmorch/VERSION 2>/dev/null | tr -d '[:space:]')
  SKILL_VERSION=$(cat "$SHMORCH_HOME/VERSION" 2>/dev/null | tr -d '[:space:]')
  echo "Project: $PROJECT_VERSION  Skill: $SKILL_VERSION"
  ```
  - **BEHIND** — project version < skill version → offer update (Step 2b).
  - **CURRENT** — equal, or skill file missing → no provisioning.

**RESUMABLE overlay** (any already-initialized repo): if `bash "$SHMORCH_HOME/tools/check-session-state.sh"` returns `INTERRUPTED`, or `session.md` leads with a "Pick up immediately" / **BLOCKER** note, offer the fast lane before the full bootstrap:
> "There's an in-flight session here. **resume** (fast: session + plan only) or full **go**?"

- resume → run `$SHMORCH_HOME/workflows/resume.md` and stop.
- go → continue below.

---

## Step 2 — Provision (only UNINITIALIZED or BEHIND)

**2a. UNINITIALIZED → provision fresh (= init).** Read `$SHMORCH_HOME/workflows/init.md` and execute it against the current directory. init detects existing code and runs `discover` itself. Ignore init's closing "run /shmorch go" hand-off — you *are* go; continue to Step 3.

**2b. BEHIND → provision delta (= auto-update / sync).** Say exactly:
> "Shmorch update available ($PROJECT_VERSION → $SKILL_VERSION). Run now before we start? (yes/no)"

- yes → read `$SHMORCH_HOME/workflows/auto-update.md` and execute it, then continue.
- no → continue; remind again at wrap.

SELF and CURRENT skip this step.

---

## Step 3 — Session start

Check session state:
```bash
bash "$SHMORCH_HOME/tools/check-session-state.sh"
```

- `CLEAN` (or script missing / no timelog yet): stamp SESSION_START normally.
- `INTERRUPTED`: previous session has no SESSION_END — run the **Catch-Up Wrap** below before opening the new session.

Use the topic/detail passed to `go` as the SESSION_START detail. If empty, use "new session".

### Catch-Up Wrap (runs only on INTERRUPTED)

Tell the user immediately, before doing anything else:

> "Previous session wasn't wrapped — running catch-up wrap now before we start."

Then execute these steps in order:

**CW-1 — Close the previous session in the timelog:**
```bash
bash "$SHMORCH_HOME/tools/timelog.sh" "SESSION_END" "auto-wrapped on reentry"
```

**CW-2 — Infer what happened:**
```bash
git log --oneline -10
```
Read `docs/state/session.md` to find the last session entry date. Commits since that date are what the previous session produced.

**CW-3 — Update session.md:**
Write a session entry (or update today's if one exists) using the standard session.md format from `workflows/wrap.md` Step 5. Use git log as the source for "What was done" and "Commits". Set the focus line to "Session ended without wrap — reconstructed from git log." Demote the previous "Latest Session" heading to a date heading.

**CW-4 — Update plan.md:**
Check if any tracks or tasks visible in git commits have a status that should now be updated. Apply changes if obvious; skip if unclear.

**CW-5 — Graduate closed tracks:**
```bash
grep -rl "Status: Closed\|Status: Done" docs/state/tracks/ 2>/dev/null
```
For each match, prompt the user: "Track `<name>` is closed — graduate now or defer?" (one question, non-blocking).

**CW-6 — Commit state files:**
```bash
bash "$SHMORCH_HOME/tools/commit-session-state.sh"
```
Skip silently if nothing to commit.

**CW-7 — Stamp new session start:**
```bash
bash "$SHMORCH_HOME/tools/timelog.sh" "SESSION_START" "DETAIL"
```

Tell the user: "Catch-up wrap done. Continuing with session start."

Then extract and surface the first **BLOCKER** from session.md:
```bash
grep -A1 "BLOCKER\|Pick up immediately" docs/state/session.md | head -4
```

---

## Step 4 — Orient

Read `$SHMORCH_HOME/workflows/orient.md` and execute it: read context/stack (interview if unfilled), last session, plan, check for leftover work, surface gaps, and propose 2-3 concrete next moves. That file also carries the working-session references (tracks, phases, stack awareness, decisions).
