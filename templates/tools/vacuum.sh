#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
TS=$(date '+%Y%m%d-%H%M%S')
REPORT="shmorch/state/vacuum-report-$TS.md"
echo "# Vacuum Report — $TS" > "$REPORT"
echo "## TODOs / FIXMEs" >> "$REPORT"
grep -rn "TODO\|FIXME\|HACK" \
  --include="*.ts" --include="*.js" --include="*.py" --include="*.tsx" \
  --include="*.php" --include="*.rb" --include="*.go" --include="*.rs" \
  . 2>/dev/null | grep -v "\.git" | grep -v "shmorch/" | head -40 >> "$REPORT" || echo "_none_" >> "$REPORT"
echo "" >> "$REPORT"
echo "## Empty Test Files" >> "$REPORT"
find . \( -name "*.test.*" -o -name "*.spec.*" -o -name "*Test.php" -o -name "*_test.php" \) \
  2>/dev/null | grep -v "\.git" | grep -v "vendor/" | while read -r f; do
  [ "$(wc -l < "$f")" -lt 3 ] && echo "$f"
done >> "$REPORT" || true
echo "" >> "$REPORT"
echo "_Review this, then confirm deletions in Shmorch_" >> "$REPORT"
echo "Report: $REPORT"; cat "$REPORT"
