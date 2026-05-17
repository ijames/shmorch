#!/usr/bin/env bash
# Outputs INTERRUPTED if the previous session has no SESSION_END, otherwise CLEAN.
# Used by go.md Step 1. Call from any project root — uses git to locate it.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TIMELOG="$ROOT/docs/state/timelog.md"

if [ ! -f "$TIMELOG" ]; then
  echo "CLEAN"
  exit 0
fi

LAST=$(grep "SESSION_" "$TIMELOG" 2>/dev/null | tail -1)

if [[ "$LAST" == *"SESSION_START"* ]]; then
  echo "INTERRUPTED"
else
  echo "CLEAN"
fi
