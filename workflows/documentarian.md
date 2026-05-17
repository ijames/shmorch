# Workflow: Documentarian

Audit and repair the relationship between documentation, code, and tests. Docs are the primary source of truth — discrepancies do not automatically mean the doc is wrong. Each divergence requires triage.

## When to use
- After one or more tracks close (verify knowledge landed in destination docs)
- When docs feel out of sync with the codebase
- As part of a sprint retrospective
- When a new developer needs to be onboarded (docs should tell the story without gaps)

## Inputs
- `docs/state/tracks/` — closed track directories with `→ destination` headers
- `docs/` — skeleton structure and existing docs
- `git log --oneline -20` — recent code changes

## Roles
- `agents/roles/documentarian.md`

---

## Step 1 — Stamp

```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "documentarian: starting"
```

---

## Step 2 — Orient

Run these in parallel to build a picture before reasoning:

```bash
# Closed tracks and their → destinations
grep -rl "Status: Closed\|Status: Done" docs/state/tracks/ 2>/dev/null

# Docs skeleton — what sections exist and what's in them
find docs -name "index.md" | sort
find docs -name ".gitkeep" | sort

# Recent code changes without doc changes (last 20 commits)
git log --oneline -20
```

For each closed track found: read its index.md to extract the `→ destination` line.

---

## Step 3 — Closed track knowledge check

For each closed track flagged by the scanner:

1. Read the track's `→ destination` header — which docs sections were supposed to receive its knowledge?
2. Read those destination sections now
3. Check: is the knowledge from the track actually present in the destination? Be specific — not "it mentions it" but "the specific findings, decisions, and behaviors are documented"
4. If missing: flag for Step 6

---

## Step 4 — Docs skeleton audit

For each docs section (product/, architecture/, development/, reference/, guides/):

1. Does an `index.md` exist and describe what belongs here?
2. Are the files that should exist actually present? (Use the project's domains.md or equivalent as the reference for what _should_ be documented)
3. Are there stub files (e.g. `.gitkeep`, placeholder `*No content yet*`) where real content belongs?

Flag gaps for Step 6.

---

## Step 5 — Parity triage (the critical step)

For every discrepancy between docs, code, and tests — **docs are the primary source of truth.** A discrepancy does not mean the doc is stale; it may mean:

- The code diverged from intent (a bug or undocumented change)
- The tests don't cover the intended behavior (a test gap)
- The doc was written before implementation and needs updating (doc stale)

**Triage protocol for each discrepancy:**

1. **Read the doc** — what does it say the behavior is?
2. **Read the tests** — what behavior is verified?
3. **Read the code** — what does it actually do?
4. **Check git log** for all three files — when did each last change, and why?
5. **Check `docs/development/decisions.md`** — was there a decision that explains the divergence?
6. **Check Zulip** (if connected) — was there a discussion about this behavior?

Then classify:
- `DOC_STALE` — documented intent was deliberately changed; update the doc
- `CODE_DIVERGED` — code moved away from documented intent without a decision; flag for developer review
- `TEST_GAP` — behavior is correct but not tested; file a plan.md item
- `UNDECIDED` — insufficient evidence; escalate to developer before changing anything

**Never change a doc, test, or code to resolve a discrepancy without classifying it first.** `UNDECIDED` items must go to the developer.

---

## Step 6 — Write parity report

Write `docs/state/parity-report-YYYYMMDD.md`:

```markdown
# Parity Report — YYYY-MM-DD

## Track Knowledge Gaps
- Track `YYYYMMDD-name`: knowledge not found in → destination `docs/section/file.md`

## Docs Skeleton Gaps
- `docs/section/` — missing: file.md (expected because X)

## Discrepancies
### DOC_STALE
- `docs/X.md`: says Y; code does Z; decision [date] changed intent — update doc

### CODE_DIVERGED
- `htdocs/X.php`: does Z; doc says Y; no decision found — needs developer review

### TEST_GAP
- Behavior documented in `docs/X.md` §Y has no test coverage — filed in plan.md

### UNDECIDED
- `docs/X.md` vs `htdocs/Y.php`: conflicting; insufficient history — escalate
```

---

## Step 7 — Review with developer

Present the report summary. For each item requiring a decision (CODE_DIVERGED, UNDECIDED), ask the developer explicitly before acting.

For DOC_STALE and TEST_GAP items, get batch approval then execute.

---

## Step 8 — Execute approved changes

Apply in this order:
1. Docs updates (DOC_STALE) — write to the correct section, not a new file
2. Plan.md additions (TEST_GAP) — file as backlog items
3. Track knowledge integration — extract and write to `→ destination` docs

After each batch of changes, verify the docs still form a consistent skeleton (no orphaned links, no contradictions introduced).

---

## Step 9 — Stamp completion

```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "documentarian: complete — N gaps closed, M items escalated"
```

Append a summary line to `docs/state/session.md`.
