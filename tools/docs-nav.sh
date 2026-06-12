#!/usr/bin/env bash
# docs-nav.sh — patch sibling navigation links into every doc in a docs/ tree
#
# Usage: bash tools/docs-nav.sh [docs-root]
# Default docs-root: docs/  (relative to current working directory)
#
# For each directory containing an index.md, reads the sibling .md files,
# extracts their # Title headings, and writes a "In this section:" nav line
# into each sibling. Each file's own name is excluded from its nav line.
#
# Injection point:
#   - Files with a ↑ up-link:   nav line inserted immediately after ↑ line
#   - Files with no ↑ up-link:  nav line inserted before the first # heading
#
# Safe to re-run — strips any existing nav line before re-inserting.

set -euo pipefail

DOCS="${1:-docs}"

if [[ ! -d "$DOCS" ]]; then
  echo "docs-nav: directory not found: $DOCS" >&2
  exit 1
fi

patched=0
=======
skipped=0
>>>>>>> c886980 (feat(tools): docs-nav.sh — auto-patch sibling nav links in docs/)

# join_with SEP elem [elem ...]
join_with() {
  local sep="$1"; shift
  local result=""
  for item in "$@"; do
    [[ -z "$result" ]] && result="$item" || result+="${sep}${item}"
  done
  printf '%s' "$result"
}

<<<<<<< HEAD
# extract_title FILE — first # heading, trailing punctuation/whitespace stripped
extract_title() {
  local title
  title="$(grep -m1 '^# ' "$1" 2>/dev/null | sed 's/^# //' | tr -d '\r' | sed 's/[[:space:]]*[–—:|-]*[[:space:]]*$//')"
  [[ -z "$title" ]] && title="$(basename "$1" .md)"
  printf '%s' "$title"
}

while IFS= read -r index_file; do
  dir="$(dirname "$index_file")"

  # Collect all sibling .md files (sorted, excluding index.md)
  sibling_files=()
  while IFS= read -r f; do
    sibling_files+=("$f")
  done < <(find "$dir" -maxdepth 1 -name "*.md" ! -name "index.md" | sort)

  [[ ${#sibling_files[@]} -eq 0 ]] && continue

  # Pre-extract titles into an associative array keyed by basename
  declare -A titles=()
  for sib in "${sibling_files[@]}"; do
    titles["$(basename "$sib")"]="$(extract_title "$sib")"
  done

  # Patch each sibling
  for sib in "${sibling_files[@]}"; do
    bname="$(basename "$sib")"

    # Build nav parts — every sibling except this file itself
    nav_parts=()
    for other in "${sibling_files[@]}"; do
      other_bname="$(basename "$other")"
      [[ "$other_bname" == "$bname" ]] && continue
      nav_parts+=("[${titles[$other_bname]}](${other_bname})")
    done

    [[ ${#nav_parts[@]} -eq 0 ]] && continue   # sole file — nothing to link

    nav_line="**In this section:** $(join_with ' · ' "${nav_parts[@]}")"

    tmp="$(mktemp)"

    if grep -q '^↑' "$sib" 2>/dev/null; then
      # Remove existing nav line, insert fresh one after the ↑ line
      awk -v nav="$nav_line" '
        /^\*\*In this section:/ { next }
        /^↑/                    { print; print nav; next }
        { print }
      ' "$sib" > "$tmp"
    else
      # No ↑ line — remove existing nav if any, insert before first # heading
      awk -v nav="$nav_line" '
        BEGIN { done = 0 }
        /^\*\*In this section:/ { next }
        /^# / && !done          { print nav; print ""; done = 1 }
        { print }
      ' "$sib" > "$tmp"
    fi

    mv "$tmp" "$sib"
    patched=$((patched + 1))
  done

  unset titles

done < <(find "$DOCS" -name "index.md" | sort)

echo "docs-nav: patched ${patched} file(s)"
