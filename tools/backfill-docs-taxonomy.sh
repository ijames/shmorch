#!/usr/bin/env bash
# Migrates a project's docs/ from the pre-20260724 skeleton
# (architecture/development/product/reference/state/to_review) to the
# current one (product/technology/reference/project/inbox). Run from the
# target project's repo root, or pass its path as $1.
#
# Mechanical git mv only. Files that need per-entry judgment (decisions,
# anti-decisions, dev notes, product concept docs with no direct new-home,
# deployment content buried in a guides/ index) are left in place and
# listed in the report for an agent/human pass — see
# docs/state/tracks/20260724-dev-docs-taxonomy-backfill/index.md.
set -euo pipefail
ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

if [ ! -d docs/state ] && [ ! -d docs/architecture ] && [ ! -d docs/development ]; then
  echo "No old-skeleton docs/ found under $ROOT (docs/state, docs/architecture, docs/development all absent). Nothing to do."
  exit 0
fi

# old-path:new-path, mechanical 1:1 moves only.
MAPPING=(
  "docs/architecture/domains.md:docs/technology/architecture/domains.md"
  "docs/architecture/index.md:docs/technology/architecture/index.md"
  "docs/architecture/observability.md:docs/technology/architecture/observability.md"
  "docs/architecture/system-overview.md:docs/technology/architecture/system-overview.md"
  "docs/development/code-styleguides:docs/technology/development/code-styleguides"
  "docs/development/testing:docs/technology/development/testing"
  "docs/development/tech-stack.md:docs/technology/development/tech-stack.md"
  "docs/development/workflow.md:docs/technology/development/workflow.md"
  "docs/development/index.md:docs/technology/development/index.md"
  "docs/development/guides/setup.md:docs/reference/instructions/install.md"
  "docs/product/analytics.md:docs/product/strategy/analytics.md"
  "docs/product/roadmap.md:docs/product/strategy/roadmap.md"
  "docs/product/seo-geo.md:docs/product/strategy/seo-geo.md"
  "docs/product/design.md:docs/product/design/design.md"
  "docs/state/context.md:docs/project/context.md"
  "docs/state/plan.md:docs/project/plan.md"
  "docs/state/session.md:docs/project/session.md"
  "docs/state/spec.md:docs/project/spec.md"
  "docs/state/timelog.md:docs/project/timelog.md"
  "docs/state/index.md:docs/project/index.md"
  "docs/state/schedule:docs/project/schedule"
  "docs/state/tracks:docs/project/tracks"
  "docs/to_review/README.md:docs/inbox/index.md"
)

# old-path, real content, no mechanical mapping — needs an agent/human judgment pass.
JUDGMENT=(
  "docs/architecture/decisions.md — split entries into docs/technology/decisions/"
  "docs/development/decisions.md — split entries into docs/{product,technology}/decisions/"
  "docs/development/anti-decisions.md — split entries into docs/{product,technology}/decisions/anti-decisions.md"
  "docs/development/notes.md — fold into docs/technology/development/concepts/ or keep standalone"
  "docs/development/guides/index.md — deployment content, if any, to flat docs/reference/instructions/deployment.md"
  "docs/product/cognitive-architecture.md — no direct new home, review against docs/product/design/concepts/ (or similar product concept docs)"
)

MOVED=()
SKIPPED=()
for pair in "${MAPPING[@]}"; do
  old="${pair%%:*}"
  new="${pair##*:}"
  if [ ! -e "$old" ]; then
    continue
  fi
  mkdir -p "$(dirname "$new")"
  git mv "$old" "$new"
  MOVED+=("$old -> $new")
done

# Empty leftover dirs (old skeleton dirs with nothing left but a .gitkeep or judgment files).
for d in docs/architecture docs/development docs/development/guides docs/to_review docs/state; do
  if [ -d "$d" ] && [ -z "$(find "$d" -mindepth 1 -not -name '.gitkeep')" ]; then
    rm -rf "$d"
  fi
done

echo "# Docs taxonomy backfill — $ROOT"
echo ""
echo "## Moved (${#MOVED[@]})"
for m in "${MOVED[@]}"; do echo "- $m"; done
echo ""
echo "## Needs judgment pass (left in place)"
for j in "${JUDGMENT[@]}"; do
  path="${j%% —*}"
  [ -e "$path" ] && echo "- $j"
done
echo ""
echo "Review the judgment list above, then commit."
