# Shmorch's own repo never installed its own safety hooks; README overstates what they do

**Filed from `shmorch` (self), 2026-09-08.**

## The gap

While fixing `git-discipline-self-repo-direct-to-main-drift.md`, found that
`shmorch-ln` (this skill repo, working under its own doctrine) has neither
`.githooks/` nor `.claude/hooks/` installed — `init`'s hook-sync step
(`workflows/init.md`, `workflows/auto-update.md` Step 2.9) has apparently
never been run against the skill repo itself, only against client projects.

Separately, `README.md` § Safety currently claims the Claude Code
`PreToolUse` hook "blocks `rm -rf`, `git push --force`, **and direct pushes to
`main`/`master`** before they run." Checked `templates/.claude/hooks/pre-tool.sh`:
it only matches `rm -rf|rm -r /|git push --force` — there is no direct-push-to-
main block in it at all. The README claim is stale/inaccurate, not just
this repo's install missing.

## Not resolved — needs a decision, not just a copy-paste fix

- Should `shmorch-ln` self-install its own `.githooks/` + `.claude/hooks/` the
  same way client projects do (run `init`'s hook-sync against itself), or is
  there a reason the skill repo is meant to be different?
- Does `pre-tool.sh` need an actual `git push` (non-force, to `main`/`master`)
  block added to match what README claims, or does README need correcting to
  describe only what the hook actually does today?
- Once decided, re-verify README § Safety's whole bullet list against the
  actual hook script contents rather than trusting the prose — this is the
  second doc/behavior mismatch found in that section in one pass.
