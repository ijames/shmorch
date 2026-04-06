#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PLAN="$ROOT/shmorch/state/plan.md"
[ -f "$PLAN" ] || exit 0
if grep -q "| In progress |" "$PLAN" 2>/dev/null; then
  echo "Reminder: active track in progress — run /shmorch-sync before ending session."
fi
exit 0
