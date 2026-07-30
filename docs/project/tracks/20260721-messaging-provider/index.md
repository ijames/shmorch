---
status: Open
updated: 2026-07-21
summary: Design for an opt-in, per-project messaging provider (thin Zulip/Slack skills, keys never in Shmorch) replacing the hardcoded single-Zulip-workspace assumption. Scope settled; implementation not started.
---

↑ [Shmorch Plan](../../plan.md)
→ `templates/.shmorch/AGENTS.md`, `core/operations.md`, `docs/architecture/feedback-systems.md` (once shipped)

# Track: Messaging provider — optional, per-project, not hardcoded to one Zulip workspace

**Status:** Open
**Opened:** 2026-07-21
**Domain:** Operations / integrations

## Why

`core/operations.md` and `docs/architecture/feedback-systems.md` currently reference Zulip
as if there's exactly one workspace, always connected, always the right one
(`mcp__zulipchat__get_streams` hardcoded as *the* example). That's wrong across projects —
different repos legitimately want different Zulip orgs, a different provider entirely, or
none at all. Surfaced 2026-07-21: need the ability to add/remove a messaging provider per
project, both for posting updates (existing behavior) and for reading field feedback
(new — ties into `feedback-systems.md`'s maintainer-workflow integration and survey tools).

## Scope decisions (settled 2026-07-21)

- **Communication provider, not fully generic "any integration."** Scoped to post +
  optionally read. Broader generic-provider abstraction (deploy hooks, issue trackers) is
  explicitly deferred until a second non-messaging need actually appears — see
  `plan.md` Deferred.
- **Separate thin provider skills, not code baked into Shmorch.** A `zulip` skill, a
  `slack` skill, etc. — each knows auth/API shape/channel semantics for its provider.
  Shmorch's job stays "know *when* to post" (track promoted, decision made, wrap); the
  provider skill's job is "know *how*." A project with no messaging need installs nothing.
- **Keys live in the MCP server config (or project `.env`), never in Shmorch.**
  `AGENTS.md`'s new config section stores a non-secret *pointer* — which MCP
  server/tool-prefix or provider skill this project uses — not the credential itself. One
  MCP server entry per workspace when multiple Zulip orgs are in play.
- **Opt-in, mirrors the existing Docs Placement Hook pattern** in
  `templates/.shmorch/AGENTS.md` (`Status: enabled | disabled`, asked once during the
  context interview, toggled by editing the file).

## Open question

Does a Zulip MCP already exist generically, or is `mcp__zulipchat__*` a
one-off/project-specific connection? Slack almost certainly has one. Check before
building a provider skill from scratch — if an MCP already covers the API surface, the
provider skill may just be a thin conventions wrapper (which stream, which topic naming,
when to post) rather than raw API calls.

## Backlog (moved here from plan.md 2026-07-21 — see plan.md for the pointer)

- [ ] `templates/.shmorch/AGENTS.md`: add a "Messaging Provider" section (opt-in, mirrors
  Docs Placement Hook) — `Status`, `Provider`, `Workspace/org`, `Default stream`,
  `Feedback stream/topic`
- [ ] `workflows/orient.md` Context Setup flow: one more interview question for messaging
  provider opt-in
- [ ] `core/operations.md`: generalize the Communication Notifications section to read the
  configured provider/pointer instead of hardcoding Zulip
- [ ] `docs/architecture/feedback-systems.md`: point the (not-yet-built) `/shmorch
  feedback` command at whichever provider is configured, alongside survey-tool sources
- [ ] Investigate whether a generic Zulip MCP exists vs. project-specific setup; same for
  Slack — informs whether provider skills wrap an MCP or call raw APIs
