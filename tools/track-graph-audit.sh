#!/usr/bin/env bash
# track-graph-audit.sh — deterministic traversal of docs/state/tracks/ for
# graph-first-docs conformance (tracks/20260525-graph-first-docs) and closed-track
# graduation (core/documentation.md § Skeleton Principle, Track closing process).
#
# Pure detection — never writes. Prints one finding per line, machine-parseable:
#   CHUNK_VIOLATION <file> <lines>        — file exceeds the single-responsibility line cap
#   MISSING_FRONTMATTER <file>            — no status/updated/summary front-matter block
#   CLOSED_UNGRADUATED <track> <dest...>  — Status: Closed but no destination doc references it back
#
# Used by workflows/documentarian.md Step 2 in place of ad hoc inline greps, so the
# mechanical scan runs as a deterministic script rather than main-thread/agent reads
# (docs/state/tracks/20260721-workflow-subagent-delegation). Judgment — whether a
# CLOSED_UNGRADUATED track's knowledge actually landed, and writing it if not — stays
# a documentarian pass (Step 3+); this script only finds candidates.
#
# Usage: bash $SHMORCH_HOME/tools/track-graph-audit.sh
# Env:   CHUNK_MAX=400   line-count cap before a file is flagged (default 400)

set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TRACKS="$ROOT/docs/state/tracks"
CHUNK_MAX="${CHUNK_MAX:-400}"

[ -d "$TRACKS" ] || { echo "No $TRACKS — nothing to audit."; exit 0; }

for track_dir in "$TRACKS"/*/; do
  [ -d "$track_dir" ] || continue
  track="$(basename "$track_dir")"
  index="$track_dir/index.md"
  [ -f "$index" ] || continue

  # --- chunk size + front-matter, every .md in the track ---
  for f in "$track_dir"*.md; do
    [ -f "$f" ] || continue
    lines=$(wc -l < "$f" | tr -d ' ')
    [ "$lines" -gt "$CHUNK_MAX" ] && echo "CHUNK_VIOLATION $f $lines"
    head -1 "$f" | grep -q '^---$' || echo "MISSING_FRONTMATTER $f"
  done

  # --- closed-track graduation check ---
  grep -qE "Status:.*Closed" "$index" || continue

  dest_line=$(grep -m1 '^→' "$index" || true)
  [ -n "$dest_line" ] || { echo "CLOSED_UNGRADUATED $track (no → destination header)"; continue; }

  # Extract candidate doc paths referenced in the → line (backtick or markdown-link form)
  dest_paths=$(echo "$dest_line" | grep -oE '[A-Za-z0-9_./-]+\.md' | sort -u)
  [ -n "$dest_paths" ] || { echo "CLOSED_UNGRADUATED $track -- destination not a resolvable path: $dest_line"; continue; }

  # ponytail: proxy for "graduated" is destination file mentions the track dir name
  # verbatim (backlink or prose reference) — cheap and false-positive-prone (misses
  # paraphrased integration), never false-negative-silent since Step 3 of
  # documentarian.md reviews every candidate before acting. Upgrade to semantic
  # content match only if false positives prove to cost real triage time.
  ungraduated=1
  for rel in $dest_paths; do
    for base in "$ROOT" "${SHMORCH_HOME:-}"; do
      [ -n "$base" ] || continue
      cand="$base/$rel"
      if [ -f "$cand" ] && grep -qF "$track" "$cand"; then
        ungraduated=0
      fi
    done
  done

  [ "$ungraduated" -eq 1 ] && echo "CLOSED_UNGRADUATED $track -- $(echo "$dest_paths" | paste -sd, -)"
done
