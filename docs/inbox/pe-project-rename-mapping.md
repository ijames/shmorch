**Status:** Deferred 2026-09-04 — revisit alongside the "Entity resolution isn't handled"
follow-up in `docs/project/plan/pe-pipeline-split-generalization-vs-concrete-track-record.md`,
when that pipeline work is next picked up.

# pe pipeline: document the project-rename-alias mechanism

Filed from `shming.com`, 2026-09-04.

## Gap

`workflows/personal-eval.md` and `agents/roles/pe-summarizer.md` derive project
identity purely from each session transcript's own `cwd` basename
(`tools/session_turns.py:read_meta`, `tools/scan.py:slug`). When a project folder is
renamed or moved (concrete case: `AppAdd/appadd` became `DarkBadge/darkbadge`),
sessions from before the rename keep attributing to the old name, splitting one
project's history across two labels in `sessions/*.md`, `stats.md`, and profile
citations.

## Already applied (in personal-profile, not shmorch — no PR needed there)

`~/.shmorch/personal-profile` is its own separate repo, so this was fixed directly,
same-session, without the branch/PR flow:

- New `project-aliases.yaml` at the repo root: flat `old-basename: new-name` lines.
- `tools/session_turns.py`'s `read_meta()` resolves the folder basename through this
  map (`_resolve_alias`, capped at 5 hops for a rename chain) before returning it as
  `repo` — this feeds both `scan.py`'s slug and the header `pe-summarizer` reads, so
  the fix is a single choke point, not scattered.
- Backfilled the one already-processed session affected (`d6a353e4`): renamed both
  session files, updated its footnote citation and `stats.md` row from `appadd` to
  `darkbadge`. Commit `466ecbf`.

## Suggested shmorch-side change

Nothing in `~/.shmorch/personal-profile` needs a PR (separate repo), but the shmorch
skill's own docs describe this pipeline's mechanics and should mention the alias file
exists, since it's the kind of thing a future session would otherwise rediscover from
scratch:

- `workflows/personal-eval.md` Step 1 (resolve `$PERSONAL_PROFILE_HOME`, check
  backlog) — one line noting `project-aliases.yaml` exists at the profile root and
  should get a new entry whenever a project folder is renamed/moved, so history stays
  attributed to one name.
- Optionally, `agents/roles/pe-summarizer.md`'s Input section — a note that project
  identity is already alias-resolved by the time it sees the `session_turns.py`
  output header, so it shouldn't second-guess a project name that looks unfamiliar.

Low-stakes, doc-only — a `PATCH` version bump per `core/operations.md`.
