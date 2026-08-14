---
status: Done
updated: 2026-08-14
summary: Branch A — every loadable .md gets YAML frontmatter (purpose, load-when, size); the orchestrator reads only frontmatter across a directory before deciding which bodies to open. Cheapest lever, ships first, composes with B and C. Merged via PR #106.
---

↑ [index.md](index.md)
**In this section:** [Spec — subagent delegation](spec.md) · [Findings](findings.md) · [Approach B — subagent delegation](approach-b-subagent-delegation.md) · [Approach C — core doc JIT breakup](approach-c-core-doc-breakup.md) · [Comparison](comparison.md)

# Approach A — frontmatter-gated loading

## The idea

Every `.md` file a workflow might load (`workflows/*`, `core/*`, `agents/*`, `docs/project/plan/*`) gets a short YAML frontmatter block. Before a workflow opens a file's *body*, it reads only the frontmatter — a `head -c` / grep-to-`---` style read, not the full file — and decides from that alone whether the body is needed at all.

This isn't new infrastructure — `plan/*.md` and `tracks/*/index.md` already carry `status` / `updated` / `summary` frontmatter (this track's own files are the example). The gap is that **`workflows/*.md` and `core/*.md` have none**, so `go`/`orient`/`wrap` can't make a skip decision without opening the body first. This track extends the existing convention to the files that currently lack it, and makes "read frontmatter, decide, then maybe open body" the explicit read pattern in every workflow step that currently just says "read `X.md` and execute it."

## Frontmatter shape (new, for workflows/core/agents)

```yaml
---
loads_when: <the condition under which a workflow step should open this file's body>
skip_when: <the condition under which it's safe to skip — optional, only when non-obvious>
size: <approx lines, kept honest by a lint check — see Open questions>
depends_on: [other files this one assumes are already loaded]
---
```

Distinct from `plan/*.md`'s `status`/`updated`/`summary` shape — that one answers "is this backlog item still relevant," this one answers "does the *current step* need this file's body." Both are frontmatter; different fields for different jobs. No forced unification.

## What changes mechanically

- `workflows/go.md` Step 2/4 ("read `init.md`/`orient.md` and execute it") becomes "read `init.md`'s frontmatter; if `loads_when` matches the detected state, open the body."
- `core/index.md` (already exists, 20 lines) becomes the frontmatter-gated entry point for `core/*` — a workflow greps frontmatter across `core/*.md` for `loads_when` matches instead of `core/index.md`'s hand-maintained pointer table falling out of sync with what actually exists.
- `docs/project/plan/index.md`'s per-bullet frontmatter (already there) becomes machine-checkable, not just human-read — `orient.md`'s "surface gaps" step can grep `status: Open` across `plan/*.md` frontmatter instead of reading every bullet's full body.

## What this doesn't replace

- Doesn't reduce the cost of files that genuinely need their body read — frontmatter gating only prevents opening files that turn out to be irrelevant. A workflow that needs `session.md`'s content still reads `session.md`'s content (bounded, per the existing tail-read backlog item).
- Doesn't touch *where* execution happens (main thread vs. subagent) — that's Approach B. Frontmatter gating reduces *which* files get opened; subagent delegation reduces *whose context* pays for opening them. Compose freely.
- Doesn't shrink any individual file's body — that's Approach C. A 300-line workflow file with perfect frontmatter still costs 300 lines the moment `loads_when` matches.

## Cost / risk

- **Build cost:** low — add a 3-5 line frontmatter block to each `workflows/*.md` and `core/*.md` (~35 files per the earlier survey), plus rewrite the "read X and execute it" instruction phrasing in the ~6 workflow files that dispatch to others (`go.md`, `orient.md`, `resume.md`, `wrap.md`, `self-improve.md`, `documentarian.md`).
- **Risk:** low — additive metadata, no behavior change to file bodies. Worst case a `loads_when` is written wrong and a step skips a file it needed, which is a visible failure (missing context, not silent corruption) and cheap to fix.
- **Payback:** immediate on every session, no spawn latency, no schema-enforcement dependency (unlike Approach B's JSON-return problem in `findings.md`). This is the "bounded reads + index discipline" lever `findings.md` already measured at **69% reduction, no downside** — frontmatter gating is that same lever generalized from `plan.md` specifically to every loadable file.

## Traversal algorithm (2026-08-10)

The gating decision isn't flat — it's a walk down the existing directory structure,
cheapest read first, widening only when the cheap read doesn't resolve the question:

1. **Read the nearest index first.** `core/index.md` (20 lines), `docs/project/plan/index.md`,
   a track's `index.md` — these are already small and already summarize their subtree.
   Most decisions stop here.
2. **Index points at a subtree → open that subtree's frontmatter, not its body.**
   E.g. `core/index.md` says "TDD doctrine → `core/tdd.md`" — read `tdd.md`'s frontmatter
   (`loads_when`) to confirm relevance before opening the body.
3. **Frontmatter alone doesn't resolve it → descend one level.** If the subtree has its
   own index (a track folder does; a flat `core/*.md` file doesn't), open *that* index
   next, repeating from step 1 one level down. If it's a leaf file, open the body — this
   is the point where paying the read cost is actually justified, not skipped.
4. **Still ambiguous across many candidates → bulk frontmatter grab, not bulk body reads.**
   When there's no single index to disambiguate (e.g. "which of 20 `plan/*.md` bullets are
   relevant to this session's focus"), grep frontmatter across the whole set in one pass —
   every file's `summary`/`status` line, none of their bodies. This is a **flat, cheap
   approximation of a knowledge graph**: no graph database, no separate index to keep in
   sync, just the frontmatter *already sitting in every file* read in bulk instead of
   one-by-one. It scales with file count, not file size, which is the property that
   matters here — 20 files' frontmatter is still cheap even when 3 of those files are
   1,500 words.

This is a strict ordering, not a menu — steps 1-3 are the "traverse down the tree" path
and should resolve the overwhelming majority of gating decisions for free (an index
answers "which subtree" in one line). Step 4 is the fallback for exactly the cases where
there's no natural tree to walk — a flat directory of independent leaf files
(`plan/*.md` bullets, `core/*.md` doctrine files with no further nesting) — and even
there it stays frontmatter-only, never falling back to "just read them all."

## Traversal as tooling, not LLM improvisation (2026-08-10)

The traversal algorithm above is deterministic — same inputs (current step, directory
tree, frontmatter contents) always produce the same candidate file set. That's exactly
the boundary `spec.md`'s "What this doesn't replace" section already draws: rote,
rule-following mechanics stay scripted (`tools/*.sh`), agent judgment is reserved for
work that actually needs it. Leaving the traversal to "the model reads index.md, decides,
reads the next one, decides again" makes a deterministic decision non-deterministic for
no reason — same failure mode as any other place doctrine says "don't agent-ify what a
script already does correctly."

**Concretely:** `tools/frontmatter-traverse.sh` — given a starting index and a
`loads_when` query string (e.g. the current workflow step's name), walks step 1-4 of the
algorithm above in bash: extract each candidate's frontmatter block (`awk '/^---$/{f=!f;
next} f'`, no YAML library needed — this skill's frontmatter is flat `key: value`, not
nested), match `loads_when`/`skip_when` against the query, recurse into sub-indexes,
print the resolved file list. No new dependency — same tier as every other `tools/*.sh`
script already in this repo, `awk`/`grep`/`sed` only. The workflow step calls the script
and gets a file list back instead of narrating its way down the tree turn by turn.

## Open questions

- Who keeps `size:` honest as files grow? Options: a `vacuumer` check (flag if actual line count drifts >20% from declared `size`), or drop the field entirely and let `loads_when`/`skip_when` do the work without a staleness-prone number attached.
- Does `core/index.md`'s existing hand-maintained table get replaced by a frontmatter grep, or kept as a human-readable mirror with the grep as the machine path? Leaning toward: keep the human table (it's 20 lines, cheap, and useful for a person skimming the repo), add frontmatter as the machine path — not either/or.
- Frontmatter parsing on non-Claude CLIs (`core/portability.md`'s degrade-gracefully rule) — a `head`/`awk` frontmatter extraction is POSIX-portable, no special tooling needed, so this should degrade cleanly by default. Confirm no CLI-specific blocker before building.

## Backlinks

- [index.md](index.md)
- [comparison.md](comparison.md) — how this stacks against B and C
