---
status: Reference
updated: 2026-08-24
summary: Captured summary of "The Wild West of AI" (blog.shming.com, 2026-08-24) plus an assessment of it as a fair comparison against the AI-Native SDLC Playbook.
---

↑ [Track index](index.md)
**In this section:** [Blog revisions — additive only](blog-revision.md) · [The Determinism Ladder](determinism-ladder.md)

# "The Wild West of AI" — capture and fairness assessment

**Source:** https://blog.shming.com/2026/08/24/the-wild-west-of-ai/
**Author:** James Bennett Saxon · **Published:** 2026-08-24

> **Capture caveat:** the text below is a *summarized* retrieval, not the verbatim post.
> Section structure and claims are preserved; wording is not, except where quoted. If this
> capture is to be cited as evidence, re-fetch the original verbatim first.

---

## Captured content

Framed as a response to Anthropic's AI-Native SDLC Playbook, comparing it to Shmorch, described as a solo development lifecycle framework for standalone developers.

| Section | Position taken |
|---|---|
| **One Big Skill** | One consolidated skill with many commands rather than many specialized skills, to avoid "an explosion of random names" — accepting that the skill itself becomes substantial. |
| **The Paper Trail** | Agrees with the Playbook: "documents and gitlog are a great place for the source of truth" over Confluence/Jira. Version-controlled sources now support flexible extraction and rendering. |
| **Tracks and Merging** | Identifies ambiguity in how the Playbook manages multiple tracks across long projects. Shmorch's answer: sequential PR merges using `merge` not `rebase`, producing a "punctuated commit chain" for visual clarity. |
| **Documentation** | Three categories, each evolving differently from inception to maturity: **creator docs** (institutional knowledge — ADRs, designs, decisions, specs), **project docs** (ongoing effort — tracks, sprints), **user docs** (compiled per Diátaxis). |
| **Context Management** | Frontmatter on all documents so agents can decide what to read. Oversized files break into subfolders with `index.md`; better agent traversal, acknowledged cost to human readability. |
| **Testing / Success / Loops / Verification** | TDD, functional, integration, e2e, BDD with Gherkin as quality gates, plus telemetry and evaluation tooling (PostHog named). |
| **Living Diagrams** | Absent from *both* approaches. Advocates C4 integrated with IcePanel or similar. |
| **Conclusion** | Similar solutions have likely emerged independently across the industry — a "convergence and divergence" pattern. Open question whether these frameworks standardize like past technologies or whether "custom" and "in-house" come to define enterprise systems; analogy to typewriters giving way to personalized word processor output. |

---

## Is it a fair write-up as a comparison?

**Short answer: accurate in everything it says, incomplete as a comparison.** Nothing in it
is wrong. But it omits the dimensions where the Playbook wins, and it does not name the
category difference that explains most of the divergence — so a reader finishes it with a
skewed picture in Shmorch's favour.

### What is fair, and genuinely well-observed

- **The documentation taxonomy is the strongest contribution and it is correctly claimed.** Creator / project / user with different maturation curves, plus Diátaxis for the user tier, is materially more sophisticated than the Playbook's `CLAUDE.md` + skills. The Playbook has no theory of documentation at all. Fair point, fairly made.
- **Frontmatter-driven traversal**, with the human-readability cost stated rather than hidden. Naming your own tradeoff is what makes this credible.
- **Living diagrams marked absent from both.** Self-implicating rather than point-scoring; this is the most obviously fair move in the piece.
- **The paper trail agreement.** Correctly identified as genuine convergence, not framed as an original insight.
- **The convergence/divergence conclusion** is a reasonable read of the moment and appropriately hedged.

### Where it falls short of fair

**1. The category difference is never stated.** The Playbook is a governed pipeline for an
organization; Shmorch is a session orchestrator for one developer. The Playbook's separation
of duties, managed settings, approval gates, and metrics program are not things Shmorch
decided differently — they are things that have no meaning at n=1. Comparing them without
saying so makes the Playbook look bureaucratic and Shmorch look complete. Both distortions,
and one sentence would fix it.

**2. It skips the Playbook's strongest material entirely.** Not mentioned anywhere:

- **Hooks, managed settings, permission denies** — the deterministic enforcement layer. This is the Playbook's actual thesis (enforcement moves from process to code) and the post does not engage with it. Given that this track exists *because* that thesis lands, the omission is significant.
- **Evals as config regression testing** — Shmorch self-modifies via `self-improve`/`auto-update` with no regression net. A live exposure, unmentioned.
- **The entire Maintain stage** — deterministic detection, tiered 1σ/2σ/3σ response, anomaly-becomes-intent. A whole stage of a six-stage playbook, absent from a comparison of it.

A comparison that omits the other side's three best arguments is not unfair in intent, but
it is unfair in effect.

**3. "Tracks and merging" answers a different question than the one it raises.** The
observation is right — the Playbook is genuinely thin here (parallel worktrees, roughly one
paragraph). But merge-not-rebase punctuated chains address *git legibility*, not track
coordination. The gap the Playbook actually leaves is **when to spawn and how to gate what
comes back**, and Shmorch answers that well in `TASK-PROTOCOL.md` — spawn conditions,
one-role-per-agent, return contracts, BLOCKER gating. That is the stronger card and it is
not played.

**4. The testing section underclaims.** Listing TDD / functional / integration / e2e / BDD
reads as an inventory, and the Playbook has a testing story too (in-session feedback loops,
CI evals). The actual differentiator is **ordering rigor** — no test no code, always-red,
temporal propagation, the Testing Depth Ladder scaling to project stage. The Playbook has
no ordering doctrine whatsoever. Underclaimed relative to what the repo actually contains.

**5. PostHog and evals get conflated.** Product telemetry (Shmorch's analytics dimension)
and config regression evals (the Playbook's Stage 4) are different objects solving different
problems. Naming them together blurs a distinction that matters.

**6. The framing sidesteps the central claim.** "Wild West" plus the typewriter analogy
implies an unstandardized space where personal preference reasonably rules. But the
Playbook's argument is that enforcement should be *mechanical* — which is a claim about
determinism, not taste, and it survives regardless of how varied the surrounding tooling
gets. Custom frameworks and deterministic enforcement are orthogonal; the framing treats
them as if answering one answers the other.

### Verdict

It is a fair and well-observed **position piece** — "here is what I built, here is where I
agree, here is what I think is missing." As that, it works, and the documentation taxonomy
and living-diagrams sections are its best material.

It is not a fair **comparison**, because a comparison owes the other side its strongest
case, and three of the Playbook's best arguments do not appear. The fix is small: one
sentence naming the different subjects (org pipeline vs. solo orchestrator), and a short
section conceding the enforcement layer, evals, and the Maintain loop. Conceding those
would also strengthen the piece — the documentation and orchestration arguments look more
credible next to an acknowledged weakness than next to silence.

See `research/research-20260824-ai-native-sdlc.md` for the fuller matrix, and
[determinism-ladder.md](determinism-ladder.md) for what follows from the enforcement gap.
