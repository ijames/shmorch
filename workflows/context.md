# Workflow: Context Management

Context has two failure modes: **too diffuse** (multiple unrelated concerns muddled
together) and **too deep** (one thread so long it loses sight of the bigger picture).
Both kill productive development. This workflow defines how Shmorch recognizes and
corrects both.

## When to use

- Proactively: when a thread exceeds ~20 exchanges or context window is above ~40% utilization
- When multiple unrelated concerns have drifted into the same thread
- On any topic switch (hot-swap protocol)
- When the conversation has lost focus and is circling

## Inputs

- None — applies to the current conversation state

## Roles

- None — runs inline

---

## Context Levels

Every conversation operates at two levels simultaneously:

| Level | Contents | Lives in |
|---|---|---|
| **Architectural** | Why this exists, what it connects to, constraints | decisions.md, plan.md, track docs |
| **Implementation** | What we're doing right now, the specific code | Active conversation thread |

The architectural level must always be visible — it's the compass. The implementation
level must stay focused — scattered implementation threads produce bad code.

---

## Hot-Swap: Switching Tracks Mid-Conversation

When the user shifts topic, instruction, or track — even briefly — that's a context switch.

**Triggers:**

- User mentions a different track, a bug, a question, or a side concern
- A clean stopping point is reached (commit made, feature complete, tests green)
- The current thread has accomplished its goal

**What to do:**

1. If the current thread is at a clean point: commit or checkpoint first
2. Write one line in session.md noting where the interrupted thread stands
3. Name the switch explicitly: "Switching context from [X] to [Y]."
4. Carry only what's needed — don't drag implementation detail from X into Y

**Return triggers:** If the user says "back to X" or the natural flow returns,
name it: "Resuming [X] — we were at [brief state]."

---

## Compression: When a Thread Gets Too Long or Tangled

## Compaction Triggers

Compact when any of the following is true:

- Context window estimated above ~40% utilization
- Thread has exceeded ~20 exchanges without a clean stopping point
- Tool outputs accumulating without being referenced again
- Visible symptoms: responses slowing, repeating prior context, losing track of decisions

### Mid-session wrap reminder — ~55% utilization

When context appears to be around 55% full, surface this reminder once (do not repeat it):

> "We're about halfway through the context window. Good time for a mid-session wrap — self-improve and wrap prompts while there's still room. Want to do that now, or keep going?"

This is a prompt, not an action. Do not run self-improve or wrap prompts automatically. If the user says yes, run them inline. If no, continue and let them decide when to compact or quit.

Compression is needed when:

- A single thread has been running for many exchanges with growing complexity
- Multiple unrelated concerns have drifted into the same thread
- The conversation has lost focus and is circling
- A series of fixes/changes has accumulated that now needs to be understood as a whole
- The user seems confused about where things stand

**Shmorch should proactively flag this.** Don't wait to be asked. Say something like:

> "This thread is getting complex — we've covered [A], [B], and [C] and it's all
> tangled together. Want me to compact this and give us a clean starting point?
> I can snapshot the decisions, update state, and start fresh on [next thing]."

Or just do it if the stopping point is clear:

> "Clean stopping point. Compacting — [brief what-was-done]. Continuing with [next]."

**Compaction steps:**

0. Clear processed tool outputs first — highest-volume, lowest-value tokens; discard entirely, do not summarize.
1. Identify what the thread accomplished
2. Write decisions to decisions.md — architectural decisions and unresolved issues must survive compaction verbatim, with no information loss.
3. Write state to session.md / plan.md (what's done, what's next)
4. Commit if there's uncommitted work
5. Clear the implementation thread — start the next topic fresh

---

## Separation: One Focus at a Time

A context window should serve one concern. If you notice two or more distinct concerns
mixing — stop and separate them.

**Signs of mixing:**

- Fixing a bug while designing a feature
- Implementing while also re-architecting
- A long explanation that's really two different decisions
- Tests for one thing while the code under test belongs to a different track

**When you notice mixing:**

1. Name it: "These are two separate concerns — [X] and [Y]."
2. Finish one cleanly before starting the other
3. Or explicitly park one: "Setting [Y] aside — I'll pick it up after [X] is done."

---

## Bigger Picture Reminder

When deep in implementation, surface the bigger picture periodically:

- After a long implementation thread: "This connects to [track/decision] — still on course."
- When a choice is made that has architectural implications: write it to decisions.md now.
- When a fix reveals a design gap: flag it for the backlog immediately, don't let it get lost.

The bigger picture isn't separate from the work — it's the frame that makes the work coherent.

---

## Compact Prompt Templates

Use these or adapt them:

**Proactive flag:**
> "We've been on [topic] for a while and it's getting layered. Good time to compact —
> want me to snapshot this and start fresh on [what's next]?"

**Clean-point compact:**
> "Good stopping point on [topic]. Compacting now."
> → commit → update state → "Ready for [next]."

**Tangle alert:**
> "This is mixing [X] and [Y]. I'll finish [X] cleanly first, then we tackle [Y]."

**Return from hot-swap:**
> "Back to [X]. We were at: [one-sentence state]. Continuing."
