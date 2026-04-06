# Stack Inventory

> Keep this updated. It informs every technical decision in this project.
> Before suggesting a new package, upgrade, or pattern — consult this file first.

## Runtime

| Layer | Version | Pinned? | Reason |
|---|---|---|---|
| <!-- e.g. Python --> | <!-- 3.7 --> | <!-- Yes --> | <!-- Heroku runtime.txt constraint --> |

## Key Dependencies

| Package | Version in use | Purpose | Can upgrade? | Notes |
|---|---|---|---|---|
| <!-- package --> | <!-- x.y.z --> | <!-- --> | <!-- Yes / No / Ask --> | <!-- --> |

## External Constraints

> These are things *outside* the codebase that limit what we can use or change.
> Always capture the reason — "we can't upgrade X" is useless; "we can't upgrade X because Y" is actionable.

<!-- Examples:
- Heroku (hobby tier): Python version must match runtime.txt; no persistent disk
- Payment processor API v1: requires requests < 2.28 for TLS compatibility
- Client's server: PHP 7.2 only, no extensions beyond stock
- Angular 1.x: full rewrite required to move to 2+; deferred indefinitely
-->

## Best Practice Notes

> Per-component guidance — what patterns to use, what to avoid, for *this* stack at *these* versions.

<!-- Examples:
- Pyramid: use config.include() for modular setup; avoid mutable global state in views
- Celery 4.x: use task signatures for chaining; .apply_async args must be JSON-serializable
- AngularJS 1.x: use controllerAs syntax; avoid $scope in new code
-->

## Upgrade Opportunities

> Packages that *could* be upgraded when the relevant constraint is lifted.

<!-- Format:
- Package X → v Y.Z: blocked by [constraint]. Unblocked when: [condition].
-->
