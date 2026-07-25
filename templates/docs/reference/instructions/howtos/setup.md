# Setup Guide

> Recreate the full dev environment from scratch.
> Fill in each section as the scaffold is built — this doc is written alongside the code, not after.

↑ parent: [howtos/](index.md)
↔ related: [technology/decisions/](../../../technology/decisions/index.md)

> **Parity rule:** This doc, each component's README, and the code must stay in sync. If a command here is wrong, or a README is missing, run `/shmorch verify` to catch it.

---

## Prerequisites

Install these before anything else.

| Tool | Version used | Install |
|---|---|---|

Verify:
```bash
```

---

## Repository

```bash
git clone <repo-url>
cd <project>
```

---

## Quick start (after all prerequisites installed)

```bash
cp .env.template .env.local   # fill in secrets — see .env.template for where to get each value
```

---

## Configuration and secrets

All environment variables live in one place: `.env.local` at the repo root (gitignored).
`.env.template` documents every variable with comments on where to get values.

| Secret | Local (`.env.local`) | Remote secret store key |
|---|---|---|

To start completely fresh from a clone: follow the Prerequisites section, then each
service's install step in order. Nothing else should be required.

---

## Branching workflow

State files (`docs/project/`) always commit to `main` via Shmorch wrap — never on feature
branches. See `core/git-discipline.md` for the full branch/PR model, and
`docs/project/process/index.md` for any project-specific override.
