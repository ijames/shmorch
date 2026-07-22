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
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "documentarian: starting"
```

---

## Step 2 — Orient

Run these in parallel to build a picture before reasoning. The track scan is
deterministic — a script, not a main-thread read — so this workflow only pays reasoning
cost on the findings it actually needs to triage (`docs/state/tracks/20260721-workflow-subagent-delegation`):

```bash
# Deterministic traversal: chunk-size violations, missing front-matter,
# and CLOSED_UNGRADUATED candidates (closed track whose → destination doesn't
# reference it back — a proxy, not proof; see script header)
bash "$SHMORCH_HOME/tools/track-graph-audit.sh"

# Docs skeleton — what sections exist and what's in them
find docs -name "index.md" | sort
find docs -name ".gitkeep" | sort

# Recent code changes without doc changes (last 20 commits)
git log --oneline -20
```

For each `CLOSED_UNGRADUATED` line: read that track's index.md to extract the full `→
destination` line and confirm with a real read whether the knowledge landed — the script
flags candidates, it does not conclude.

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

Ensure the run artifacts directory exists:
```bash
mkdir -p docs/state/documentarian
```

If `docs/state/documentarian/index.md` does not exist, create it:
```markdown
# Documentarian Runs

↑ [docs/state/](../index.md)

Parity reports from `/shmorch documentarian` runs. Each file is a point-in-time audit.
Files are named `YYYYMMDD_parity-report.md`. The most recent run is the authoritative current state.

---

| Date | File | Findings | Resolved |
|---|---|---|---|
```

Write `docs/state/documentarian/YYYYMMDD_parity-report.md` (replace YYYYMMDD with today's date):
**Never write to `docs/state/parity-report-*.md` at the root level.**

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

## Step 9 — Update index and stamp

Add a row to `docs/state/documentarian/index.md` for this run:
```
| YYYY-MM-DD | [YYYYMMDD_parity-report.md](YYYYMMDD_parity-report.md) | N findings (summary) | Applied / Pending |
```

```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "documentarian: complete — N gaps closed, M items escalated"
```

Append a summary line to `docs/state/session.md`.
