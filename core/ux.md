# UX Philosophy — All Components Are Dynamic

UX is cognitive load management, not aesthetics. Animation and motion are not decorative — they are the primary mechanism by which state changes are communicated without forcing the user to reconstruct what happened.

An interface where elements flash in or out, or change state abruptly, is inflicting extraneous cognitive load on every user, on every interaction. The user must detect the change, identify what it was, reconstruct where it went, and re-anchor their spatial model — every time. Animation eliminates all four steps by making the transformation visible.

**At spec time, every component defines:**
1. **Entry** — how does it appear? (fade-in, scale up, slide from where, spring or ease?)
2. **State changes** — which transitions are load-bearing? (open/closed, loading/done, error/success)
3. **Exit** — how does it leave?

"We'll add animation later" signals that the component's interaction design is unfinished — not that the feature is nearly done. A spec with no transition story is an incomplete spec.

**The honest framing:** Software UIs are inherently smoke and mirrors — visual chrome that helps the user form and maintain a mental model of an underlying state machine. Animation makes that fiction coherent. Without it, the mental model breaks on every state change. The goal is to make the fiction so coherent that the user never notices the seams.

**Research basis:** Sweller's Cognitive Load Theory (extraneous load from abrupt changes), change blindness research (users miss instantaneous changes — animation acts as connector), Tversky, Morrison & Bétrancourt 2002 (animation facilitates comprehension when it reveals the transformation). Material Design motion principles: *informative*, *focused*, *expressive* — all three are functional, not decorative.

**Layer selection:** CSS `transition` for simple A→B state changes (always prefer), CSS `@keyframes` for sequences, CSS View Transitions API for full-view/route transitions (Baseline 2025), `motion`/Framer Motion for gesture-driven, layout morphs, and exit animations (things CSS structurally cannot express).

**Style and motion abstraction balance:** Style and motion code must be readable to a developer who is not a CSS or animation specialist. When a developer opens a component file, they should understand what it looks like and how it moves without chasing definitions across multiple files.

The rule: **abstract for naming and reuse — colocate for readability.**

- Extract dynamic color/style computations to named utility functions when reused across components, or complex enough to need a name
- Keep animation configs as named constants *above the component's `return`* in the same file — not in a separate module — unless genuinely shared across multiple components
- A developer should be able to read a component file and understand both its appearance and its motion without leaving the file
- The test: "If I removed all named constants and inlined them, would the JSX still be readable?" If yes, the abstraction adds no value. If no, the abstraction is earning its place.

Over-abstraction (moving every animation config to a separate file) is as harmful as under-abstraction (walls of inline noise). The goal is a component that reads as a unit. Readability is the constraint; naming and reuse are the tools.

---

## Live Config Binding as Design Practice

For any project with tunable visual or experiential output, build a live config binding tool **before or alongside** speccing the output itself. The tool is how you discover what the spec should be — not the other way around.

**Why:** Good design optima in visual/experiential systems are often not reachable by analytical reasoning. You cannot think your way to the right spiral radius, the right colour temperature, the right timing curve. You can only feel your way there. Live binding — where moving a slider immediately updates the output — compresses the explore-evaluate loop to near-zero latency and lets you converge on results you could not have specified in advance.

**Implication for spec work:** When a system has tunable parameters, the first spec question is not "what are the right values?" but "what parameters need to be live-bindable?" Spec the binding surface. Let the experimenter answer the value questions.

**The designer is a theme creator.** When a user finds a configuration they like, saving that config state *is* the theme. Theme creation is not abstract design work done upfront — it is "reach a state you like in the experimenter, name it, save it." A theme system built on top of a serialisable config costs nothing to add and makes the tool immediately meaningful to users who want to personalise or share their setup.

**Scope:** This applies anywhere output is experienced rather than just read: visualisations, audio, motion, 3D scenes, generative UI, game feel. If a human has to perceive it to evaluate it, live binding is not a nice-to-have — it is the primary design method.
