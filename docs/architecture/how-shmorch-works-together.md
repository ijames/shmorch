↑ [Architecture](../README.md)

# How the pieces work together

A short answer to "what actually is shmorch, mechanically" — for anyone (including future
me) who's read `workflows/*.md` file-by-file and lost the shape of the whole.

## The four moving parts

**Roles** (`agents/roles/*.md`) are personas: analyst, architect, implementer, critic,
documentarian, vacuumer, and a few more. Each is a short file describing one job and one
set of concerns. A role has no opinion about which model runs it or which CLI is hosting
the session — it's pure "what this job cares about."

**Model tiers** are a cost dial, not a role property. `core/portability.md` maps roles to
a *tier* (cheap/default vs. strong), not a specific model name, because shmorch runs
under multiple CLIs with different model rosters (Claude Code's haiku/sonnet, omp's
smol/default/slow). Routine roles run cheap; the adversarial critic role escalates to the
strong tier because catching a bad plan is worth more than the tokens it costs. This is
the only place "cost" enters the picture — workflows and roles are written as if
compute were free, and the tier mapping is where that gets reconciled with reality.

**Workflows** (`workflows/*.md`) are the actual procedures — numbered steps, like
`go.md`, `design.md`, `verify.md`, `documentarian.md`. A workflow is what you invoke; it
reads one or more role files to know how to think about its steps, and it may delegate
individual steps to subagents running under a role and a tier.

**Tools** (`tools/*.sh`) are the deterministic floor under all of this. Anything a
workflow needs to know that a shell script can compute exactly — dead links, chunk-size
violations, which tracks are closed but unreferenced — gets a script
(`track-graph-audit.sh`, `docs-audit.sh`) instead of an agent read. The convention,
repeated across this codebase: **scripts find candidates, agents triage them.** A script
never concludes ("this track's knowledge landed"); it only flags ("this looks
unreferenced, go check"). That split exists because LLM judgment is expensive and
occasionally wrong in ways a `grep` isn't — spend the reasoning budget on the 5% of
findings that need it, not on re-deriving the other 95% by reading files a script could
have scanned in milliseconds.

## Why this adds up to a conversational interface

The user only ever talks to one thing: the current CLI session, running whichever
workflow they invoked (or `go.md`, which chains the others). Underneath, that session:

1. Reads a workflow's steps.
2. At each step, either does the work inline (reading a role file for stance) or spawns a
   subagent scoped to a role and a tier — a full team, assembled and torn down per step,
   never a standing chatroom of agents waiting for work.
3. Runs deterministic tools wherever a step's need is mechanically checkable, and only
   asks an agent to reason about what's left.
4. Reports back through the same conversation, whether the step took one message or
   spawned ten subagents to get there.

The user experiences this as one continuous conversation from "here's an empty repo" or
"here's a legacy codebase I've never touched" through design, implementation, review, and
deployment — because the orchestration (which role, which tier, which script vs. which
agent) is a decision the workflow makes on every step, not a decision the user has to
keep making. Brownfield and greenfield differ only in which workflow's `Step 1` fires
first (`discover.md` vs. `init.md`), not in the shape of anything downstream.

## Why this stays a skill, not a plugin

Everything above is markdown and shell scripts read at runtime — no daemon, no install
step beyond dropping the directory in place, no plugin API to version against. That's a
deliberate constraint, not an oversight: a skill is the whole system re-derivable from
files a human can read top to bottom in an afternoon, portable across CLIs
(`core/portability.md` exists *because* this isn't tied to one vendor's plugin runtime).
The tradeoff is real — a plugin could hold state across sessions, register hooks the host
CLI fires natively, ship a UI. Shmorch has traded that away on purpose: a skill blows up
in exactly one way (a bad merge to `shmorch-core.md`) and rolls back in exactly one way
(`git revert`). A plugin blows up in whatever way its host's plugin system allows, which
is a much longer list to audit before trusting it.

## The open question: enterprise

Everything here assumes a solo developer is the one steering — one person invoking
workflows, one person merging skill-file PRs, one person's judgment resolving what a
script flags. Multiple people sharing one shmorch instance raises questions this
architecture hasn't answered yet: who approves a `shmorch-core.md` PR when it's not just
one developer's own workflow being changed, how project-level overrides
(`.shmorch/agents/roles/<name>.md`) don't turn into unreviewable drift across a team, and
whether the current model-tier cost dial still holds when ten people are running
workflows concurrently instead of one. None of this is solved here — flagging it as the
next real design question, not deciding it unilaterally.
