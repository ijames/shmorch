# Candidate skill directive: every new error log needs a paired watcher

**Status:** Deferred 2026-09-04 — not yet validated as more than a one-project
pattern; revisit if another Shmorch project independently hits the same
caught-exception-invisible-to-alerting failure mode.

**Filed from `darkbadge` 2026-08-26**, via
`docs/inbox/observability-driven-development-error-watchers.md`. Already applied as
a DarkBadge project-local rule in
`docs/technology/development/decisions/process.md` § "Observability-Driven
Development" and as a PR-gate check alongside the five-phase Intent→Behavior→Test→
Code→PR workflow — this inbox item is only about whether the *pattern* should
graduate into Shmorch doctrine, not the DarkBadge-side application (already done).

## Why this might be more than a project-local rule

Developer's framing: "if we have a collection of services interacting with each
other, making sure as soon as there are new features that there are new
first-order monitors is critical." This generalizes past DarkBadge — any project
past `proof-sprint` with multiple services/jobs interacting async (queues,
schedulers, webhooks) has the same failure mode: a caught exception that logs but
doesn't raise is invisible to platform-level error alarms by construction, on any
cloud, not just AWS/CloudWatch.

## Where this might graduate to in the skill

`core/observability.md`'s existing "Build Track Rule" stops at logging: *"What log
events does this feature introduce?"* is the required spec-time question, but
nothing requires a **watcher** per new error-level log event — a track can satisfy
the current rule by just adding a `print`/structured-log call and calling it done.

Candidate addition: extend the Build Track Rule (or add a sibling rule under the
`productionization` stage row, where "Metrics + alerting on SLOs" already lives) so
that any new error-path log event requires a named watcher — tool-agnostic
phrasing, since the concrete mechanism varies by project (CloudWatch Metric Filter
+ Alarm in DarkBadge's case; could be a Datadog monitor, Sentry alert rule, etc.
elsewhere). Possibly framed as a third leg alongside TDD/BDD for the
`productionization`+ stages specifically — "no test, no code" / "no scenario, no
feature" / "no watcher, no error log" — though it likely shouldn't apply at
`R&D`/`proof-sprint` stages where alerting infra doesn't exist yet.

Sharper version, per a same-day follow-up from the developer ("a review of
telemetry should be part of the gate before merging"): this isn't only a sibling to
TDD/BDD in principle, it's a sibling **gate** — `workflows/build.md`'s PR phase
(wherever it currently checks "tests green, spec satisfied") should also check "new
error-path logs have a named watcher" before a PR is considered mergeable, the same
place, not a separate step a developer could skip.

## Not resolved — needs a decision

- Does this belong in `core/observability.md`'s Build Track Rule, a new sibling
  rule under the `productionization` stage row, or both?
- Should `workflows/build.md`'s PR-phase checklist gain this as a hard gate, matching
  how DarkBadge applied it locally?
