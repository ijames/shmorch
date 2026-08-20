### Self-Improve Proposals — 2026-06-16 | Project: PholderShare

#### Proposal 1: Fix crash in check-self-improve-gate.sh on first run
**Pattern:** `set -euo pipefail` + `grep ... | tail -1` with zero matches causes the script to exit 1 silently before the intended empty-string fallback (`echo PROCEED`) can run. Confirmed via `bash -x` trace.
**Frequency:** Deterministic — hits every project's first-ever self-improve run (this project included; line 19 had no prior "self-improve: complete" entry in timelog.md until tonight).
**File:** `~/.claude/skills/shmorch/tools/check-self-improve-gate.sh`
**Change:** Line 19, append `|| true` to the grep so the pipeline doesn't trip `pipefail`/`-e` on no-match:
```bash
LAST_RUN_LINE=$(grep "self-improve: complete" "$TIMELOG" 2>/dev/null | tail -1 || true)
```
Same risk exists at line 26 (`LAST_SESSION_END_LINE=$(grep "SESSION_END" ...)`) if a timelog ever lacks a SESSION_END line — add `|| true` there too for consistency.
**Improvement:** Self-improve gate works on first run for any project instead of crashing with no output, which currently makes the gate indistinguishable from "not yet implemented."

---

#### Proposal 2: Remove unresolved git merge-conflict marker from docs-nav.sh
**Pattern:** Running `bash ~/.claude/skills/shmorch/tools/docs-nav.sh docs/` throws `line 27: =======: command not found`. The file contains an unresolved merge conflict from commit `c886980` (feat(tools): docs-nav.sh).
**Frequency:** Deterministic — breaks every invocation of this tool, not just intermittent.
**File:** `~/.claude/skills/shmorch/tools/docs-nav.sh`
**Change:** Around line 26-29, resolve the conflict markers. Current broken state:
```
patched=0
=======
skipped=0
>>>>>>> c886980 (feat(tools): docs-nav.sh — auto-patch sibling nav links in docs/)
```
Need both counters; correct resolution is keeping both lines and removing the markers:
```
patched=0
skipped=0
```
(Also missing the opening `<<<<<<<` marker — check whether more of the file is affected; do a full diff against the pre-conflict version if available, or re-read the rest of the script for any other inserted `<<<<<<<`/`=======`/`>>>>>>>` lines before treating this as fully fixed.)
**Improvement:** docs-nav.sh becomes runnable at all. This is a tool used by the documentarian workflow — currently any project invoking it gets a confusing shell error instead of working nav links.

---

#### Proposal 3: Mechanical anti-decision check before writing backlog/plan additions
**Pattern:** A backlog note (htmx as Taconite replacement) was added that directly contradicted the existing 2026-06-14 anti-decision ("Do not add HTMX, Alpine.js, or any other framework layer at this stage" in decisions.md). It was caught only because the agent happened to cross-reference manually via AskUserQuestion — the bidirectional-sync check in shmorch-core.md ("whether the change countermands a decisions.md entry") is documented as a thing to always do, but has no structural enforcement.
**Frequency:** One confirmed near-miss this session; the doctrine text itself acknowledges this is supposed to happen "in the moment" every time a plan/backlog item is added, meaning the exposure is every single backlog write, not a one-off.
**File:** `~/.claude/skills/shmorch/workflows/build.md` (or wherever backlog/plan.md additions are documented as a step) — add a concrete sub-step, and optionally `~/.claude/skills/shmorch/tools/` for a grep helper.
**Change:** Add a step: before appending any new backlog/plan.md item, extract its key nouns (tech names, pattern names) and grep `docs/development/anti-decisions.md` and the "Anti-decision:" lines in `decisions.md` for the same terms:
```bash
grep -i "anti-decision" -A2 docs/development/decisions.md | grep -i "<keyword>"
```
If a match is found, surface it to the user before writing the backlog item, rather than after. Document this as a required pre-write check in the same place the bidirectional-sync rule already lives in shmorch-core.md, with the explicit grep command so it's mechanical rather than a memory-dependent vigilance step.
**Improvement:** Converts a "remember to check" instruction (probabilistic) into a "run this grep" instruction (mechanical), consistent with the project's own stated preference ("Where possible, encode prohibitions as lint rules with remediation instructions — markdown instructions alone are probabilistic" — PholderShare CLAUDE.md override).

---

### No-action observations

- **Stub-session churn:** At least 6 occurrences of `SESSION_START` immediately followed by `SESSION_END | auto-closed by stop hook` within seconds-to-minutes, then a *new* `SESSION_START` shortly after with real work (2026-05-29 00:10, 2026-06-08 23:03, 2026-06-14 13:05, 2026-06-14 15:39, 2026-06-15 16:36, 2026-06-15 18:31/32, 2026-06-16 12:51, 2026-06-16 21:00). This meets the 2+ bar for a pattern, but it's ambiguous whether this is a genuine workflow problem (stop hook firing too eagerly on near-empty sessions) or just how the user naturally opens/closes terminal tabs — recommend watching one more cycle and checking with the user whether the auto-close threshold needs tuning before proposing a tools/ change.
- **Recurring unresolved "next up" item:** "Push `20260529-v2-initial`, open PR, return to main (no remote configured)" appears verbatim or near-verbatim in three consecutive session closeouts (2026-06-14 first session, 2026-06-15/16, 2026-06-16 second) without resolution. This is a single carried-forward TODO rather than a workflow-phase friction pattern — likely just blocked on an external dependency (no git remote configured) rather than a shmorch process gap. Worth flagging to the user directly rather than proposing a skill change.
