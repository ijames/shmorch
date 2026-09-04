# Candidate doctrine addition: flag dependency chains

**Status:** Deferred 2026-09-04 — DarkBadge's own case already resolved via
PostHog's native dependency support; no urgent driver for app-code doctrine.
Revisit if a project on a flag service without native dependency support hits
this failure mode.

**Filed from `darkbadge` 2026-08-04**, via
`docs/inbox/feature-flag-dependency-chains.md`. DarkBadge's own concrete case is
resolved — PostHog turned out to support flag dependencies natively
(https://posthog.com/docs/feature-flags/dependencies), so no app-code
`dependsOn`/fail-closed layer was needed there. This inbox item is only about
whether `core/progressive_delivery.md` should gain doctrine for projects on a flag
service that *doesn't* support dependencies natively.

## What surfaced it

A PR review found a real failure mode: three flags forming a dependency chain
(`app-tile-alternatives-link` ← `alternatives-live-query` ← `activity-link-auto-chain`),
each only safe to enable once its prerequisite was verified live. Nothing in
`progressive_delivery.md`'s current doctrine — Toggle Types, Scale Ladder — guards
against an operator flipping the leaf flag on while its prerequisite is off.

## Two mechanisms worth documenting as valid (project chooses per case)

1. **Fail-closed gating** (recommended default): a flag with `dependsOn: [...]`
   evaluates to off whenever it's individually on but any dependency is off.
   Matches the existing "Dark Default Rule" (absence means dark) — cheap, no
   cross-flag writes, no new infrastructure. This is what a service without native
   dependency support (like a bare in-app boolean-flag setup) would need in its own
   flag-resolution layer.
2. **Cascading activation**: turning a flag on programmatically flips its
   dependencies on too. Needs real automation (calling the flag service's API to
   mutate *other* flags' rollout state on a webhook/event) — meaningfully more
   infrastructure than option 1. Should only be reached for if fail-closed gating
   proves too passive in practice.

## Not resolved — needs a decision

- Should `core/progressive_delivery.md`'s Toggle Types / Scale Ladder sections gain
  a "Dependency Chains" section covering both mechanisms above?
- Should the doctrine note that some flag services (PostHog, confirmed) solve this
  natively, so the app-code mechanisms above are a fallback for services that
  don't — not a universal requirement?
