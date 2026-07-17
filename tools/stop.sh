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
    bash "$SHMORCH_HOME/tools/timelog.sh" "SESSION_END" "auto-closed by stop hook"
  fi
fi

# Remind about active tracks
if [ -f "$PLAN" ] && grep -q "| In progress |" "$PLAN" 2>/dev/null; then
  echo "Reminder: active track in progress — run /shmorch wrap before ending session."
fi

# Docs placement reminder — opt-in via .shmorch/AGENTS.md "Docs Placement Hook" Status
AGENTS="$ROOT/.shmorch/AGENTS.md"
if [ -f "$AGENTS" ] && grep -A1 "Docs Placement Hook" "$AGENTS" 2>/dev/null | grep -qi "enabled"; then
  TOUCHED=$(git -C "$ROOT" status --porcelain -- docs/ 2>/dev/null | grep -v "docs/state/tracks/\|docs/state/plan.md\|docs/state/session.md\|docs/state/timelog.md" || true)
  if [ -n "$TOUCHED" ]; then
    echo "Docs changed this session — apply the vacuumer role's docs-placement check (agents/roles/vacuumer.md) before wrap."
  fi
fi

exit 0
