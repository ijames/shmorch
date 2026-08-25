# No-em-dash rule: scope gap + doctrine-liveness gap

Filed from `shming.com`, 2026-08-25. Two gaps, same root cause: a global rule existed but didn't actually prevent the failure.

## Observation

`core/engineering-standards.md:14` already bans em dashes in externally-read content. It still leaked through, twice:

1. **Scope narrowed by a project override, unnoticed.** `shming.com/.shmorch/AGENTS.md` restated the rule as "anything committed to this repo" — narrower than the global rule, which doesn't say "this repo," it says externally-read content, wherever it lands. The narrowing wasn't flagged as a conflict with the global rule at write time.
2. **The restated rule sat unmerged.** It lived on an open PR for a day while work continued against `main`, where it wasn't present. Nothing checked whether it was actually live before relying on it.

Net effect: a generated cover letter for a real employer, and ~70 more instances across job.yaml/resume/win-win drafts, in `shming.com.private` (a sibling repo, never covered by "this repo" wording), all shipped with em dashes. An external editor caught it, not Shmorch.

## Proposal — replace, don't append

**`core/engineering-standards.md:14`** — replace the trailing scope clause. Current:

> Never use an em dash — or other AI-slop tells — in anything a person outside the authoring session will read: web/product content, docs, PR titles and descriptions, commit messages meant for human review.

Add one clause after "human review": **"— including generated content in any sibling or private data repo the project writes to, not just the repo this doctrine lives in. A project-level override may add detail; it may not narrow this scope."**

**New, in `core/operations.md`** (near the VERSION/skill-change mechanics, since that's the file that already governs what counts as "live"):

> A written rule binds only once merged to the branch the project treats as canonical. A rule sitting on an open PR is not in effect. Before treating any `.shmorch/AGENTS.md` or `core/*.md` change as active, confirm it's merged, not just committed.

## Scope and boundaries

- Applies to any project-level override file (`.shmorch/AGENTS.md` per-project), not just this one incident.
- Does not require a new enforcement mechanism (lint/CI) here — that's a separate, larger lift. This is the doctrine-text fix; enforcement tooling can be a follow-on item if it recurs.

## Suggested landing

- `core/engineering-standards.md:14` — tighten in place.
- `core/operations.md` — new short paragraph near the VERSION-bump section.
- No VERSION bump required if this lands as the only change (docs-only per the existing rule at `core/operations.md:82`), unless bundled with a code/behavior change.
