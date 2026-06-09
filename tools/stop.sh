#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PLAN="$ROOT/docs/state/plan.md"
TIMELOG="$ROOT/docs/state/timelog.md"

# Stamp SESSION_END if session is still open (SESSION_START with no SESSION_END)
if [ -f "$TIMELOG" ]; then
  LAST=$(grep "SESSION_" "$TIMELOG" 2>/dev/null | tail -1)
  if [[ "$LAST" == *"SESSION_START"* ]]; then
    bash ~/.claude/skills/shmorch/tools/timelog.sh "SESSION_END" "auto-closed by stop hook"
  fi
fi

# Remind about active tracks
[ -f "$PLAN" ] || exit 0
if grep -q "| In progress |" "$PLAN" 2>/dev/null; then
  echo "Reminder: active track in progress — run /shmorch wrap before ending session."
fi

exit 0
