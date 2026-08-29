---
status: Open
updated: 2026-08-24
summary: Seven rungs for moving Shmorch rules from instruction to enforcement, the script-vs-hook portability split, and the list of what should deliberately stay probabilistic.
---

↑ [Track index](index.md)
**In this section:** [Blog revisions — additive only](blog-revision.md) · ["The Wild West of AI" — capture and fairness assessment](wild-west-post.md)

# The Determinism Ladder

## The organizing principle

**Determinism at the edges, judgment in the middle.**

The model should be confined to the steps that actually require judgment. Everything that
surrounds those steps — triggers, state transitions, link maintenance, gates, validation —
is machinery, and machinery should be code. Today Shmorch narrates the machinery in prose
and asks the model to perform it faithfully every time.

Three conversions capture most of the available leverage:

| From | To | Why |
|---|---|---|
| Instructed | **Generated** | A link the model is told to maintain drifts. A link a script emits cannot. |
| Attested | **Validated** | "Confirm the manifest is synced" is a self-report. `grep pkg requirements.txt` is a fact. |
| Checklist | **Exit code** | A four-item DoD in markdown is four chances to skip one. A script exits 1 or it doesn't. |

## The portability split — this resolves the hooks-break-portability objection

Two different determinism mechanisms, different properties, and the objection dissolves
once they're kept apart:

| Mechanism | Property | Portability | Use for |
|---|---|---|---|
| **Script** (`tools/*.sh`, called by a workflow) | Deterministic *when run* | Universal — every CLI can run bash | The default. Everything in Rungs 1–5 |
| **Hook** (harness-fired, `PreToolUse`/`PostToolUse`) | Deterministic *and unskippable* | Claude Code only | The short list of true invariants, layered on top |

The rule: **write the script first, always.** It works on omp, Pi, Codex, Gemini,
opencode, Cursor, Antigravity. Then, where the rule is a genuine invariant that must not be
bypassable even by a model that decided to skip a step, add a hook that calls *the same
script*. CLIs without hooks degrade to "the workflow calls it," which is exactly today's
reliability — no worse — while Claude Code gets "it cannot be skipped."

No logic ever lives in the hook. The hook is a trigger; the script is the truth. That keeps
`core/portability.md` satisfied and avoids forking behavior per CLI.

---

## Rung 0 — Inventory what is actually judgment

Prerequisite, and cheap. Walk `core/` and `workflows/` and label every rule:

- **Mechanical** — a script could decide it (does the file exist, does the grep hit, is the manifest stale, did the test commit precede the code commit)
- **Judgment** — requires reading intent (is this spec good, is this the right architecture, is this the top priority)
- **Mixed** — a judgment with a mechanically checkable *shape* (a spec is judged, but "has all required sections" is not)

Expectation: the mechanical bucket is much larger than it feels while writing doctrine. The
mixed bucket is where Rung 4 pays off. Only the judgment bucket is irreducible.

## Rung 1 — Generators over instructions

**Model already in the repo: `docs-nav.sh`.** Sibling nav links are not maintained by
anyone; they are regenerated, so they cannot drift. That is the pattern to extend.

Candidates — anywhere doctrine says "keep X in sync" or "update the links":

- index files and `In this section:` nav (done)
- track `→ destination` and `↑ source` back-links
- `core/index.md`'s table vs. the actual `core/*.md` frontmatter (currently hand-maintained, already a drift risk)
- plan `status:` rollups into `index.md` Current Activities
- the doctrine map in `shmorch-core.md` vs. what exists on disk

Every one of these is currently a rule the model is asked to remember. Each becomes a
generator that is simply re-run.

## Rung 2 — Validators that exit nonzero

**Model already in the repo: `check-session-state.sh`, `check-self-improve-gate.sh`.**
Underused. These replace self-attested checklists.

Highest-value new checks:

- `check-manifest-sync.sh` — dependency file newer than deployment manifest → exit 1. Kills a whole class of "green CI, broken deploy."
- `check-test-first.sh` — for a build track, assert the test file's first commit precedes the implementation's. Mechanizes the always-red rule instead of asserting it.
- `check-generated-files.sh` — auto-generated files modified outside their generator → exit 1.
- `check-dod.sh` — the `build.md` Definition of Done as an actual gate rather than a list to read.

Note what this changes about `wrap`: today it is a prose checklist the model walks. It
becomes "run the validators, report failures, exercise judgment only on what they surface."

## Rung 3 — Scripted workflow steps

Workflows are procedures written as prose for a model to follow. Any step of the shape
*read file A → check condition → write file B* is a script, not a paragraph.

The target shape for a workflow file:

```
1. Run tools/orient-scan.sh        → structured output
2. [JUDGMENT] Interpret; decide next move
3. Run tools/open-track.sh "<name>" → creates skeleton, links, frontmatter
```

rather than three paragraphs describing each. This shrinks `workflows/*.md` (directly
serving the Approach C context-budget goal), removes the chance of performing step 1
slightly differently each session, and makes the judgment steps *visible* — they are the
ones without a script next to them.

## Rung 4 — Typed boundaries at agent seams

`TASK-PROTOCOL.md` currently specifies a return line:

```
DONE: <path> | <summary> [| BLOCKER | CRUFT | GAP]
```

and instructs the orchestrator to check every return line and gate on BLOCKER. **That gate
is itself probabilistic** — it depends on the orchestrator remembering to parse a string.
An agent that returns a malformed line, or an orchestrator that skims, silently drops the
gate.

Convert: the agent writes structured output (JSON) to a known path; a script validates the
schema and exits nonzero on BLOCKER. The orchestrator does not decide whether to gate — it
cannot proceed. Same for the "verify all output files exist" step, which is `test -f` in a
loop and is currently a prose instruction.

This is the highest-value rung for multi-agent work specifically, because it is the one
place where a probabilistic failure is *invisible* rather than merely possible.

## Rung 5 — Parseable frontmatter predicates

`loads_when:` is prose today:

```
loads_when: any code change (fix, migration, config, feature) — the No Test No Code prime directive...
```

Unparseable, so the expected-load set cannot be computed, so loading cannot be verified —
the [`doctrine-load-verification`](../../plan/doctrine-load-verification.md) gap. Making the
trigger a predicate alongside the prose:

```
loads_when_match: { tools: [Edit, Write], paths: ["**/test_*", "**/*_test.*"] }
loads_when: any code change — ... (prose retained for the model)
```

unlocks three things at once: the expected set becomes computable (verification), the files
can be **pre-loaded deterministically** rather than hoped for (enforcement), and the
observed-vs-expected diff catches the inverse failure of loading files that did not apply
(context budget).

Note this makes verification largely moot by making loading deterministic — a better
outcome than verifying a probabilistic process.

## Rung 6 — Hooks for the true invariants

Only after the script exists. The list is short and should stay short:

| Invariant | Hook | Calls |
|---|---|---|
| Auto-generated files are not hand-edited | `PreToolUse` on Edit/Write | `check-generated-files.sh` |
| Test logic is not changed to make tests pass | `PreToolUse` on Edit, test paths | ask, not deny — this one has legitimate exceptions |
| No push / no branch switch without confirmation | `PreToolUse` on Bash | matcher on `git push`, `git checkout` |
| Skill edits do not land on main directly | `PreToolUse` on Edit under `$SHMORCH_HOME` | `check-branch.sh` |
| Manifest sync before commit | `PreToolUse` on Bash `git commit` | `check-manifest-sync.sh` |

`ask` is underrated here versus `deny`. Most of Shmorch's safety rules are "confirm with the
developer first," which is precisely what an ask-gate is, and it converts a rule the model
might forget into a prompt the developer actually sees.

## Rung 7 — Evals for the irreducible residue

Whatever is still probabilistic after Rungs 1–6 gets behavioral coverage rather than
enforcement: 20–50 real tasks with mechanically checkable expected outcomes, run on any
change to the `core/` tree, gating `self-improve` and `auto-update`.

This is the terminator for the recursion problem — you stop trying to verify that a rule
loaded and instead verify that behavior was correct, which makes the loading question moot
when it passes and diagnosable when it fails.

Assertions must be mechanical (file exists, commit order, grep hits, exit code), never
model-graded, or the recursion simply reappears one level up.

---

## What must stay probabilistic

Naming these is as important as the ladder, because the failure mode of this whole track is
mechanizing judgment into a rigid process that produces worse work. These stay:

| Chunk | Where | Mechanical shape check (Rung 4) |
|---|---|---|
| The 95% confidence interview | `build.md` | Plan file exists with named files, order, tests, risks |
| Spec authoring | `specwriter` | Required sections present; every AC maps to a scenario |
| Architecture proposals | `architect` | Decision recorded in `decisions/` with alternatives named |
| Critic review at phase boundaries | `critic` | Findings file exists; severity field valid |
| Prioritization | `prioritizer` | Every backlog item has a rank and a rationale |
| Synthesis of parallel agent output | orchestrator | All input files consumed; conflicts surfaced |

The pattern for all of them: **the content is judged, the shape is checked.** A spec is good
or bad and no script will tell you which — but a spec missing its acceptance criteria
section is mechanically wrong and should never reach a human reviewer.

---

## Sequencing

1. **Rung 0** — the inventory. Cheap, and it sizes everything else.
2. **Rung 2** — validators. Highest value per line, no architectural change, works everywhere.
3. **Rung 4** — typed agent boundaries. The only place a probabilistic failure is currently invisible.
4. **Rung 1** — generators. Steady drift reduction, low risk.
5. **Rung 5** — frontmatter predicates. Depends on Approach A having shipped.
6. **Rung 6** — hooks. Only over scripts that already exist and are proven.
7. **Rung 7** — evals. Largest build; do it once the surface has stopped moving.

Rung 3 runs throughout rather than as a discrete step — workflow steps convert to scripts
as the scripts get written for other rungs.

## Open questions

- Does Rung 4's JSON return break the "CLIs without subagents adopt the role inline" degradation path? Probably fine — inline work can write the same file — but unverified.
- Rung 5 adds a second source of truth for load triggers (predicate + prose). Do they drift from each other, and does a generator resolve that (prose derived from predicate)?
- Is there a point where the accumulated `tools/*.sh` surface needs its own tests? Rung 7 covers behavior, not the scripts themselves.
- Cost: every validator is a bash invocation per gate. Unmeasured, likely negligible, worth confirming before Rung 2 goes wide.
