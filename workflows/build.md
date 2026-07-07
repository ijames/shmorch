# Workflow: Build

Implement an approved spec and design. Produces committed, tested, documented code.

> **Read `.shmorch/agents/TASK-PROTOCOL.md` before starting.**

---

## When to use
- When outcome and approach are both clear (spec written, design approved)
- When the user says "let's build" or "start implementing"
- After Design workflow has produced an approved design

## Inputs
- Approved spec (`docs/state/spec.md` or track-level spec)
- Design doc (`docs/state/design-<feature>.md` if present)
- `docs/state/stack.md` — version constraints and external limits

## Roles
- `agents/roles/implementer.md` (one per module for large features, run in parallel)

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

State files (`docs/state/`, `docs/development/decisions.md`) are the only content that commits directly to main — via `/shmorch wrap`, never manually during a build.

---

## Step 2 — Stamp and prep
```bash
bash $SHMORCH_HOME/tools/timelog.sh "TASK_START" "<track name>"
```

Set status `IN_PROGRESS` in `docs/state/plan.md`.

Read the approved spec and design:
- `docs/state/spec.md` (or track-level spec)
- `docs/state/design-<feature>.md` (if exists)

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

Write this list to `docs/state/plan.md` under the active task.

4. **Seed scripts (stage-gated):** If this implementation writes or modifies any migration files (`db/migrations/`, `migrations/`, `alembic/versions/`, or similar), apply the following check based on the project `stage` from `docs/state/context.md`:
   - **R&D / proof-sprint:** List every seed/fixture script that populates the affected tables. Flag each as "potentially stale — verify schema alignment before running `make db-seed` or equivalent." Updating stale seeds is part of the Definition of Done for this task, not a follow-up.
   - **productionization / maintenance:** Seed scripts are not the authoritative data source in production. Instead: flag that this migration must be validated against a production branch restore (e.g. Neon copy-on-write branch from the production branch) before applying. Seeds are a dev scaffold only — live data comes from backups, not seeds.

**Gate condition:** Do not start Step 3 until this list exists. When implementation completes (Step 4), use this list as the doc/test update checklist — not just the DoD checklist.

---

## Step 3a — Small feature: implement directly

Write code, tests, and doc updates as a single unit. Proceed to Step 4.

## Step 3b — Large feature: Call Task (parallel implementers)

Identify up to 4 independent modules. For each, call Task. Parallel calls are allowed when modules don't share write targets.

```
Task(
  description: "Implementer: <module>",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/implementer.md` first (project override); if not present, use `$SHMORCH_HOME/agents/roles/implementer.md` (skill default). Act according to the role definition found.

    ## Task
    Implement: <module>

    Spec: docs/state/spec.md
    Design: docs/state/design-<feature>.md (read if present)
    Stack constraints: docs/state/stack.md (read this; for other context load only what the task requires — do not pre-scan the whole codebase)

    Write production code and corresponding tests. Follow the existing patterns in the codebase.
    Do not change test logic to make tests pass — if tests fail after your change, the code is wrong.

    ## Output
    Write a completion note to: docs/state/build-<module-slug>.md

    Structure:
    ### Module: <module>
    ### Files changed
    <list>
    ### Tests written
    <list>
    ### Notes
    <anything the orchestrator should know before integration>

    ## Return
    DONE: docs/state/build-<module-slug>.md | <one-line summary> [| BLOCKER if a design gap or constraint prevented completion]
)
```

Stamp each:
```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_SPAWN" "implementer → <module>"
```

### Gate after parallel implementers

After all Task calls complete:
- Verify each `docs/state/build-<module>.md` exists
- If any BLOCKER: surface to developer before integration
- Stamp:
```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_DONE" "implementer → <module>"
```

---

## Step 4 — Definition of Done checklist

Run through this before committing. Do not split into separate commits — code + tests + docs together.

### Correction check

If any correction was already applied during this task (a fix to wrong logic, a misunderstood requirement, a behavioral change):
- **Stop before the next change.** Briefly describe what you understood, what was wrong, and your revised understanding.
- Ask the developer to confirm before continuing.

One correction can be a misread. Two means the semantics weren't locked in — confirm before committing more code.

### Tests
- New or changed public methods: tests written and passing?
- Run the full test suite — no regressions?
- (See `.shmorch/AGENTS.md` for project-specific test command and framework guidance)
- **Framework choice:** Behat for order loop lifecycle behavior, user-facing outcomes, and integration sequences with scripted collaborators. PHPUnit for internal calculation logic, price/quantity rules, and injectable components.
- **Broad replacement guard:** If this commit includes a text replacement touching > 5 files (e.g. renaming a symbol, fixing encoding across the codebase), run the full test suite *before* committing — sweeps can silently mutate string literals and operator expressions in addition to comments.

### Documentation
- Public API, architectural pattern, or data model changed? Update `docs/architecture/` or `docs/development/`.
- New service, model, or exception type? Document in the relevant architecture doc.
- Does `docs/state/tracks/` need updating?
- Did this change countermand something previously documented? Rewrite that section — don't append.

### Track
- Is this tied to an open track step? Mark it done.
- No track exists and this is non-trivial? Create one using `.shmorch/docs/track-template.md`.
- Update `docs/state/plan.md`.

### Plan alignment
- Does the implementation use the patterns and dependencies specified in the design? Actively verify — no deprecated API, no undeclared new dependency, no undeclared framework introduced.
- If a subagent was used: read its `build-<module>.md` Notes section — did it flag any constraint deviations?
- If any deviation was necessary: it must be recorded in `decisions.md` before this step passes.

---

## Step 5 — Stamp and hand off
```bash
bash $SHMORCH_HOME/tools/timelog.sh "TASK_DONE" "<track name>"
```

Set status `DONE` in `docs/state/plan.md`. Update `docs/state/session.md`.

Suggest: `/shmorch vacuum` → `/shmorch commit` → `/shmorch wrap`
