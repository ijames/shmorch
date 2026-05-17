#!/usr/bin/env bash
# Gate check for self-improve. Outputs PROCEED or SKIP:<reason>.
# Used by self-improve.md Step 2. Call from any project root — uses git to locate it.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TIMELOG="$ROOT/docs/state/timelog.md"

if [ ! -f "$TIMELOG" ]; then
  echo "SKIP:no-timelog"
  exit 0
fi

SESSION_COUNT=$(grep -c "SESSION_" "$TIMELOG" 2>/dev/null || echo 0)
if [ "$SESSION_COUNT" -lt 3 ]; then
  echo "SKIP:not-enough-sessions ($SESSION_COUNT < 3)"
  exit 0
fi

LAST_RUN_LINE=$(grep "self-improve: complete" "$TIMELOG" 2>/dev/null | tail -1)

if [ -z "$LAST_RUN_LINE" ]; then
  echo "PROCEED"
  exit 0
fi

LAST_SESSION_END_LINE=$(grep "SESSION_END" "$TIMELOG" 2>/dev/null | tail -1)

LAST_RUN_TS=$(echo "$LAST_RUN_LINE" | grep -o '\[[0-9-]* [0-9:]*\]' | tr -d '[]')
LAST_END_TS=$(echo "$LAST_SESSION_END_LINE" | grep -o '\[[0-9-]* [0-9:]*\]' | tr -d '[]')

ts_to_epoch() {
  date -j -f "%Y-%m-%d %H:%M:%S" "$1" "+%s" 2>/dev/null \
    || date -d "$1" "+%s" 2>/dev/null \
    || echo 0
}

LAST_RUN_EPOCH=$(ts_to_epoch "$LAST_RUN_TS")
LAST_END_EPOCH=$(ts_to_epoch "$LAST_END_TS")
NOW_EPOCH=$(date "+%s")
FOUR_HOURS=14400

if [ "$((NOW_EPOCH - LAST_RUN_EPOCH))" -lt "$FOUR_HOURS" ] \
  && [ "$LAST_RUN_EPOCH" -gt "$LAST_END_EPOCH" ]; then
  echo "SKIP:ran-recently-no-new-sessions"
  exit 0
fi

echo "PROCEED"
