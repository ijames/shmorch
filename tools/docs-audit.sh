#!/usr/bin/env bash
# docs-audit.sh — deterministic tree-wide consistency scan for docs/, companion
# to track-graph-audit.sh (which only walks docs/{project,state}/tracks/).
# Checks links, front-matter placement, and cross-reference completeness —
# the mechanical half of what documentarian.md's Step 3+ still triages by hand.
#
# Pure detection — never writes. Prints one finding per line, machine-parseable:
#   DEAD_LINK <file> -> <target>              — relative link/path target doesn't exist on disk
#   MISSING_FRONTMATTER <file>                 — docs/{project,state}/*.md or docs/product/*.md
#                                                 (direct children only) missing the
#                                                 status/updated/summary block (core/documentation.md
#                                                 § Front-Matter Previews)
#   MISSING_PARENT_LINK <file>                  — non-index.md doc with no `↑` line
#   UNLINKED_FROM_INDEX <file>                  — file's section index.md never mentions it
#   ONE_WAY_RELATED <file> -> <target>          — `↔ related` link with no reciprocal link back
#   DUPLICATE_CONTENT <fileA> <fileB> <pct>%    — >= DUP_THRESHOLD% shared lines, same top-level
#                                                 category (cheap line-overlap heuristic — misses
#                                                 paraphrased duplication; that upgrade is semantic,
#                                                 not mechanical, see docs-audit-tool track)
#
# Used by workflows/documentarian.md Step 2, run alongside track-graph-audit.sh — same
# "scan mechanically, triage with judgment" split. This script only finds candidates.
#
# Usage: bash $SHMORCH_HOME/tools/docs-audit.sh
# Env:   DUP_THRESHOLD=40   percent line-overlap before two files are flagged as duplicates

set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DOCS="$ROOT/docs"
DUP_THRESHOLD="${DUP_THRESHOLD:-40}"

[ -d "$DOCS" ] || { echo "No $DOCS — nothing to audit."; exit 0; }

# --- DEAD_LINK ---
# Matches both markdown links [text](path) and bare backtick paths on ↑/→/↔ lines.
# Skips external links (http/https/mailto), pure anchors (#foo), and anything with a
# template placeholder (<...>).
while IFS= read -r -d '' f; do
  dir="$(dirname "$f")"
  # Strip backtick-delimited spans first — a link shown as example syntax inside
  # inline code (`[text](path.md#anchor)`) is prose, not a real reference.
  sed -E 's/`[^`]*`//g' "$f" 2>/dev/null | grep -oE '\]\(([^)]+)\)' | sed -E 's/^\]\((.*)\)$/\1/' | while IFS= read -r target; do
    [ -z "$target" ] && continue
    case "$target" in
      http://*|https://*|mailto:*|\#*|*"<"*) continue ;;
    esac
    clean="${target%%#*}"
    [ -z "$clean" ] && continue
    resolved="$dir/$clean"
    [ -e "$resolved" ] || echo "DEAD_LINK $f -> $target"
  done || true
done < <(find "$DOCS" -name '*.md' -print0)

# --- MISSING_FRONTMATTER ---
# Direct children only (not tracks/, not schedule/, not index.md) — matches whichever
# taxonomy generation this project is on (old docs/state/ or new docs/project/).
for base in project state; do
  [ -d "$DOCS/$base" ] || continue
  for f in "$DOCS/$base"/*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "index.md" ] && continue
    head -1 "$f" | grep -q '^---$' || echo "MISSING_FRONTMATTER $f"
  done
done
if [ -d "$DOCS/product" ]; then
  for f in "$DOCS/product"/*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "index.md" ] && continue
    head -1 "$f" | grep -q '^---$' || echo "MISSING_FRONTMATTER $f"
  done
fi

# --- MISSING_PARENT_LINK ---
while IFS= read -r -d '' f; do
  [ "$(basename "$f")" = "index.md" ] && continue
  grep -q '^↑' "$f" 2>/dev/null || echo "MISSING_PARENT_LINK $f"
done < <(find "$DOCS" -name '*.md' -print0)

# --- UNLINKED_FROM_INDEX ---
# docs/{project,state}/plan/ is a directory-scan registry by design (like inbox/'s inverse):
# backlog items are found by listing the directory, never by an index.md line, so concurrent
# stub tracks adding items never collide on a shared index.md edit. Skip it here.
while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  [ "$base" = "index.md" ] && continue
  dir="$(dirname "$f")"
  case "$dir" in
    "$DOCS/project/plan"|"$DOCS/state/plan") continue ;;
  esac
  index="$dir/index.md"
  [ -f "$index" ] || continue
  grep -qF "$base" "$index" 2>/dev/null || echo "UNLINKED_FROM_INDEX $f"
done < <(find "$DOCS" -name '*.md' -print0)

# --- ONE_WAY_RELATED ---
while IFS= read -r -d '' f; do
  dir="$(dirname "$f")"
  self="$(basename "$f")"
  grep '^↔' "$f" 2>/dev/null | grep -oE '\]\(([^)]+)\)' | sed -E 's/^\]\((.*)\)$/\1/' | while IFS= read -r target; do
    clean="${target%%#*}"
    [ -z "$clean" ] && continue
    resolved="$dir/$clean"
    [ -f "$resolved" ] || continue
    grep -q '^↔' "$resolved" 2>/dev/null && grep '^↔' "$resolved" | grep -qF "$self" && continue
    echo "ONE_WAY_RELATED $f -> $target"
  done || true
done < <(find "$DOCS" -name '*.md' -print0)

# --- DUPLICATE_CONTENT ---
# Compares files pairwise within the same top-level category only (keeps this O(n^2)
# bounded to a few dozen files at a time, not the whole tree).
for cat_dir in "$DOCS"/*/; do
  [ -d "$cat_dir" ] || continue
  files=()
  while IFS= read -r -d '' f; do files+=("$f"); done < <(find "$cat_dir" -name '*.md' -print0)
  n=${#files[@]}
  [ "$n" -lt 2 ] && continue
  for ((i=0; i<n; i++)); do
    for ((j=i+1; j<n; j++)); do
      a="${files[$i]}"; b="${files[$j]}"
      la=$(grep -cve '^\s*$' "$a" 2>/dev/null || echo 0)
      lb=$(grep -cve '^\s*$' "$b" 2>/dev/null || echo 0)
      { [ "$la" -lt 8 ] || [ "$lb" -lt 8 ]; } && continue
      shared=$(comm -12 <(grep -ve '^\s*$' "$a" | sort) <(grep -ve '^\s*$' "$b" | sort) | wc -l | tr -d ' ')
      smaller=$(( la < lb ? la : lb ))
      pct=$(( shared * 100 / smaller ))
      [ "$pct" -ge "$DUP_THRESHOLD" ] && echo "DUPLICATE_CONTENT $a $b ${pct}%"
    done
  done
done
