---
status: Open
updated: 2026-08-10
summary: Branch C — absorbs tracks/20260601-core-breakup/ into this umbrella. Shrink individual file bodies (largely already done for shmorch-core.md — 205 lines with a pointer table); remaining work is workflows/*.md, which are still 250-1800 words each and read in full.
---

↑ [index.md](index.md)
**In this section:** [Approach A — frontmatter-gated loading](approach-a-frontmatter-gating.md) · [Approach B — subagent delegation](approach-b-subagent-delegation.md) · [Comparison — which branch first](comparison.md) · [Findings — workflow subagent delegation](findings.md) · [Spec — workflow subagent delegation](spec.md)

# Approach C — core/workflow doc JIT breakup

Absorbs `tracks/20260601-core-breakup/` (opened 2026-06-01) into this umbrella per
the 2026-08-10 session decision to spec all three context-budget levers together.
That track's own index.md is left in place as historical record and now points
here; this file carries the current, broader scope.

## Status check — the original scope is mostly already done

`tracks/20260601-core-breakup/` was opened against a `shmorch-core.md` "god doc"
carrying identity, rules, workflow phases, timing, safety, and version management
in one file. Checked 2026-08-10: **`shmorch-core.md` is already 205 lines**, and
already reads as a pointer table — every heavy section (`core/tdd.md`,
`core/ux.md`, `core/documentation.md`, `core/operations.md`, `core/portability.md`,
etc.) is a one-line link out, not inlined content. `core/` holds 15 files, sized
30-184 lines each. The breakup this track was opened for happened at some point
between 2026-06-01 and now, likely as incidental cleanup during the entrypoint
consolidation or portability work — not tracked back to a specific commit here.

**What's NOT done, and is the real remaining surface:** `workflows/*.md`. These are
larger than any single `core/*.md` file and are read in full, unconditionally, by
`go`'s dispatch chain:

| File | Words |
|---|---|
| `workflows/init.md` | 1,838 |
| `workflows/wrap.md` | 1,595 |
| `workflows/orient.md` | 1,465 |
| `workflows/auto-update.md` | ~2,700 (421 lines) |
| `workflows/go.md` | 939 |

`go` → `init.md` or `auto-update.md` → `orient.md`, in sequence, every session that
provisions. That's 3,000-5,000+ words of workflow procedure text opened inline
before a single line of project work happens — separate from, and additive to,
whatever `session.md`/`plan/` reads Approach A and B target.

## The idea (revised scope)

Split each large `workflows/*.md` into a thin dispatcher (steps + file pointers,
no inlined detail) plus JIT-loaded sub-files for steps that don't always fire —
mirroring what already happened to `shmorch-core.md` → `core/*.md`. Concretely:
`wrap.md`'s Catch-Up Wrap block (currently inlined in `go.md`, ~50 lines, fires
only on `INTERRUPTED`) is a candidate — same shape as `core/tdd.md` being pulled
out of `shmorch-core.md` for firing only when TDD doctrine is actually needed.

## What this doesn't replace

- Doesn't change *whether* a step decides to open a file (Approach A) or *where*
  the read cost lands (Approach B). A smaller `orient.md` is still read inline on
  the main thread under this approach alone — it's just fewer tokens when it does.
- Lowest ceiling of the three on its own: shrinking a 1,465-word file to, say,
  900 words by extracting a JIT sub-block is real but bounded — it can't approach
  A's "don't open it at all" or B's "don't pay for it on the main thread" savings.

## Cost / risk

- **Build cost:** medium — requires actually reading each large workflow file,
  finding the conditionally-fired blocks, extracting them, and updating every
  cross-reference. Mechanical but not small; ~5 files.
- **Risk:** low-medium — same risk shape as any doc split (a cross-reference gets
  missed, a step can't find its extracted block). `shmorch-core.md`'s prior split
  is the existence proof this works cleanly when done.
- **Payback:** compounds with A — a frontmatter-gated `loads_when` check is cheaper
  to write and cheaper to be *wrong* about when the file it's gating is already
  small and single-purpose. Doing C first makes A's frontmatter easier to write
  correctly; doing A first makes C's remaining scope more visible (frontmatter
  surfaces which blocks are conditionally-loaded candidates for extraction).

## Branch identity

Suggested branch name if built standalone: `feat/<date>-workflow-doc-jit-breakup`.
Touches: `workflows/init.md`, `wrap.md`, `orient.md`, `auto-update.md`, plus new
`workflows/_<name>-*.md` JIT sub-files (naming TBD — matches `core/`'s flat
namespace or introduces a subdirectory, open question).

## Backlinks

- [index.md](index.md)
- [comparison.md](comparison.md) — how this stacks against A and B
- `tracks/20260601-core-breakup/index.md` — original, narrower-scope track this
  absorbs
