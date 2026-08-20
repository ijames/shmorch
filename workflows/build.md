---
loads_when: time to code an approved spec and design
size: 285 lines
---

# Workflow: Build

Implement an approved spec and design. Produces committed, tested, documented code.

> **Read `.shmorch/agents/TASK-PROTOCOL.md` before starting.**

---

## When to use
- When outcome and approach are both clear (spec written, design approved)
- When the user says "let's build" or "start implementing"
- After Design workflow has produced an approved design

## Inputs
- Approved spec (`docs/project/spec.md` or track-level spec)
- Design doc (`docs/project/design-<feature>.md` if present)
- `docs/project/stack.md` — version constraints and external limits

## Roles
- `agents/roles/implementer.md` (one per module for large features, run in parallel)
- `agents/roles/critic.md` (adversarial verification pass after implementation, before DoD)

---

## Before Starting Any Implementation

> **REQUIRED — do this before writing a single line of code or editing any file.**

### Intent

Intent is not a document — it is the synthesized understanding formed by reading the project corpus: specs, architecture decisions, product goals, existing tests, prior decisions. Before any build task, read enough of the corpus to answer: *what should this piece do, and why does it fit here?* Intent is abstract and resolved into the process as concrete artifacts (tests, code, docs). There is no "intent document" to check off.

### Order: tests before behavior, always

Tests are written before behavior is implemented — no exceptions. This applies to every task, including "trivial" ones. The implementation is never written first and tests added after.

### Simulate before implementing

Before writing production code, Claude must be able to simulate the implementation:

1. **Write the tests** (RED). Tests must fail — but fail for the right reason (the behavior doesn't exist yet, not a syntax error or wrong import).
2. **Simulate the implementation in reasoning**: given the test inputs, trace what the correct implementation would compute and what it would return. Produce the expected outputs.
3. **Validate the simulation** against the tests and docs: do the expected outputs match the test assertions? Do they match what the docs describe? If not, the tests or docs are wrong — fix them before implementing.
4. **Implement** — the minimum code to make the tests pass. The simulation should already confirm the design is correct, so implementation should have no surprises.
5. **Verify** — tests go GREEN. Simulation matched reality.

This simulation step is a design validation. It catches design errors before they become code. A Claude that cannot simulate the correct output for a test does not yet understand the intent well enough to implement.

### Confirm the phase

- **RED phase** (writing failing tests): goal is tests that fail for the right reason. No production code. Functional/integration tests before unit tests.
- **GREEN phase** (making tests pass): minimum code to pass. No extra behavior.
- **Refactor**: no new behavior; tests must stay green.

### 95% confidence interview

Say exactly this:

> "I'm about to start this task. I'm going to interview you until I have 95% confidence about what you actually want, not what you think you should want."

Ask one focused question at a time: outcome, constraints, non-goals, assumed approach. Do not start until you've reached 95% confidence.

**This workflow covers code, tests, and infra builds.** For infra, the "simulation" is: describe the expected resource topology and verify it matches the architecture docs before writing any IaC.

---

## Step 0.5 — External API feasibility check

**If the task touches any external API, do this before writing a single line of code:**

1. Name every endpoint the implementation will call
2. Confirm each is accessible via the current OAuth / developer API (not an internal gateway)
3. Verify the expected response shape with a live test call or documented schema
4. If any endpoint is inaccessible or the response differs from assumptions — **stop and surface this to the user before proceeding**

Pattern that triggered this rule: an OCO continuation arm wasted a full session targeting an internal gateway endpoint (`ausgateway.schwab.com`) inaccessible via the developer API. Stop earlier.

---

## Step 1 — Branch setup

Before writing any code, verify you are on the correct feature branch:

```bash
git branch --show-current
```

If on `main`: prompt the user to create an appropriate feature branch before proceeding:
> "You're on main. This work belongs on a feature branch — create one now?"

Default branch naming: `<type>/YYYYMMDD-<short-description>` where type is one of `feat`, `fix`, `chore`, `refactor`, `docs`. Example: `feat/20260519-order-ticker`, `chore/20260519-vacuum`. If the project has a different convention in `decisions.md` or a project `build.md` override, apply that instead.

State files (`docs/project/`, `docs/{product,technology}/decisions/ (topic-appropriate)`) are the only content that commits directly to main — via `/shmorch wrap`, never manually during a build.

---

## Step 2 — Stamp and prep
```bash
bash $SHMORCH_HOME/tools/timelog.sh "TASK_START" "<track name>"
```

Set `status: in-progress` on the active track's item file in `docs/project/plan/`.

Read the approved spec and design:
- `docs/project/spec.md` (or track-level spec)
- `docs/project/design-<feature>.md` (if exists)

Read only these files at session start. Do not pre-load architecture docs or source files not directly referenced by the spec — retrieve dynamically via targeted reads as needed.

---

## Step 2 — Decompose

Break the implementation into modules or layers that can be implemented independently. Small features (single file, < 2 hours): implement directly in Step 3a. Large features (multiple modules): use Step 3b.

---

## Step 2b — Propagation gate (required before any implementation)

Before writing code, enumerate:
1. **Affected docs:** Which architecture docs, API docs, or track docs will need updating if this spec is implemented? List them.
2. **Affected tests:** Which existing tests are likely to need updating? List them. If none, confirm why.
3. **Affected decisions:** Does this implementation require a new entry in decisions.md, or update an existing one?

Write this list to `docs/project/plan/` under the active task.

4. **Seed scripts (stage-gated):** If this implementation writes or modifies any migration files (`db/migrations/`, `migrations/`, `alembic/versions/`, or similar), apply the following check based on the project `stage` from `docs/project/context.md`:
   - **R&D / proof-sprint:** List every seed/fixture script that populates the affected tables. Flag each as "potentially stale — verify schema alignment before running `make db-seed` or equivalent." Updating stale seeds is part of the Definition of Done for this task, not a follow-up.
   - **productionization / maintenance:** Seed scripts are not the authoritative data source in production. Instead: flag that this migration must be validated against a production branch restore (e.g. Neon copy-on-write branch from the production branch) before applying. Seeds are a dev scaffold only — live data comes from backups, not seeds.

**Gate condition:** Do not start Step 3 until this list exists. When implementation completes (Step 4), use this list as the doc/test update checklist — not just the DoD checklist.

---

## Step 3a — Small feature: implement directly

Write code, tests, and doc updates as a single unit. Proceed to Step 4.

## Step 3b — Large feature: spawn Task agents

Default is Task agents — one per independent module, up to 4. Call Task for each module
unless the module is so tightly entangled with in-flight context that fully briefing an
agent would cost more than implementing it directly; in that case implement it inline and
note why. Parallel calls are allowed when modules don't share write targets.

```
Task(
  description: "Implementer: <module>",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/implementer.md` first (project override); if not present, use `$SHMORCH_HOME/agents/roles/implementer.md` (skill default). Act according to the role definition found.

    ## Task
    Implement: <module>

    Spec: docs/project/spec.md
    Design: docs/project/design-<feature>.md (read if present)
    Stack constraints: docs/project/stack.md (read this; for other context load only what the task requires — do not pre-scan the whole codebase)

    Write production code and corresponding tests. Follow the existing patterns in the codebase.
    Do not change test logic to make tests pass — if tests fail after your change, the code is wrong.

    ## Output
    Write a completion note to: docs/project/build-<module-slug>.md

    Structure:
    ### Module: <module>
    ### Files changed
    <list>
    ### Tests written
    <list>
    ### Notes
    <anything the orchestrator should know before integration>

    ## Return
    DONE: docs/project/build-<module-slug>.md | <one-line summary> [| BLOCKER if a design gap or constraint prevented completion]
)
```

Stamp each:
```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_SPAWN" "implementer → <module>"
```

### Gate after parallel implementers

After all Task calls complete:
- Verify each `docs/project/build-<module>.md` exists
- If any BLOCKER: surface to developer before integration
- Stamp:
```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_DONE" "implementer → <module>"
```

### Adversarial verification pass

For each module (or once, if a single implementer was used for a small feature — this pass isn't limited to Step 3b's parallel case), call Task with the critic role to check the implementation against the docs, not against the implementer's own report:

```
Task(
  description: "Critic: <module>",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/critic.md` first (project override); if not present, use `$SHMORCH_HOME/agents/roles/critic.md` (skill default). Act according to the role definition found.

    ## Task
    Review the implementation of <module> against:
    - Spec: docs/project/spec.md
    - Design: docs/project/design-<feature>.md (if present)
    - Stack constraints: docs/project/stack.md
    - The implementer's own report: docs/project/build-<module-slug>.md

    Verify against the docs, not against what the implementer claims — the report describes
    intent, not ground truth. Look for spec/design deviations, missing edge cases, untested
    public methods, and gaps between what the docs require and what was actually built.

    ## Output
    Write your findings to: docs/project/build-<module-slug>-review.md

    ## Return
    DONE: docs/project/build-<module-slug>-review.md | <verdict> [| BLOCKER if any blocker found]
)
```

If any BLOCKER: fix it before proceeding to Step 4 — do not carry a known blocker into the DoD checklist. If the critic reports NEEDS WORK with only RISK/ASSUMPTION/GAP findings (no BLOCKER), use judgment: fix now or note explicitly in `docs/project/build-<module-slug>.md` Notes why it's deferred.

---

## Step 4 — Definition of Done checklist

Run through this before committing. Do not split into separate commits — code + tests + docs together.

### Correction check

If any correction was already applied during this task (a fix to wrong logic, a misunderstood requirement, a behavioral change):
- **Stop before the next change.** Briefly describe what you understood, what was wrong, and your revised understanding.
- Ask the developer to confirm before continuing.

One correction can be a misread. Two means the semantics weren't locked in — confirm before committing more code.

### Tests
- Did any new public methods get added or changed? If so, are they tested and passing?
- Run the full test suite — no regressions?
- (See `.shmorch/AGENTS.md` for project-specific test command and framework guidance)
- **Framework choice:** Behat for order loop lifecycle behavior, user-facing outcomes, and integration sequences with scripted collaborators. PHPUnit for internal calculation logic, price/quantity rules, and injectable components.
- **Broad replacement guard:** If this commit includes a text replacement touching > 5 files (e.g. renaming a symbol, fixing encoding across the codebase), run the full test suite *before* committing — sweeps can silently mutate string literals and operator expressions in addition to comments.

### Documentation
- Public API, architectural pattern, or data model changed? Update `docs/technology/architecture/` or `docs/technology/development/`.
- New service, model, or exception type? Document in the relevant architecture doc.
- Does `docs/project/tracks/` need updating?
- Did this change countermand something previously documented? Rewrite that section — don't append.

### Track
- Fill in the track's `↑` source and `→` destination links before writing anything else — if you can't fill in the destination, the track isn't scoped. Do this before implementation, not retroactively at this checklist.
- Is this tied to an open track step? Mark it done.
- No track exists and this is non-trivial? Create one using `.shmorch/docs/track-template.md`.
- Update `docs/project/plan/`.
- **Before opening the PR:** update the track's `index.md` Status field to reflect the state the merge will produce (e.g. `Open — Intent + Spec` → `Shipped` / `Closed`), not the state it's in mid-build. Stale status fields caught only by later documentarian sweeps are the recurring failure mode this guards against — fix it at the point of change, not in batch later.
- **Growth check:** whenever this checklist touches a track's `index.md`, `wc -l` it. If it now exceeds ~200–300 lines, split per `core/documentation.md` § Track file growth right here rather than waiting for `wrap`'s end-of-session pass — same date/version-based vs. section-based choice, applied at the point of change per "Continuous state updates, deferred intent."

### Plan alignment
- Does the implementation use the patterns and dependencies specified in the design? Actively verify — no deprecated API, no undeclared new dependency, no undeclared framework introduced.
- If a subagent was used: read its `build-<module>.md` Notes section — did it flag any constraint deviations?
- If any deviation was necessary: it must be recorded in `decisions.md` before this step passes.

### Commit grouping
If tests or docs are missing, do not commit the code alone. Either finish them now, or create a track step to complete them and note the gap explicitly — never leave an implicit gap for a later session to discover.

### Checklist Summary
Before committing, confirm all four:
- [ ] Tests written and passing, no regressions
- [ ] Docs updated (or explicitly not needed)
- [ ] Track/plan status current
- [ ] No unrecorded deviation from the design

---

## Step 5 — Stamp and hand off
```bash
bash $SHMORCH_HOME/tools/timelog.sh "TASK_DONE" "<track name>"
```

Set `status: done` on the active track's item file in `docs/project/plan/` (or delete it — git history keeps it, matching the inbox ADDRESSED convention). Update `docs/project/session.md`.

Suggest: `/shmorch vacuum` → `/shmorch commit` → `/shmorch wrap`
