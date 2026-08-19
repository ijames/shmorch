---
status: Open
updated: 2026-08-10
summary: Decision doc — three branches (A frontmatter gating, B subagent delegation, C doc JIT breakup) scored on build cost, risk, ceiling, and dependency on the other two. Recommendation — A first, standalone; B and C sequenced after, and C makes A cheaper if done alongside it.
---

↑ [index.md](index.md)
**In this section:** [Approach A — frontmatter-gated loading](approach-a-frontmatter-gating.md) · [Approach B — subagent delegation](approach-b-subagent-delegation.md) · [Approach C — core/workflow doc JIT breakup](approach-c-core-doc-breakup.md) · [Findings — workflow subagent delegation](findings.md) · [Spec — workflow subagent delegation](spec.md)

# Comparison — which branch first

## Scorecard

| | A — frontmatter gating | B — subagent delegation | C — doc JIT breakup |
|---|---|---|---|
| Build cost | Low — add frontmatter to ~35 files, rewrite dispatch phrasing in ~6 | High — new return contract, `TASK-PROTOCOL.md` gate change, non-Claude fallback | Medium — split ~5 large workflow files, fix cross-refs |
| Risk | Low — additive metadata, visible failure mode | Medium — schema-less JSON convention, spawn-cost unmeasured, cuts against existing spawn gate on purpose | Low-medium — mechanical split, existing precedent (`shmorch-core.md`) |
| Ceiling alone | Medium — only removes cost for files that turn out unneeded | Highest — removes main-thread cost entirely for the files it covers | Lowest — shrinks bodies, doesn't change whether/where they're read |
| Depends on the others? | No — standalone win | Benefits from A shipping first (per findings.md: measure again after the cheap fix, only reach for B if headroom remains) | No, but pairs well with A (smaller files → simpler `loads_when` to write correctly) |
| Already measured? | Yes — this is exactly findings.md's "bounded reads + index discipline" lever, generalized: **69% reduction, no downside, ship first** | Partially — findings.md simulated the ceiling (98%) but spawn-cost-vs-savings is still an open question, not yet measured | No direct measurement; `shmorch-core.md`'s prior split is an existence proof, not a number |
| Non-Claude CLI fallback | Trivial — `head`/`awk` frontmatter read is POSIX-portable | Real design constraint — must produce the same JSON shape inline when no subagent primitive exists | Trivial — smaller files read the same way on every CLI |

## Recommendation

**Yes — Approach A first.** Three independent reasons converge on the same
answer:

1. **It's already been measured, on this exact repo, at zero cost.**
   `findings.md`'s simulation against `plan.md`/`session.md` found the
   bounded-reads-plus-index-discipline lever — which is what frontmatter gating
   generalizes — closes 69% of the token gap with no downside and no subagent
   round-trip. That measurement predates this session; A doesn't need new
   evidence, it needs building.
2. **Ladder logic.** A reaches for an already-established convention
   (`plan/*.md` frontmatter already exists) rather than new infrastructure (B) or
   a mechanical but nontrivial file surgery pass (C). Cheapest rung that holds,
   per the ladder: does it need new machinery at all? No — extend what's already
   there.
3. **It de-risks B.** `findings.md` explicitly says don't reach for the subagent
   lever before the index lever — measure again after the cheap fix ships to see
   how much headroom is actually left. Building A first isn't just "cheapest
   first," it's the prerequisite the existing findings already called for.

**Sequencing:** A standalone → measure real reduction on this repo's own
`go`/`resume`/`wrap` calls → if meaningful cost remains, B (spawn-cost measurement
was always B's blocking open question, unaffected by doing A first) → C can run
in parallel with either, since it's orthogonal to both (no shared file
touch-points with A's frontmatter work or B's return-contract work, beyond the
workflow files all three eventually touch).

**On "three branches to swap and experiment on":** build A on its own branch first
since it's the one with a clear, already-measured payoff and the lowest chance of
needing to be reverted. Once A is in, cut B and C as separate branches off of
main-with-A (not off each other) so their real-world cost/benefit can be measured
against the *already-improved* baseline, not the original one — comparing B or C
against the pre-A baseline would overstate their marginal contribution.

## What "best choice" actually means here

Not mutually exclusive despite the branch framing — A, B, and C attack three
different axes (which files open / whose context pays / how large each file is)
and compose without conflict. "Three branches to experiment on" is really "three
sequenced landings," not "pick one and discard the others." The comparison above
picks an *order*, not a winner.

## Backlinks

- [index.md](index.md)
- [approach-a-frontmatter-gating.md](approach-a-frontmatter-gating.md)
- [approach-b-subagent-delegation.md](approach-b-subagent-delegation.md)
- [approach-c-core-doc-breakup.md](approach-c-core-doc-breakup.md)
