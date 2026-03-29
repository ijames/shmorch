#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
if [ ! -d ".git" ]; then echo "Not a git repo."; exit 1; fi
TS=$(date '+%Y-%m-%d %H:%M')
git add shmorch/state/ shmorch/CLAUDE.md 2>/dev/null || true
if git diff --cached --quiet; then
  echo "Nothing to checkpoint."
  exit 0
fi
git commit -m "checkpoint: shmorch state [$TS]"
echo "Checkpointed."
