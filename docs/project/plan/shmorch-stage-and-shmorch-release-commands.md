---
status: open
category: Features
---

↑ [Plan](index.md)

**`/shmorch stage` and `/shmorch release` commands** — formalise the RC → release flow with built-in semver rules. `stage` tags `dev` as `vX.Y.Z-rc.N` (version bump from Conventional Commits since last tag); `release` merges RC to `main`, tags final version, confirms deploy pipeline fired. Surfaced from MoBoS first release 2026-06-09.
