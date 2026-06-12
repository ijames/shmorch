#!/usr/bin/env bash
# SessionStart hook — injects sprint state into context so drift-checking is automatic.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

echo "=== SHMORCH SESSION CONTEXT ==="
echo "Project: $(basename "$ROOT")"
echo "Date: $(date '+%Y-%m-%d')"
echo ""

# Sprint objective
SPRINT_CAL="$ROOT/.shmorch/sprint-calendar.md"
if [ -f "$SPRINT_CAL" ]; then
  echo "--- Sprint objective ---"
  grep -A2 "current\|objective\|goal\|focus" "$SPRINT_CAL" 2>/dev/null | head -6 || true
  echo ""
fi

# Last session summary
SESSION="$ROOT/docs/state/session.md"
if [ -f "$SESSION" ]; then
  echo "--- Last session ---"
  # Print from top through first blank line after the first "What was done" block
  awk '/^## Latest Session/,/^## [0-9]{4}-[0-9]{2}-[0-9]{2}/' "$SESSION" 2>/dev/null | head -20 || true
  echo ""
fi

# Blockers only
PLAN="$ROOT/docs/state/plan.md"
if [ -f "$PLAN" ]; then
  BLOCKERS=$(grep -i "BLOCKER\|\*\*BLOCKER" "$PLAN" 2>/dev/null | head -3 || true)
  if [ -n "$BLOCKERS" ]; then
    echo "--- Blockers ---"
    echo "$BLOCKERS"
    echo ""
  fi
fi

echo "=== run /shmorch go to start — Esc+Esc after go to reclaim context ==="
exit 0
