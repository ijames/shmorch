---
status: Draft
updated: 2026-08-25
summary: Additive revisions to "The Wild West of AI" — one framing paragraph, one new section, three line-level inserts. Existing sections stay as published; nothing here rewrites them.
---

↑ [Track index](index.md)
**In this section:** [The Determinism Ladder](determinism-ladder.md) · ["The Wild West of AI" — capture and fairness assessment](wild-west-post.md)

# Blog revisions — additive only

Patches to https://blog.shming.com/2026/08/24/the-wild-west-of-ai/, addressing the gaps in
[wild-west-post.md](wild-west-post.md). **Existing sections stay as written.** Four of these
are drop-ins; two are single-sentence additions to sections that otherwise do not change.

Drafted without em dashes, per `core/engineering-standards.md` (public-facing).

---

## 1. Framing paragraph — insert in the intro, before "One Big Skill"

Closes the category-error gap. One paragraph, nothing else in the intro changes.

> Worth saying up front: these are not the same kind of artifact. Anthropic is describing a
> governed pipeline for an organization, with separation of duties, approval gates and a
> metrics program attached. Shmorch is a session orchestrator for one developer. Some of
> what reads as disagreement below is really just that difference. Where Anthropic has a
> control I do not, it is usually because the control has no meaning at n=1, not because I
> weighed it and passed.

---

## 2. New section — "What I Don't Have"

The main addition. Suggested placement: after "Testing/Success/Loops/Verification", before
"Living Diagrams", so it sits next to the other thing missing from both rather than
interrupting the earlier run of sections.

> ## What I Don't Have
>
> Three parts of the playbook I have no answer to, and one of them is the part that matters
> most.
>
> **Enforcement.** This is the real argument in Anthropic's piece and I skipped past it.
> Their claim is that enforcement moves from process to code: hooks that block an edit at
> the moment it happens, managed settings an engineer cannot override, permission denies,
> branch protection. Every rule in Shmorch is markdown that the model reads and is expected
> to follow. That is thousands of lines of instruction with no mechanical enforcement
> anywhere in it. Some of those rules are not judgment calls and never should have been
> prose: do not hand-edit generated files, do not change a test to make it pass, sync the
> deployment manifest after a dependency change. Each of those is one script away from being
> unbreakable rather than merely instructed. Anthropic is right about this and I do not have
> it.
>
> **Testing the configuration.** Shmorch modifies its own doctrine, deliberately, through a
> self-improve command. There is no regression coverage on the result. Anthropic's answer is
> an eval suite of real tasks with expected outcomes, gating any configuration change, with
> every production incident becoming a permanent eval. A system that rewrites its own rules
> with nothing checking the rewrite is in a worse position than one that never changes them,
> and that is where I am.
>
> **The loop actually closing.** Their sixth stage is the one I left out of the comparison
> entirely. A deterministic detector watches metrics with no model in the detection path,
> and response is tiered by how far out things are: log it, diagnose it read-only, or open a
> pull request. The finding is then written as an intent file and re-enters the pipeline at
> stage one. Keeping the model out of detection is the subtle call and it is the right one,
> because detection must not hallucinate while diagnosis may. I treat observability as
> something to design in. I have nothing that says what happens when the instrument fires.

---

## 3. "Tracks and Merging" — one sentence to add

The section stands. It just does not play the stronger card, which is the coordination
protocol rather than the commit shape. Append:

> The commit chain is the legibility half. The coordination half is a task protocol: when
> spawning an agent is actually worth it (parallelizable, role-specific, low file overlap
> with what is already loaded), one role per agent because a single context tends to agree
> with itself, and a structured return that the orchestrator has to gate on before the next
> phase starts. That is the part Anthropic leaves as roughly a paragraph about worktrees.

---

## 4. "Testing/Success/Loops/Verification" — one sentence to add

Currently reads as an inventory of test types, and Anthropic has a testing story too. The
differentiator is ordering, which is worth stating plainly. Append after the list:

> The list is not the interesting part, since any serious setup has most of it. The
> interesting part is ordering: no scenario means no feature, no test means no code, the
> test is red before the code exists, and how much rigor applies scales to what stage the
> project is actually in. Anthropic has feedback loops and evals but no ordering doctrine at
> all.

---

## 5. Same section — small correction

PostHog and Anthropic's evals currently sit together and are different objects. Change the
telemetry mention to name the distinction:

> PostHog covers product telemetry, which is what users are doing. That is a different
> object from evaluating the agent configuration itself, and I only have the first one.

---

## 6. Conclusion — one sentence to add

The Wild West framing implies preference reasonably rules. It does for tooling, but not for
the enforcement claim, and conceding that is a stronger close than leaving it open. Append
before the typewriter analogy:

> One caveat on my own framing. That everyone is building something custom is a claim about
> tooling, and I think it holds. It is not an argument against mechanical enforcement, which
> is true regardless of whose framework surrounds it. The frameworks can stay personal. The
> gates underneath them probably should not.

---

## Notes

- Order of value if only some land: **2** carries almost all of it, then **1**. Items 3 to 6 are polish.
- Item 2 is the only one that changes the shape of the piece. It reads as a concession section, which strengthens the documentation and orchestration arguments rather than weakening them.
- None of this touches "One Big Skill", "The Paper Trail", "Documentation", "Context Management" or "Living Diagrams".
