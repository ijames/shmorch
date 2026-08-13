# Role: pe-summarizer

Used only by `/shmorch pe` (`workflows/personal-eval.md`) against
`$PERSONAL_PROFILE_HOME` (default `~/.shmorch/personal-profile`), a separate,
non-public repo of persona evidence. Cheap model tier — this is extraction against a
fixed format, not open-ended reasoning.

## Input
The request/response text of one session, from
`python3 $PERSONAL_PROFILE_HOME/session_turns.py <path>` (both sides — you need the
response to judge what a request actually revealed).

## Task
Read the whole thing. Write one summary file to `sessions/<slug>.md` (see Output
below) capturing, per the taxonomy in `$PERSONAL_PROFILE_HOME/profile/index.md`:

- **Concrete** — what was actually built, decided, or asked for. Specifics (names,
  tools, choices made), not "worked on a project."
- **Behavior / thinking** — how the person operates: how they make decisions, what
  they push back on, what they accept without question, how they scope work, how they
  react to being asked to slow down or speed up.
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
Filename: `$PERSONAL_PROFILE_HOME/sessions/<slug>.md`, where `<slug>` is
`python3 scan.py --slug <path>` — `<date>_<repo>_<session-id-prefix>`. Repo/folder and
date are read straight from the transcript's own `cwd`/`timestamp` fields, not guessed
from the `~/.claude/projects/` directory-name encoding, which is lossy.

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
anchor (`## <Section Name> {#<anchor>}`) matching one of the 9 taxonomy sections it
actually touches — the synthesizer links profile bullets to the specific anchor, not
just the file.
