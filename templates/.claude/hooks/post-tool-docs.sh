#!/usr/bin/env bash
# PostToolUse hook — fires right after a docs file is written/edited, while
# context is still just that one file. Opt-in via .shmorch/AGENTS.md "Docs
# Placement Hook" Status; never blocks, only reminds.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
AGENTS="$ROOT/.shmorch/AGENTS.md"
[ -f "$AGENTS" ] || exit 0
grep -A1 "Docs Placement Hook" "$AGENTS" 2>/dev/null | grep -qi "enabled" || exit 0

INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

case "$FILE" in
  */docs/state/tracks/*) exit 0 ;;   # tracks own their own shape rules
  */docs/*.md)
    echo "Just wrote $FILE — check vacuumer's docs-placement rules now (agents/roles/vacuumer.md): right docs/<category>/, index.md links it, front-matter if under docs/state/."
    ;;
esac
exit 0
