#!/usr/bin/env bash
# timelog.sh — Append a timestamped event to docs/state/timelog.md
# Usage: bash $SHMORCH_HOME/tools/timelog.sh "EVENT" "detail"
# Examples:
#   bash $SHMORCH_HOME/tools/timelog.sh "SESSION_START" "resuming auth module"
#   bash $SHMORCH_HOME/tools/timelog.sh "TASK_START" "Build login endpoint"
#   bash $SHMORCH_HOME/tools/timelog.sh "AGENT_SPAWN" "analyst → src/payments/"
#   bash $SHMORCH_HOME/tools/timelog.sh "TASK_DONE" "Build login endpoint"
#   bash $SHMORCH_HOME/tools/timelog.sh "SESSION_END" "spec approved"

set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

EVENT="${1:-EVENT}"
DETAIL="${2:-}"
TS=$(date '+%Y-%m-%d %H:%M:%S')
ENTRY="[$TS] $EVENT | $DETAIL"
LOG="$ROOT/docs/state/timelog.md"

# Self-healing guard: a SESSION_START immediately after another SESSION_START
# (no intervening SESSION_END) means some entry path bypassed go/resume's
# INTERRUPTED check. Close the orphaned session here so pairing stays sound
# regardless of caller.
if [ "$EVENT" = "SESSION_START" ] && [ -f "$LOG" ]; then
  LAST=$(grep "SESSION_" "$LOG" 2>/dev/null | tail -1 || true)
  if [[ "$LAST" == *"SESSION_START"* ]]; then
    echo "[$TS] SESSION_END | auto-wrapped (guard: consecutive SESSION_START)" >> "$LOG"
  fi
fi

echo "$ENTRY" >> "$LOG"
echo "$ENTRY"
