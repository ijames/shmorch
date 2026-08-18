---
title: Multi-agent role composition vs. single-agent role-switching
tags: [agents, architecture]
created: 2026-08-04
---

# Multi-agent role composition vs. single-agent role-switching

**What it is:** Two different strategies for giving an agentic system more than one
perspective on a task. *Single-agent, multi-tool*: one agent, one continuous context,
switches "mode" via prompting (e.g. "write as architect, then critique as critic" in the
same conversation). *Multi-agent, single-role-each*: separate agents, each with exactly
one role and its own isolated context, composed by an orchestrator.

**Why it exists:** A single continuous context tends to self-agree — an agent asked to
critique what it just wrote as itself is anchored to its own prior reasoning, so the
critique reads as agreeable rather than adversarial. Separate agents with separate contexts
don't share that anchor, so the independence is real rather than simulated. This is
documented in Anthropic's own multi-agent research (the orchestrator-worker pattern) and
shows up as the dominant industry approach — LangGraph's "supervisor" pattern, CrewAI's
hierarchical process — whenever genuine adversarial or cross-disciplinary independence is
the point, not just task splitting for speed.

**Where it appears in this project:** `agents/TASK-PROTOCOL.md`'s "One role per agent"
rule, and the `cross-functional-mediator` role (`agents/roles/cross-functional-mediator.md`,
`core/cross-functional.md`) — the mediator is itself a single-role agent spawned *alongside*
other single-role agents to review the seam between their outputs, never a second persona
blended into one of them. Raised 2026-08-04 while resolving a carried-over session note
that (incorrectly) read as a possible reversal of the one-role-per-agent rule; confirmed no
reversal ever happened — the mediator and the rule have coexisted since the mediator's
introduction (`c6308c8`, 2026-06-11).
