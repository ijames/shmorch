### Self-Improve Proposals — 2026-07-22 | Project: experiment

#### Proposal 1: `resume` should stamp SESSION_START
**Pattern:** Sessions re-entered via `/clear` + `/shmorch resume` never get a SESSION_START stamp; wrap then stamps START and END in the same second (2026-07-22 01:42:20 START+END both), and the 2026-07-22 00:40 session has an END with no START at all. Duration reporting (`duration.sh`) is meaningless for these sessions.
**Frequency:** 2+ sessions (2026-07-22 twice; pattern implicit in every post-clear resume).
**File:** `$SHMORCH_HOME/workflows/resume.md` (and `go.md` for symmetry)
**Change:** Add a step after Step 1: `bash $SHMORCH_HOME/tools/timelog.sh "SESSION_START" "<current task one-liner>"` unless a SESSION_START already exists for today after the last SESSION_END.
**Improvement:** Accurate session spans; wrap no longer needs the retroactive double-stamp.

#### Proposal 2: stop-hook auto-close produces empty session ends
**Pattern:** `SESSION_END | auto-closed by stop hook` with no summary and no session.md entry — 2026-06-17 and 2026-07-21. These sessions leave no trace of what happened beyond the stamp.
**Frequency:** 2 occurrences.
**File:** `.claude/hooks/stop.sh` (project-local)
**Change:** Include the current branch + `git log --oneline -1` in the auto-close detail line, e.g. `SESSION_END | auto-closed by stop hook — <branch> @ <last commit subject>`, so the ledger carries minimal context even without a wrap.
**Improvement:** Auto-closed sessions become reconstructable from the timelog alone.

### Already addressed
- Dry-run mutating `used_log.json` — resolved in commit `0ee02ae` + decisions.md [2026-07-22].

### No-action observations
- Stray `[2026-07-21 22:12:56] check |` entry (single occurrence — likely a manual timelog.sh test).
- TASK_DONE without TASK_START on 2026-06-05 (pre-dates current discipline; not recurring).
