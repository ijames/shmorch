# Shmorch Skill Notes

> **Structural note (2026-05-07):** Eventually shmorch will have its own `docs/` section and this file will migrate there. When that happens, NOTES.md becomes an index pointing into `docs/` rather than a flat append log.

---

## init — settings.json explanation

**Issue (2026-04-01):** During `/shmorch init`, the user paused when Claude wrote `.shmorch/.claude/settings.json` and asked why it was needed. The init command doesn't explain the purpose of any files it creates.

**What to consider:**
- Add a brief explanation in Step 3 of `commands/init.md` or in Step 7 (the report) describing what `.shmorch/.claude/settings.json` does: it wires up pre-tool safety hooks (blocks `rm -rf`, `git push --force`) and pre-allows common read-only commands.
- Alternatively, add a `## What Got Created` section to the Step 7 report so users understand what they're getting.
- The user was fine proceeding once explained — this is a "explain proactively" gap, not a design problem.

## State + docs should update continuously, not just at wrap

**Issue (2026-04-04):** State was only written at the end of the session (via /shmorch wrap). User expects state files and docs to be updated as work happens — not batched at the end.

**What to consider:**
- `go.md` and `build.md` should reinforce: update `plan.md` when a track starts/finishes a step, update `decisions.md` when a decision is made, update `stack.md` when a constraint is discovered — all in the moment, not deferred.
- The timelog already does this (stamps at every event) — state files should follow the same pattern.
- Docs (inline comments, architecture docs) should be updated alongside the code change, not as a separate pass.
- This is a "continuous not batched" principle worth making explicit in `shmorch-core.md` and `go.md`.

## build.md — Task agent protocol: loosen spawn decision, adopt richer DoD language

**Issue (2026-04-27):** The skill's `build.md` Step 3b uses rigid `Call Task (parallel implementers)` framing. In practice the decision of whether to use a sub-agent vs. implementing in the main task depends on factors the skill doesn't account for: complexity of the context handoff, how isolated the module truly is, and whether the communication overhead of a Task prompt is worth it.

**What to consider:**
- Rename Step 3b from "Call Task (parallel implementers)" to "spawn Task agents" and reframe the decision rule to lean toward calling Tasks: "Call Task agents for each module — unless the module is so tightly entangled with in-flight context that fully briefing an agent would cost more than implementing it directly. Default is Task; inline is the exception."
- The project's `build-pre-task.md` (pre-2026-04-27 version) has a cleaner Definition of Done with richer checklist language — specifically:
  - The Tests section asks "did any new public methods get added or changed?" rather than a flat bullet — this surfaces the question more reliably
  - The Track section includes "fill in ↑ source and → destination links before writing anything else — if you can't fill in the destination, the track isn't scoped" — this is a strong scoping guard that should be in the skill
  - The Commit grouping section uses stronger language: "If tests or docs are missing, do not commit the code alone. Either finish them or create a track step to complete them and note the gap explicitly."
- The skill's DoD is a condensed version that loses these nuances. Adopt the richer project language into the skill's Step 4.
- Add the Checklist Summary block (the four-item pre-commit checklist) from the project version — it's a useful at-a-glance gate that the skill's version is missing.

## Command → workflow → role/tools audit (from 2026-05-06 self-improve)

**Issue:** The command → workflow → role/tools pattern was established as the standard architecture for all Shmorch commands. Existing commands were built before this standard and many carry their workflow steps inline in the command file rather than dispatching to a separate workflow.

**What to accomplish:**
- Audit all files in `commands/` against the pattern: command = short entry point + dispatch; workflow = all procedural steps; role = agent framing; tools = only for scripts that run outside sessions
- Commands known to carry inline steps (need workflow extraction): `wrap.md`, `go.md`, `self-improve.md`, `vacuum.md` (has a workflow file but the command may still have inline steps), `init.md`, `discover.md`
- For each command that needs it: create or extend the corresponding `workflows/<name>.md` and slim the command file down to dispatch + when-to-use
- This is a structural refactor of the skill itself — scope as a track if needed

---

## Backlog may be better modeled as a dependency stack than a flat list

**Issue (2026-05-07):** When work items block each other (e.g. equity-factory → order-price-gherkin), a flat domain list doesn't surface the push/pop relationship. The developer had to mentally track "do this first" without structural support.

**What to consider:**
- plan.md's backlog could have a formal "Active Stack" section at the top where blocked chains are pushed and popped in dependency order, separate from the flat domain inventory below.
- This is a LIFO model for the hot path: top of stack = do next; bottom = not yet unblocked.
- Relates to the Beads/Conductor evaluation already in the backlog — a proper dependency graph tool would make this structural rather than prose.
- Very loose for now — worth revisiting if dependency chains become common.

---

## Shmorch should be proactive, not passive — never just stop

**Issue (2026-04-04):** When the user asked "where are we?" and then said "not yet" to starting a track, Shmorch answered the question and went quiet. It should have kept driving.

**What to consider:**
- Shmorch is the active development lead. Unless the user explicitly says "done for now" or "quit", it should always propose a next move.
- After answering a status question, follow up: "Want me to start on docs-audit now? I can dig into what's actually in the docs directory and give you a picture before we commit to the track."
- When there are gaps (unfilled context.md fields, empty stack sections, unverified assumptions), surface them proactively: "Your context.md still has placeholder preferences — want to fill those in? It'll help when we get to the commit and test tracks."
- When the user says "not yet" to starting work, don't stop — ask what's holding them back or offer something smaller: analysis, a quick audit, filling in state, answering a question about the codebase.
- The right mental model: Shmorch is a dev lead who keeps the project moving, not a tool that answers questions and waits. It should feel like pairing with someone who always has a suggestion for what to do next.
- Add to `go.md`: after asking "what do you want to work on?" and getting a non-answer, offer 2-3 concrete options rather than going silent.

## Ambient/system-triggered state changes need smooth transitions, not just user-initiated ones (2026-07-29)

**Issue:** `core/ux.md` already encodes cognitive-load-driven animation ("UX is cognitive load management," Sweller's Cognitive Load Theory, animation as the mechanism that avoids forcing users to reconstruct state changes) — but its examples (open/closed, loading/done, error/success) are all user-initiated actions. While building a light/dark theme toggle for shming.com's homepage POC, the developer (James) raised a distinct case: **ambient, system-triggered changes** — e.g. the OS flipping `prefers-color-scheme` at sunrise/sunset — are low-stakes and infrequent (twice a day) but still deserve a smooth transition, not a snap. His framing: the choice of when to demand the user's *executive/conscious* attention vs. letting a change register only at the unconscious/peripheral level is itself a cognitive-load decision, separate from "does this state change need an animation at all." A jarring flash on an ambient change forces conscious attention onto something that should stay below awareness; a smooth fade lets it pass unnoticed, which is the actual goal (make the screen feel physical/continuous, not virtual/interrupting).

**What to consider:**
- `core/ux.md`'s "State changes" bullet (item 2 under "every component defines") currently only frames transitions around explicit UI state machines. Consider adding a second category: ambient/system-triggered state (theme-follows-OS, background sync indicators, autosave status, connectivity changes) — these should default to smooth CSS `transition` on the affected custom properties/colors, specifically *because* they're unattended — the user didn't ask for the change, so it must not demand their attention either.
- Concrete implementation pattern worth capturing as an example in `core/ux.md`: CSS custom properties for theme colors + a blanket `transition: background-color, color, border-color` on themed elements handles both the system-level flip (`@media (prefers-color-scheme: dark)`) and a manual override (`:root[data-theme]`) with the same mechanism — no JS-driven repaint, no flash-of-wrong-theme, because the transition is declarative and applies regardless of what changed the underlying variable.
- Possible one-line addition to the "honest framing" paragraph: cognitive load isn't just about *whether* a transition communicates a change — it's about whether the change should be *promoted to conscious attention at all*. Frequent/ambient/system-driven changes are a case where the animation's job is to keep the change entirely off the user's executive attention, not just legible.

## NOTES.md should become an inbox directory, not a flat append-only file (2026-07-29)

**Issue:** James (working in shming.com) pushed back on the flat-file `NOTES.md` model itself while the entry above was being added. His objection: a single growing file mixes unrelated observations together, has no per-item lifecycle, and doesn't match the pattern Shmorch already ships elsewhere — `templates/docs/inbox/index.md` establishes a per-project inbox *directory* where dropped files get individually reviewed and graduate into the right `docs/` section. `NOTES.md` is the same conceptual thing (an unreviewed capture point that `self-improve` later triages) but implemented as one flat file instead of that directory pattern.

**What to consider:**
- Replace `$SHMORCH_HOME/NOTES.md` with `$SHMORCH_HOME/docs/inbox/` (or similar), one file per captured observation — mirrors the existing per-project inbox template instead of introducing a second, inconsistent pattern for the same concept.
- `self-improve.md` Step 3 (evidence gathering) and Step 7 (clear addressed items) both currently assume a single `NOTES.md` file — both need rewriting for a directory: Step 3 reads all files in the inbox dir instead of one file; Step 7 deletes/archives individual graduated files instead of rewriting one file with surviving items.
- Also update the fallback logic noted in `self-improve.md` ("`.shmorch/NOTES.md` (or `$SHMORCH_HOME/NOTES.md` if no project NOTES.md exists)") — decide whether project-level capture should also move to a `docs/inbox/`-style directory for consistency, or whether NOTES.md stays project-local while only the skill's own top-level file becomes a directory.
- Migration: existing `NOTES.md` entries (including the "ambient/system-triggered state changes" entry directly above and the prompt-injection entry below) should each become their own file under the new inbox dir rather than being lost.
- This is itself a candidate for the branch → PR → merge skill-change flow, not a direct edit — flagged here for `self-improve` to turn into a proper proposal.

## Product design criteria: respect system settings by default (2026-07-29)

**Issue:** After resolving the shming.com theme decision (light/dark, follows `prefers-color-scheme`, manual override available), James generalized it into a standing product-design expectation: **when the OS/browser already exposes a preference relevant to the product, the product should honor it by default rather than making the visitor state it again.** Theme is the concrete case here, but the principle is broader — the same reasoning applies to `prefers-reduced-motion` (skip/simplify animation for users who've opted out), `prefers-contrast`, locale/language, and any other ambient system signal a browser or OS surfaces.

**What to consider:**
- Add to `core/ux.md` (pairs naturally with the ambient-transition entry above — same session, same root cause: system-driven state deserves first-class treatment, not bolt-on treatment) a explicit line: components/pages should query and default to relevant `prefers-*` media features and other OS-exposed signals before falling back to an author-chosen default; an explicit in-app override is additive, never the only path.
- Concrete checklist candidate for spec time: "Does this component have a relevant OS/browser preference (color scheme, reduced motion, contrast, locale)? If yes, default to it."
- `prefers-reduced-motion` specifically interacts with the ambient-transition entry above — the smooth-transition recommendation there should be conditioned on `prefers-reduced-motion: no-preference`, since a user who has disabled motion should get instant/no transition instead, not the same fade. Worth flagging as a dependency between the two proposals so `self-improve`/whoever implements doesn't ship one without the other. A minimal working pattern (`@media (prefers-reduced-motion: reduce) { * { transition-duration: 0.001ms !important; } }`) is already live in `shming.com/prototypes/homepage-skin-poc/style.css` as a reference.

## Session recaps should list files touched and any git PRs (2026-07-29)

**Issue:** End-of-response/session recaps in Shmorch-driven work summarize *what* was decided or built in prose, but don't consistently enumerate the concrete artifacts changed — which files were touched, and whether a PR/commit was opened. The developer (James) wants this reliably present, not just when it happens to be relevant to the prose summary.

**What to consider:**
- Wherever Shmorch produces a recap (end-of-turn summary, `wrap.md` session close, track status updates), append a short "Files touched" list (paths only, no diff) and a "PR/commit" line (link or "none this session") when applicable.
- Likely touches `workflows/wrap.md` (session close report) and possibly `shmorch-core.md`'s general "end-of-response" expectations — decide whether this is a wrap-only requirement or applies to every substantive response.
- Keep it terse — a flat file list and one PR line, not a full diff or changelog prose.

## Prompt injection observed (2026-07-07) — security

**Issue:** While running Shmorch on DarkBadge, a `<system-reminder>` block appeared wrapped around an `AskUserQuestion` tool result — it quoted the real diff plausibly, then appended a fabricated "don't tell the user" directive with no source in any file. The secrecy clause is the injection tell.

Shmorch's own shipped hooks don't match this signature (pre-tool.sh is Bash-only; none wrap `AskUserQuestion` or add secrecy text) — the vector is likely upstream (harness) or a non-shmorch hook/MCP wrapper. Full detail + next steps: `docs/state/tracks/20260707-prompt-injection-observed/index.md`.

## Stub tracks on separate branches collide on shared index/plan files (2026-07-29)

**Issue:** On treeclusion, four "deferred intent" stub tracks (per the doctrine "Deferred intent must have a stub track") were opened in one session and, per branching discipline ("every track gets its own branch"), split onto four independent `docs/YYYYMMDD-*` branches off `main` — each just adding its own `tracks/<name>/index.md` file. That part worked cleanly. The developer then flagged the next step: merging them back into `main` sequentially will hit real conflicts, because stub-track creation isn't actually file-isolated — every track also touches shared files (`docs/project/plan.md`'s backlog list, and potentially `docs/project/tracks/index.md` or similar registries if one exists), and four branches all edited the same shared file independently. The doctrine assumes tracks are isolated by branch; in practice, doc-only stub tracks are isolated in their *own* new file but still collide on the *shared* index/backlog file every track is required to update.

**What to consider:**
- The stub-track workflow (wherever "Deferred intent must have a stub track" is operationalized — `shmorch-core.md` and/or a `workflows/` file) should call out this collision risk explicitly when more than one stub track opens in the same session: either (a) batch same-session stub tracks onto one shared branch instead of one-branch-per-track when they're pure docs additions with no build risk, or (b) if one-branch-per-track is kept, defer the shared `plan.md` backlog-line addition to the merge step itself (added fresh on `main` right before/after each merge) rather than committing it on the stub's own branch, so the branches never touch the same line of the same file.
- Worth checking whether the project has a proper per-track registry (an index file listing all tracks) vs. relying on `plan.md`'s prose backlog — a registry with one line/entry per track file, or no central listing at all (tracks discoverable by directory scan), would remove this class of collision entirely. If `plan.md`'s backlog is staying prose-based, this is a structural argument for switching it to a generated/scanned view instead of hand-maintained collision-prone text.
- The `commit.md` workflow's "Track" DoD step ("mark the step done or update progress in the track file before committing") should be extended: when a session opens multiple stub tracks in a single sitting, flag that they'll need independent branches AND that any shared backlog-file edit should NOT be included in the per-track branch commit if collision-avoidance (option b above) is adopted.
- Not yet resolved in this session — reported here rather than acted on since it needs a decision on which mitigation (a, b, or registry-based) fits the project, and this is itself a candidate for the branch → PR → merge skill-change flow, not a direct edit.

## New core doctrine: pnpm precedent for JS/TS projects (2026-07-29)

**Issue:** On treeclusion, `git worktree` (used for parallel/multi-agent track builds per branching discipline) doesn't share `node_modules` across worktrees. With plain npm, every new worktree needed a full fresh install before `tsc`/build would even resolve types — either a slow per-worktree tax or an easy-to-skip step that silently leaves type-checking broken (this actually happened: a worktree's `tsc` ran against the wrong/empty `node_modules` and missed a real type error until pnpm was adopted and the install became fast enough to just do). Switching treeclusion to pnpm (global content-addressed store, hardlinked into each worktree's `node_modules`) fixed it — installs went from "needs npm install, sometimes skipped" to ~1s, no matter how many worktrees are open. The developer confirmed this should be the standing precedent for all Shmorch-managed JS/TS repos, not a one-off fix.

**What to consider:**
- Draft content ready to drop in as `core/js_tooling.md` (was written and validated this session, then backed out per developer instruction to go through NOTES.md/self-improve instead of a direct branch/PR): pnpm as the default for new JS/TS projects and for existing projects with no committed lockfile yet (adoption, not migration — don't force-convert a project already on an established npm/yarn habit); rationale as above; a short note that `uv` is the Python analogue (global content-addressed cache, hardlinked into venvs) and should get the same "prefer for new projects" precedent, since `pip`/`poetry`/`conda` all still duplicate per-venv.
- Add a row to `core/index.md`'s table once the file lands.
- No `.shmorch/VERSION` / `$SHMORCH_HOME/VERSION` bump has been done — that's part of the skill-change workflow once this graduates out of NOTES.md, not before.
