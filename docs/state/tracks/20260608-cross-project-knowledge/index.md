↑ [Shmorch Plan](../../plan.md)
→ new `knowledge/` directory in `~/.claude/skills/shmorch/`

# Track: Cross-project knowledge base

**Status:** Open
**Opened:** 2026-06-08
**Domain:** Knowledge management

## Why

Learnings from individual projects currently die in session logs. No mechanism carries a concept from one project forward to the next. Goal: a `knowledge/` directory in the shmorch skill that persists learnings across all projects over time.

Each entry: concept, date first encountered, project name + link, relevant commit SHA, why it matters. Organized by topic (version-control, deployment, testing, etc.).

Goal: Xanadu-style — every concept encountered on any project is traceable to where it was learned and why it mattered.

Connects to graph-first docs track — knowledge entries are nodes; project and commit links are edges.

Source: PholderShare version-control discussion 2026-06-08, proposed by James.

## What changes

- New `knowledge/` directory with topic-organized entry files
- Entry format: concept, date, project + link, commit SHA, why it matters
- `go.md` optionally surfaces relevant entries at session start based on the active tech stack

## Work log

### 2026-06-08
Concept proposed during PholderShare version-control discussion.
