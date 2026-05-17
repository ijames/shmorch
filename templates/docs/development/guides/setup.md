# AppAddict — Setup Guide

> Recreate the full dev environment from scratch.
> Fill in each section as the scaffold is built — this doc is written alongside the code, not after.

↑ parent: [docs/index.md](../index.md)
↔ related: [Decisions](decisions.md), [System Components](../architecture/system-components.md)

> **Parity rule:** This doc, each component's README, the Gherkin scenarios, and the code must stay in sync. If a command here is wrong, or a README is missing, run `/shmorch verify` to catch it. See [decisions.md — 2026-05-01](decisions.md) for rationale.

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
cd appadd
```

### GitHub settings (one-time)

- Settings → General → **Automatically delete head branches** ✓
  Branches are deleted on the remote automatically when a PR merges.
  Locally after pulling main: `git branch -d <branch-name>`

---

## Quick start (after all prerequisites installed)

```bash
cp .env.template .env.local   # fill in secrets — see .env.template for where to get each value
```

Individual services:
```bash
```

---

## Configuration and secrets

All environment variables live in one place: `.env.local` at the repo root (gitignored).
`.env.template` documents every variable with comments on where to get values.

| Where | Who reads it | How |
|---|---|---|
| `.env.local` | Makefile + overmind | `make` exports all vars to child processes; `Procfile.dev` reads them |

Local dev never needs Parameter Store — set vars in `.env.local` and `make dev` handles the rest.

| Secret | Local (`.env.local`) | Parameter Store key (Lambda) |
|---|---|---|

To start completely fresh from a clone: follow the Prerequisites section, then each service's install step in order. Nothing else should be required.

---

## Branching workflow

State files (`docs/state/`, `docs/development/decisions.md`, `docs/state/timelog.md`) always commit to `main` via Shmorch wrap — never on feature branches.

Feature branches own: `app/`, `infra/`, `db/`, `tests/`, `docs/architecture/`, `docs/development/` (except decisions.md).

```bash
git checkout -b feature/<name>   # start work
# ... build, commit ...
# open PR → merge → branch auto-deleted on GitHub
git checkout main && git pull
git branch -d feature/<name>     # clean up locally
```
