# `~/.claude/settings.json` needs a scoped commit after Infigraph removal

**Filed from:** shming.com, 2026-08-31

## Observation

Infigraph (a global MCP-based code-intelligence integration with an extensive
hook system) was fully removed during a shming.com session — 10 hook
registrations and the MCP server entry deregistered from `~/.claude/settings.json`
and `~/.claude.json`, both CLAUDE.md Infigraph sections emptied
(`~/.claude/CLAUDE.md` and shming.com's own gitignored `.claude/CLAUDE.md`),
10 orphaned `infigraph-*.sh` hook scripts deleted from `~/.claude/hooks/`, and
shming.com's 46MB `.infigraph/` data directory deleted.

`~/.claude` is itself a git repo (separate from the now-standalone
`~/.claude/skills/shmorch` repo). It now carries a real, scoped diff in
`settings.json` (the 10 removed hook entries) worth committing. That repo also
carries a large amount of unrelated pre-existing drift (plugin marketplace
syncs, paste-cache churn, deleted plan files) that predates this session and
has nothing to do with the Infigraph removal — don't bundle that drift into
this commit.

Also worth noting: `~/.claude/skills/shmorch/.infigraph/` still exists on disk
— the shmorch skill's own project directory has its own Infigraph index data
that this pass didn't touch, since the removal was scoped to shming.com and
the global config, not every project with a local `.infigraph/` directory.

## Proposed fix

Next time this repo (`~/.claude`) is touched, or when Shmorch/James asks:
1. `git -C ~/.claude diff settings.json` to confirm the diff is still just the
   Infigraph hook removals (re-verify — other tooling may have touched it
   since 2026-08-31).
2. Stage and commit only `settings.json` from that repo, with a message
   describing the Infigraph hook removal.
3. Leave the rest of `~/.claude`'s dirty state alone unless asked separately.
4. Separately, decide whether `~/.claude/skills/shmorch/.infigraph/` should
   also be cleaned up, or is out of scope / harmless leftover data.

Note: `~/.claude/CLAUDE.md` and `~/.claude/hooks/` were also edited/deleted
this session, but both were already untracked in the `~/.claude` repo before
this session, so they produce no diff to commit either way.
