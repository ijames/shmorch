↑ [../session.md](../session.md)

## 2026-07-21 (interrupted — context ran low, resume here)

**Branch:** `main` (PR #60 `fix/20260721-template-graph-conformance` open, NOT merged — do not treat its contents as landed on main until merged)

**What was done:**
- Built `tools/track-graph-audit.sh` (deterministic scan: chunk-size cap, missing front-matter, `CLOSED_UNGRADUATED` closed-track-not-referenced-back candidates) and wired it into `documentarian.md` Step 2. Fixed `templates/.shmorch/docs/track-template.md`, which was missing the front-matter block the new rule requires — every new track from the old template would've re-violated it immediately. Logged as a `Compat: backfill` row in `core/documentation.md`. VERSION → `20260721.01`. All on **PR #60**, unmerged.
- User ran `shmorch sync` in `~/Projects/treeclusion` — the backfill offer surfaced and applied correctly (confirmed working end-to-end).
- Backfilled front-matter directly on `main` (docs-only, no PR needed) for two of the 13 flagged tracks: `tracks/20260525-graph-first-docs/index.md` and `tracks/20260707-multi-cli-portability/index.md` (already `Status: Closed`, 2026-07-17 — just added the missing front-matter, no content change).

**Next up (resume here after context reset):**
1. **Check if PR #60 merged.** If yes: `git fetch --all && git checkout main && git pull js main` (mandatory post-merge step per `core/operations.md`), then `tools/track-graph-audit.sh` exists on `main` — re-run it to see current findings. If no: it's still awaiting developer merge, don't duplicate the work.
2. **11 tracks still need the front-matter backfill** (13 total flagged minus the 2 done this session). Run `bash $SHMORCH_HOME/tools/track-graph-audit.sh` (needs PR #60 merged first) and work through the `MISSING_FRONTMATTER` list — same pattern as the two done above: read the file, derive `status`/`summary` from actual content, don't guess.
3. The `CLOSED_UNGRADUATED` findings for both closed tracks handled this session are **false positives** (proxy limitation — destination docs integrate the knowledge in prose, don't literally contain the track directory name) — already manually verified both landed correctly. No action needed on those two; don't re-flag.
4. This is docs-only bookkeeping (front-matter backfill) — no VERSION bump, no PR needed for `docs/state/tracks/**` edits, can commit straight to `main`.
