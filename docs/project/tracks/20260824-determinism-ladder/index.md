---
status: Open
updated: 2026-08-24
summary: Move Shmorch from doctrine-as-instruction toward deterministic scaffolding with named probabilistic chunks. Contains the AI-Native SDLC Playbook diff, the determinism ladder (7 rungs, script-vs-hook portability split), and the captured "Wild West of AI" post with a fairness assessment.
---

↑ [Shmorch Plan](../../plan/index.md)
→ `tools/*.sh`, `agents/TASK-PROTOCOL.md`, `core/*.md` frontmatter, `workflows/*.md`, `.claude/settings.json` (if hooks adopted)

# Track: Determinism ladder — deterministic scaffolding, contained probabilistic chunks

**Status:** Open
**Opened:** 2026-08-24
**Domain:** Skill architecture / enforcement model

## Why

Surfaced 2026-08-24 from a diff of Anthropic's AI-Native SDLC Playbook against Shmorch's
orchestration fundamentals. The Playbook's central structural claim is that enforcement
should move **from process to code** — hooks, managed settings, branch protection, CI evals
— so policy is enforced as the agent acts rather than asserted in a document and hoped for.

Measured against that, Shmorch's entire compliance model is probabilistic. Every rule in
`core/` is markdown the model reads and is expected to comply with. That is ~7,300 lines of
instruction with no mechanical enforcement anywhere in it. Several of those rules are
plainly not judgment calls and should never have been prose:

- never hand-edit auto-generated files
- never change test logic to make tests pass
- sync deployment manifests after any dependency change
- never push / never switch branches without confirmation
- skill edits go through branch → PR → developer merge

Each is one script or hook away from being unbreakable instead of merely instructed.

The goal of this track is **not** to make Shmorch deterministic — most of what it does is
genuinely judgment and must stay probabilistic. The goal is to make the *scaffolding*
deterministic so the probabilistic parts are small, named, and bounded by machine-checked
inputs and outputs.

## Files in this track

| File | Purpose |
|---|---|
| [determinism-ladder.md](determinism-ladder.md) | **Start here** — 7 rungs from generators to evals, what stays probabilistic, script-vs-hook portability split |
| [blog-revision.md](blog-revision.md) | Additive blog patches — one framing paragraph, one "What I Don't Have" section, four line-level inserts |
| [wild-west-post.md](wild-west-post.md) | Captured "The Wild West of AI" post (2026-08-24) + fairness assessment as a comparison |
| `research/research-20260824-ai-native-sdlc.md` | The source diff — matrix, per-dimension verdicts, ranked import list (lives in `research/`, not moved) |

## Related

- [`plan/doctrine-load-verification.md`](../../plan/doctrine-load-verification.md) — downstream of this track; the `loads_when` observability gap is Rung 5, and its portability open question is resolved here by the script/hook split.
- [`tracks/20260721-workflow-subagent-delegation`](../20260721-workflow-subagent-delegation/index.md) — Approach A (frontmatter gating) is the prerequisite for Rung 5; parseable `loads_when` predicates extend what A shipped.
- [`tracks/20260810-deterministic-merge-chain-tool`](../20260810-deterministic-merge-chain-tool/index.md) — prior art, same instinct applied to merge order.
