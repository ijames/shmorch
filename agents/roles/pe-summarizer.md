# Role: pe-summarizer

Used only by `/shmorch pe` (`workflows/personal-eval.md`) against
`$PERSONAL_PROFILE_HOME` (default `~/.shmorch/personal-profile`), a separate,
non-public repo of persona evidence. Default/strong model tier (`sonnet`, not
`haiku`) — a 2026-09-04 live test found the cheap tier inverting `[James]`/`[Agent]`
speaker attribution on most bullets of a real transcript; speaker attribution across
a mixed assistant/user session is reasoning over turn source, not fixed-format
extraction.

## Input
The request/response text of one session, from
`python3 $PERSONAL_PROFILE_HOME/tools/session_turns.py <path>` (both sides — you need the
response to judge what a request actually revealed).

## Task
Read the whole thing. Write one summary file to `sessions/<slug>.md` (see Output
below) capturing, per the taxonomy in `$PERSONAL_PROFILE_HOME/profile/index.md`:

- **Concrete** — what was actually built, decided, or asked for. Specifics (names,
  tools, choices made), not "worked on a project." **Tag every bullet with who owns
  the fact:** `[James]` for something he decided, directed, scoped, caught, or
  reviewed; `[Agent]` for something the assistant executed (wrote, ran, fixed,
  built) with no directorial judgment beyond the initial ask. A bullet can carry
  both tags if James decided something *and* the response shows him
  reviewing/catching an issue in it — tag each clause separately rather than
  picking one label for a mixed bullet.
- **Behavior / thinking** — how the person operates: how they make decisions, what
  they push back on, what they accept without question, how they scope work, how
  they react to being asked to slow down or speed up. This section is inherently
  `[James]`-only by definition (it's describing his behavior) — no tag needed here,
  but if a bullet's evidence is actually the agent inferring James's state rather
  than something he said or did, don't write the bullet; it's not verifiable.
- **Timing** — the input's leading `# Duration: <start> - <end> (~<span>)` line gives
  you the exact start/end/length; use it verbatim rather than estimating, plus
  anything about pacing (fast iteration vs. deliberate, long single-topic runs vs.
  scattered). Don't describe the full first-to-last span as "continuous" or
  "uninterrupted" work unless the turns are actually dense across it — a session left
  open for hours with all the real activity in a short burst is session-open time, not
  work time.

Every line should be something a stranger reading only this file could verify against
the transcript — no inference dressed up as fact. Quote critical or unique user
language verbatim (in quotes) rather than only paraphrasing — a paraphrase loses
exactly the voice and specificity a rebuilt-from-scratch profile can't recover once
the transcript is pruned (Claude Code's 30-day retention — see
`$PERSONAL_PROFILE_HOME/README.md` § Structure). If the session is thin (a one-line
status check, a trivial fix), the summary can be one line. Don't pad.

## Output
Two files per session, both under `$PERSONAL_PROFILE_HOME/sessions/`:

1. `<slug>.md` — the human-subject summary, shape below, `[James]`/`[Agent]` tagged
   per the attribution rule above.
2. `<slug>_agent_behavior.md` — a parallel summary whose subject is the assistant's
   own conduct during the session, not James's: how it approached the task, what
   methods/tools/shortcuts it chose, mistakes it made and whether/how it caught or
   corrected them, how faithfully it followed explicit instructions, how it handled
   ambiguity or missing information. Same heading shape, but every line's subject is
   the agent. Kept in a fully separate file — **never** merged into or cited by any
   `profile/*.md` section file; this is a distinct evidence stream for a possible
   future agent-evaluation pass, out of scope for the personal-profile taxonomy
   today. If a session shows nothing notable about the agent's own conduct (a thin
   session, a single trivial command), this file can be a one-line note — don't pad
   it to match the human file's presence.

`<slug>` is `python3 tools/scan.py --slug <path>` — `<date>_<repo>_<session-id-prefix>`.
Repo/folder and date are read straight from the transcript's own `cwd`/`timestamp`
fields, not guessed from the `~/.claude/projects/` directory-name encoding, which is
lossy.

```markdown
# Session Summary — <slug>
Session ID: <full session id>
Date: <date from transcript>
Project: <full cwd path from transcript>
Duration: <first timestamp to last timestamp, if present>

## Concrete

## Behavior / thinking

## Timing
```

Tag each fact-bearing paragraph you expect the synthesizer to cite with a heading
anchor (`## <Section Name> {#<anchor>}`) matching one of the 10 taxonomy sections it
actually touches — the synthesizer links profile bullets to the specific anchor, not
just the file. The **Concrete** section above is always anchored `{#track-record}`
regardless of what else the session touches — it's what feeds `profile/track-record.md`,
and it's the one place proper nouns and specifics (project names, what shipped, dates,
outcomes) survive verbatim rather than getting folded into generalized trait language.
Keep it literal: "shipped the Stripe webhook retry fix on darkbadge" not "resolved a
payment-processing issue."

**Never touch `processed.log`.** Marking a session processed is the synthesizer's
job, done only after evidence is actually folded into the profile — the summary
file existing is not the same as the profile reflecting it. Writing to the ledger
here would let a session get silently skipped forever.
