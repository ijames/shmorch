# Client-engagement docs (bid, go/no-go, kickoff, wrap) have no home in the taxonomy

**Status:** Deferred 2026-09-23 — revisit when a second client or consulting project needs a `docs/project/engagement/`-style folder. JKAM is the only example so far.

**Filed from `JKAM/system` 2026-09-18.**

## What happened

A consulting pre-sales proposal was filed in `docs/product/strategy/` because that folder's index says "strategic direction". James disagreed: "This being a kickoff is part of the project more than the product strategy... Project strategy, or process is where this would go... (could be more than one kickoff or wrap?) but still more transitory in that the final decisions and designs and features, use cases, etc end up in product/technology."

`docs/project/process/` doesn't fit either, because it's defined as the place for divergences from Shmorch defaults.

## What JKAM did

It created `docs/project/engagement/`, holding `index.md`, `go-no-go.md` and `proposal-draft.md`. The folder is transitory, and its outputs graduate to `product/` and `technology/`.

## To decide

- Should `init` scaffold `docs/project/engagement/` for client or consulting projects? Should the context interview ask "is this client work?"
- Is `go-no-go` a standard gate before any proposal, as it turned out to be here? James wanted to step back and ask whether the work was worth doing before any bid went out.
- `product/strategy/index.md` should say it covers where the product itself is headed, not the commercial relationship.
