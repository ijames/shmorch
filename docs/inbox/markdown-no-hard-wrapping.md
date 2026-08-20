# Markdown should not be hard-wrapped

Filed from `treeclusion`, 2026-08-20. Developer-stated position, applies to every Shmorch project.

*(This file is deliberately written unwrapped, as a demonstration of the proposal. The other inbox items are hard-wrapped, which is the status quo it argues against.)*

## Observation

Shmorch has no stated position on hard-wrapping markdown. In the absence of one, every skill file, template, and generated doc is hard-wrapped at roughly 95 columns — and every agent working in a Shmorch project inherits that by imitation, because the surrounding files look that way. The convention is being propagated without ever having been decided.

## Proposal

State a position in doctrine: **authored markdown is source for a renderer, not a reading surface. Continuous prose is written as continuous lines. No hard wrapping.**

Developer, verbatim:

> "I prefer any continuous text to be continuous with no formatting style line feeds. Style should come from style sheets, not the raw content."

## The argument

**Markdown is not intended to be read raw by humans.** It is rendered — in an editor preview, on GitHub, in a docs site, in Treeclusion. Hard wrapping optimizes the one surface nobody is supposed to be reading, at the cost of every surface they actually are.

**A hard wrap is a style decision smuggled into content.** It is a line-length opinion baked in by whoever last edited the file, in whatever terminal width they happened to have. It cannot adapt to the reader's window, font size, or column preference. That is precisely what stylesheets and renderers are for. In `treeclusion` the point is unusually sharp: the app has a reader-set `columnWidth` preference, so a hard-wrapped source file is a second, invisible, conflicting opinion about measure.

**"But git diff produces noise on long lines."** That is git's problem, not the content's. `--word-diff` exists, and both GitHub and every modern review tool render intra-line diffs. Deforming the source to flatter a diff algorithm is the tail wagging the dog.

**"But my editor doesn't soft-wrap."** That is the tool's problem, and the developer's. Any dev tool that cannot soft-wrap prose in 2026 is not fit for editing docs, and the correct response is to fix the tool rather than to permanently disfigure every file it touches.

## Second-order evidence

Hard wrapping does not merely fail to help — it manufactures bugs.

On 2026-08-20, `treeclusion` fixed a markdown parser defect where a bullet whose text wrapped onto a continuation line, or sat on the line after a bare `*`, rendered as a detached paragraph below the list instead of as part of the bullet. That entire class of defect exists *only* because content is hard-wrapped. Unwrapped content cannot produce a lazy-continuation edge case, because there are no continuation lines.

Worth noting: a doc in that repo had been hand-unwrapped by the developer as a workaround, and nobody noticed the workaround was a workaround. The convention created the bug, and then obscured it.

## Scope and boundaries — for review

- **Parsers must stay tolerant.** This governs *authoring*, not *reading*. Any Shmorch project that consumes third-party markdown must still handle hard-wrapped input correctly, because it does not control the sources it reads. The rule is "do not write hard wraps", never "assume none exist."
- **Not everything is prose.** Code blocks, tables, YAML frontmatter, and list *structure* keep their line breaks. The rule applies to continuous prose only.
- **Migration is opportunistic, not a sweep.** Adopt going forward; reflow a file when it is being edited anyway. No big-bang reflow commit across a docs tree — the diff would be enormous and would bury real history.
- **The templates need to change too.** Scaffolded files carry the convention into every new project, so the position is not actually adopted until `templates/` is authored unwrapped.
- **Semantic line breaks are the road not taken.** One sentence per line keeps diffs surgical without encoding a visual width, and is the usual middle position. It still inserts linefeeds into continuous prose, so it is out under the stated preference. Recorded here so a future reviewer knows it was considered rather than missed.

## Suggested landing

- `core/documentation.md` — the authoring rule itself, since that file already owns how docs get written.
- `core/engineering-standards.md` — a cross-reference, alongside "no em dash" and "never hand-edit auto-generated files", which is where an agent is most likely to look for formatting rules.
- `templates/` — reauthor unwrapped, or the rule regenerates its own violations.
