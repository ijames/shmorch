# Shmorch Skill Notes

## init — settings.json explanation

**Issue (2026-04-01):** During `/shmorch init`, the user paused when Claude wrote `shmorch/.claude/settings.json` and asked why it was needed. The init command doesn't explain the purpose of any files it creates.

**What to consider:**
- Add a brief explanation in Step 3 of `commands/init.md` or in Step 7 (the report) describing what `shmorch/.claude/settings.json` does: it wires up pre-tool safety hooks (blocks `rm -rf`, `git push --force`) and pre-allows common read-only commands.
- Alternatively, add a `## What Got Created` section to the Step 7 report so users understand what they're getting.
- The user was fine proceeding once explained — this is a "explain proactively" gap, not a design problem.

## State + docs should update continuously, not just at wrap

**Issue (2026-04-04):** State was only written at the end of the session (via /shmorch wrap). User expects state files and docs to be updated as work happens — not batched at the end.

**What to consider:**
- `go.md` and `build.md` should reinforce: update `plan.md` when a track starts/finishes a step, update `decisions.md` when a decision is made, update `stack.md` when a constraint is discovered — all in the moment, not deferred.
- The timelog already does this (stamps at every event) — state files should follow the same pattern.
- Docs (inline comments, architecture docs) should be updated alongside the code change, not as a separate pass.
- This is a "continuous not batched" principle worth making explicit in `shmorch-core.md` and `go.md`.

## Shmorch should be proactive, not passive — never just stop

**Issue (2026-04-04):** When the user asked "where are we?" and then said "not yet" to starting a track, Shmorch answered the question and went quiet. It should have kept driving.

**What to consider:**
- Shmorch is the active development lead. Unless the user explicitly says "done for now" or "quit", it should always propose a next move.
- After answering a status question, follow up: "Want me to start on docs-audit now? I can dig into what's actually in the docs directory and give you a picture before we commit to the track."
- When there are gaps (unfilled context.md fields, empty stack sections, unverified assumptions), surface them proactively: "Your context.md still has placeholder preferences — want to fill those in? It'll help when we get to the commit and test tracks."
- When the user says "not yet" to starting work, don't stop — ask what's holding them back or offer something smaller: analysis, a quick audit, filling in state, answering a question about the codebase.
- The right mental model: Shmorch is a dev lead who keeps the project moving, not a tool that answers questions and waits. It should feel like pairing with someone who always has a suggestion for what to do next.
- Add to `go.md`: after asking "what do you want to work on?" and getting a non-answer, offer 2-3 concrete options rather than going silent.
