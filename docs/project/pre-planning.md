








**In this section:** [session](session.md) · [timelog](timelog.md)

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

---

## `pe` multi-source ingestion — other agents' logs, other reflection tools (deferred)

Prompted by building `workflows/personal-eval.md` (2026-08-11): `pe` currently reads
Claude Code session transcripts only (`~/.claude/projects/**/*.jsonl`). The user's
stated end goal is broader — fold in other orchestration agents' logs (omp, opencode,
whatever else) and other personal-reflection tools/logs, not just Claude Code.

**Why deferred, not built now:** each source has its own log format and transcript
shape — this isn't a flag on `scan.py`, it's a separate extraction path per source,
same category of work as building the first one. Doing it now, un-asked, risks
guessing at formats for tools not yet named. Build the second source when a specific
one is named and its log shape is known.

**Not scoped as a project — a pointer for whenever a specific second source comes up.**
When it does: the `pe-summarizer`/`pe-synthesizer` roles and the `profile/` taxonomy
in `$PERSONAL_PROFILE_HOME` don't need to change — only the "get clean turn text from
a transcript" step (`session_turns.py`, Claude-JSONL-specific today) needs a sibling
per source format, dispatched by `scan.py` based on where a given log came from.

### Second source, now named: ChatGPT export (`conversations.json`)

Prompted by (2026-08-11): the user has a much larger volume of history sitting in
ChatGPT's web client than in Claude Code — more conversations, more detail, plus
ChatGPT's own cross-conversation memory feature. Still deferred (no export in hand,
nothing built), but the user asked for the format prepped in advance so it's ready to
scope for real once they have the export file.

**Format** — Settings → Data Controls → Export Data produces a zip; the conversation
history lives in `conversations.json`, a JSON array of conversation objects, each
roughly:

```json
{
  "id": "conv-abc123",
  "title": "Deploy pipeline debugging",
  "create_time": 1752000000.0,
  "update_time": 1752003600.0,
  "current_node": "node-9f2e",
  "mapping": {
    "node-root": { "id": "node-root", "message": null, "parent": null, "children": ["node-1"] },
    "node-1": {
      "id": "node-1",
      "message": {
        "id": "msg-1", "author": { "role": "user" },
        "create_time": 1752000000.0,
        "content": { "content_type": "text", "parts": ["how do I..."] }
      },
      "parent": "node-root", "children": ["node-2"]
    },
    "node-2": { "...": "assistant reply node, same shape, author.role = assistant" }
  }
}
```

The load-bearing difference from Claude Code's `.jsonl`: this is a **tree**, not a
linear log. `mapping` holds every node ever created, including abandoned branches
from regenerated or edited replies; `current_node` marks the leaf of the branch
actually shown to the user. Getting the conversation as the user actually experienced
it means walking parent-links from `current_node` back to the root, not just reading
`mapping` in file order.

The export bundle may also carry `chat.html`, `message_feedback.json`,
`shared_conversations.json`, `user.json`, and possibly a memory-feature file —
unconfirmed without an actual export in hand; verify the real bundle's contents
before assuming a schema for anything beyond `conversations.json`.

**Basic strategy, matching the "one sibling per source" shape above:**

1. `chatgpt_turns.py` (sibling to `session_turns.py`): for each conversation, walk
   `mapping` from `current_node` to root via `parent` links, reverse to
   chronological order, filter to `author.role in {user, assistant}` (skip `system`/
   `tool` nodes), join `content.parts`. Output the same clean request/response shape
   `session_turns.py` already produces, so `pe-summarizer` needs zero changes.
   Abandoned branches are discardable for now — only the shown conversation matters
   for persona evidence; revisit only if edit/regeneration patterns turn out to be
   evidence in their own right (e.g. a growth-edges signal).
2. Session boundary = one `conversations.json` entry = one `pe` session, same as one
   Claude Code transcript file today. `create_time`/`update_time` on the conversation
   object give the timing-section data `stats.md` already tracks.
3. Reuse `pe-summarizer`, `pe-synthesizer`, `pe-analyzer`, and the existing section-file
   taxonomy (11 files, numeric prefixes dropped 2026-09-04 — see
   `docs/project/plan/pe-pipeline-split-generalization-vs-concrete-track-record.md`) as-is
   — the whole point of the multi-source pointer above. No new roles needed for this
   source. The `[James]`/`[Agent]` attribution split and the parallel
   `<slug>_agent_behavior.md` stream also carry over unchanged — a ChatGPT session still
   has a human side and an assistant side to tag the same way.
4. Open question to resolve when actually built, not now: one shared
   `personal-profile` repo with a source tag per session (keeps one unified profile,
   which matches the actual goal — one picture of the person, not two), vs. a
   separate `.openai/personal-profile` tree merged later. ChatGPT conversations
   mostly won't have a "project" the way Claude Code sessions do (git repo per
   project), so whatever section-file field currently assumes a project name needs a
   fallback (topic/title-derived, or just "chatgpt" with the conversation title as
   detail) rather than a hard requirement.
5. Given the user's stated volume ("much more" than the Claude Code backlog), reuse
   the same batch-cap/cheap-tier-first design as `pe scan` rather than a one-shot
   bulk import — same cost-awareness reasoning, bigger backlog.

**Still not scoped as an active project.** Pick this up for real once the user has
the actual export file in hand — this entry exists so the format doesn't need
re-deriving from scratch when that happens.

### Non-session sources: blogs, Google Docs, social posts (deferred)

Folded in from a 2026-08-13 inbox note: beyond other agents' transcripts, sources
outside any coding context (blog posts, Google Docs, Facebook posts) would surface
evidence structurally absent from session transcripts — values, interests, and
communication style expressed when the user isn't talking to an AI at all. Same
"one extraction path per source format" shape as the ChatGPT case above, but with an
added wrinkle transcripts don't have: each of these needs its own
auth/access-and-consent story (opt-in, source by source) rather than just reading a
local file.

**Also floated, further out:** if the extract → summarize → synthesize → analyze
pipeline stays source-agnostic as more sources are added, it may be general enough to
pull out of shmorch as its own tool, independent of Claude Code. Not a near-term
commitment — revisit once the single-source (Claude Code) pipeline is solid and the
profile has enough volume to know what's actually missing from it.

---

## Backlog as a dependency stack, not just a flat list (deferred)

Prompted by (2026-05-07): when backlog items block each other (e.g. one item can't
start until another lands), a flat domain list doesn't surface that push/pop
relationship — the developer has to track "do this first" mentally, with no
structural support from the docs.

**The thought:** `plan/index.md` could gain a formal "Active Stack" section above the
flat domain inventory, where blocked chains are pushed and popped in dependency
order — LIFO for the hot path: top of stack = do next, bottom = not yet unblocked.
Relates to the Beads/Conductor evaluation already in `plan/beads-integration-investigation.md`
— a proper dependency-graph tool would make this structural instead of prose.

**Not scoped.** Loose — worth revisiting only if dependency chains between backlog
items become common enough that the flat list is routinely misleading about order.

---

## Global learning log, not per-project — resolved 2026-08-18

Prompted by (2026-08-13), raised while merging DarkBadge PR #196. Resolved: general-purpose
captures now dual-write — locally to `docs/reference/learning/<slug>.md` (project context
intact) and, in a polished project-agnostic form, to `~/.shmorch/learning/<domain>/<slug>.md`
(global knowledge graph). The two copies are decoupled, no backreference required. See
`shmorch-core.md` § Learning log and `workflows/learn.md`.
