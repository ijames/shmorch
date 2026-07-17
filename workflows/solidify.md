# Workflow: Solidify

Deterministically restructure a project's `docs/` + `docs/state/` tree onto the Skeleton
Principle shape (`core/documentation.md`), regardless of how messy or partial it currently
is. Unlike `documentarian` (which audits parity between existing, roughly-skeleton-shaped
docs and code), solidify is the one-time or occasional *structural migration* a project runs
when its docs tree itself is out of shape — flat dumps, misplaced state, no `index.md`
surface maps.

Runs the same five phases in the same order on any project. Each phase writes its output to
a checkpoint file before the next phase starts — a session that stops after Classify resumes
directly at Restructure, never re-deriving a judgment call that's already on disk. Two runs
against the same unchanged input produce the same result, on any project, any session count.

## When to use

- A project's docs are a flat file dump with no category structure
- `docs/state/` has accumulated completed work that should have graduated
- Onboarding an existing/legacy codebase whose docs never followed the skeleton
- Never needed on a project already skeleton-compliant — use `documentarian` instead to keep it in parity

## Inputs

- `docs/` and `docs/state/` — the tree being restructured
- `core/documentation.md` — target shape (Skeleton Principle, Two-Tier Knowledge, Front-Matter Previews)
- `docs/state/solidify/checkpoint.md` — this run's persisted progress, if resuming

## Roles

- `agents/roles/documentarian.md` — Classify phase reuses its triage vocabulary and worldview verbatim; no second classification scheme

---

## Checkpoint file

Lives at `docs/state/solidify/checkpoint.md` in the **target project**, not in any track
directory — a project's docs tree can need re-solidifying long after whichever track
prompted the first run has closed, and a project may run solidify with no open track at all.

```markdown
---
phase: <inventory | classify | restructure | verify | done>
started: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Solidify Checkpoint

## Inventory
<manifest table — see Phase 1>

## Classify
<per-entry decision — see Phase 2>

## Restructure log
<moves actually applied — see Phase 3>

## Verify
<parity findings — see Phase 4>
```

If this file exists when solidify starts, read `phase:` from its front-matter and resume at
that phase — do not re-run completed phases. If it doesn't exist, start at Phase 1.

---

## Step 1 — Stamp

```bash
bash "$SHMORCH_HOME/tools/timelog.sh" "PHASE" "solidify: starting (resume: <phase-or-fresh>)"
```

---

## Phase 1 — Inventory

Skip if the checkpoint already has a completed Inventory section.

Walk the project:
```bash
find docs -type f -name "*.md" | sort
git log --diff-filter=A --name-only --format="%H %ad" --date=short -- docs | head -200
```

For every file, record: path, line count, front-matter if present (`status`/`updated`/`summary`),
last commit date that touched it. Write the manifest table to the checkpoint's `## Inventory`
section. Set `phase: inventory` complete, advance front-matter to `phase: classify`.

Do not classify yet — Inventory is purely descriptive.

---

## Phase 2 — Classify

Skip if the checkpoint already has a completed Classify section.

For every manifest entry, apply the `agents/roles/documentarian.md` triage vocabulary to
decide its target:

| Decision | Meaning | Action |
|---|---|---|
| `STAYS` | Already in correct skeleton location | No move |
| `MOVES → docs/<category>/<path>` | Wrong location, clear correct one | Queue for Phase 3 |
| `GRADUATES → docs/<category>/<path>` | Completed `docs/state/` content that should graduate per Two-Tier Knowledge | Queue for Phase 3 |
| `MERGES → <existing file>` | Duplicate or fragment of an existing doc | Queue for Phase 3 |
| `UNDECIDED` | Insufficient evidence to place confidently | Escalate to developer; do not move |

This is the expensive reasoning step — every decision must be written to the checkpoint
before moving to the next file. If interrupted mid-phase, the checkpoint shows exactly which
files are already classified; resume classifying only the remainder.

Present `UNDECIDED` items to the developer in a batch at the end of this phase — same rule
as documentarian: never resolve `UNDECIDED` unilaterally.

Set `phase: classify` complete, advance to `phase: restructure`.

---

## Phase 3 — Restructure

Skip if the checkpoint already has a completed Restructure log.

Apply **only** the moves/merges/graduations the Classify phase queued — no new judgment
calls here. For each:

1. `git mv` (preserves history) to the target path
2. Update the moved file's `↑` parent link and any `index.md` that should now reference it
3. Append the move to the checkpoint's `## Restructure log` immediately after it's applied

If a target `docs/<category>/index.md` doesn't exist yet, create it as a surface map (per
`core/documentation.md`) — a list of what's in the section, not a copy of the content.

Set `phase: restructure` complete, advance to `phase: verify`.

---

## Phase 4 — Verify

Skip if the checkpoint already has a completed Verify section.

Run the equivalent of `documentarian.md` Steps 4–5 against the new structure:
- Every `docs/<category>/` has an `index.md`
- No orphaned `↑`/`→` links (target path exists)
- No file left flat at a category root that should be in a subdirectory
- `docs/state/` contains only in-flight content — nothing that should have graduated in Phase 2 was missed

Write findings to the checkpoint's `## Verify` section. If gaps are found, return to Phase 2
for those specific entries only — do not restart Inventory.

Set `phase: verify` complete, advance to `phase: done`.

---

## Phase 5 — Checkpoint / close

```bash
bash "$SHMORCH_HOME/tools/timelog.sh" "PHASE" "solidify: complete — N moved, M graduated, K escalated"
```

Append a one-line summary to `docs/state/session.md`. Leave `docs/state/solidify/checkpoint.md`
in place with `phase: done` — it's the record that this project has been solidified once, and
the starting point (`git diff` against it) if solidify is run again later after more drift.

---

## Rules

- Never skip a phase's checkpoint write to "save time" — an unwritten decision is a decision
  that has to be redone, which breaks determinism across sessions.
- Never act on an `UNDECIDED` classification without developer sign-off.
- Restructure never invents a new classification — if Phase 2 didn't decide it, Phase 3 doesn't move it.
- Two sessions running solidify against the same checkpoint phase and the same unchanged
  `docs/` tree must produce the same classification — if a decision felt arbitrary, it belongs
  in `core/documentation.md` as a rule, not in this run's judgment.
