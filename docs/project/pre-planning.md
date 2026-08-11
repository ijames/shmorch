



**In this section:** [Session Log](session.md) · [timelog](timelog.md)

# Pre-planning

Deferred ideas and proposals not yet ready for the active backlog.

---

## Shmorch Live Docs Structure (deferred)

Agreed minimal docs structure for shmorch's own live documentation.
Full template structure is overkill — shmorch is a tool, not a product.

```
docs/
  README.md               ← exists, keep (shmorch-specific content)
  index.md                ← what shmorch is + philosophy + tenet list
  research.md             ← explorations, open questions, things to investigate
  state/
    plan.md               ← exists, keep (backlog, in-progress, completed)
    context.md            ← identity/purpose (used by /go to orient sessions)
    session.md            ← last session summary (written by /wrap)
  architecture/
    feedback-systems.md   ← exists, keep
    decisions.md          ← permanent ADR log (why things are the way they are)
  reference/
    aws-lambda-deploy.md  ← exists, keep
```

Excluded: `product/`, `development/`, `testing/`, `guides/`, `to_review/` — not applicable to a tool project.

Status: blocked on shmorch-core.md refactor. Revisit after that lands.

---

## Knowledge graph as the aggregator over multiple evidence sources (deferred)

Prompted by building `~/.shmorch/personal-profile` (2026-08-10): that tool deliberately
stays a "dumb, evidence-only source" — flat folders, hand-authored markdown links between
a trait bullet and the session that produced it. That's the right shape *for one source*.
The open question is what happens once there are several such sources (the personal profile,
Treeclusion's document/reference graph, Paths' own knowledge model, shmorch's own
`docs/` skeleton) and something needs to reason across all of them.

**The thought:** a forced folder hierarchy with hand-authored links (what every one of these
projects currently does) only captures relationships someone thought to write down at
authoring time. A knowledge graph inverts that — nodes are the evidence units (a session
summary, a doc, a decision), and the *interstitial* relationships between them (this trait
relates to that one, this decision supersedes that one, this session's content echoes a
theme from three projects ago) either live as edges on the graph, or — more interestingly —
don't need to be pre-authored at all. A user-context-aware LLM sitting on top of the graph
can generate the connective narrative on demand, at query time, tailored to what the reader
actually asked, rather than every possible relationship being pre-written into a static link
by whoever authored the node.

That reframes "linking" as two different jobs that shouldn't be conflated:
- **Structural/provenance edges** (this bullet came from this session, this doc supersedes
  that decision) — cheap, mechanical, worth pre-authoring, exactly what the flat-folder +
  markdown-link approach already does well.
- **Interpretive/interstitial relationships** (why these two things matter to each other) —
  expensive to pre-author exhaustively, degrades as the corpus grows (see: this repo's own
  `core/documentation.md` § Progressive Disclosure, which exists because pre-authored
  structure alone doesn't scale to "what should I read"). Better generated dynamically by an
  LLM with the graph as context, on the specific question asked, than baked in ahead of time.

**Not scoped as a project — a lens for evaluating future work.** Relevant to, but not
currently informing the design of:
- `~/.shmorch/personal-profile` — its own `README.md` "Vision" section already flags this:
  "Turning many such sources... into something navigable — a knowledge graph instead of a
  forced folder hierarchy — is a separate future project's job, not this one's."
- `/Users/james/Projects/treeclusion` — a "stretchtext" document browser (Ted Nelson-
  inspired) that expands references inline instead of hyperjumping away; the closest existing
  project to "interstitial relationships made navigable," worth revisiting this thinking
  against once treeclusion's own reference model is further along.
- `/Users/james/Projects/Paths` — has its own knowledge/path model (`paths-driver.mjs`,
  `docs/product/cognitive-architecture.md`); worth checking whether its cognitive-
  architecture thinking already covers some of this ground before designing anything new.

No action here — parking the framing so it doesn't need re-deriving next time knowledge-
graph aggregation comes up in any of these projects.
