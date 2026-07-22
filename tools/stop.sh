#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PLAN="$ROOT/docs/state/plan.md"
TIMELOG="$ROOT/docs/state/timelog.md"
SHMORCH_HOME="${SHMORCH_HOME:-}"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$(cat "$ROOT/.shmorch/home" 2>/dev/null || true)"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$HOME/.claude/skills/shmorch"

# Stamp SESSION_END if session is still open (SESSION_START with no SESSION_END)
if [ -f "$TIMELOG" ]; then
  LAST=$(grep "SESSION_" "$TIMELOG" 2>/dev/null | tail -1 || true)
  if [[ "$LAST" == *"SESSION_START"* ]]; then
    # Carry minimal context so auto-closed sessions are reconstructable from the ledger
    BRANCH=$(git -C "$ROOT" branch --show-current 2>/dev/null || true)
    LASTC=$(git -C "$ROOT" log --oneline -1 2>/dev/null || true)
    bash "$SHMORCH_HOME/tools/timelog.sh" "SESSION_END" "auto-closed by stop hook — ${BRANCH:-?} @ ${LASTC:-?}"
  fi
fi

# Remind about active tracks
if [ -f "$PLAN" ] && grep -q "| In progress |" "$PLAN" 2>/dev/null; then
  echo "Reminder: active track in progress — run /shmorch wrap before ending session."
fi

exit 0
