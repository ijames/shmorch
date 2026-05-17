# Guides

Operational — task-oriented docs for deploying, configuring, and contributing to MoBoS.

↑ [docs/index.md](../index.md)

---

## Deployment

- **[Deploy Setup](../infrastructure/deploy-setup.md)** — topology, GitHub Actions CI/CD pipeline, staged deploy (dev → staging → prod), SSH forced-command security model

## Testing

```bash
php -d include_path=htdocs:htdocs/service htdocs/vendor/bin/phpunit htdocs/tests/
```

Gherkin (Behat) scenarios also run in CI. See `.github/workflows/ci.yml`.

## Configuration

Four TOML configs — one per host. Config keys documented in [reference/](../reference/index.md).

**Config sync risk:** `[trading]` and `[services.schwab.api]` sections must be identical across all 4 TOML configs.

| Host | Config |
|------|--------|
| DreamHost / trentmo | `htdocs/config/trentmo_schwab.toml` |
| DreamHost / mobos | `htdocs/config/mobos_schwab.toml` |
| AWS / jaws | `htdocs/config/jaws_schwab.toml` |
| AWS / mobaws | `htdocs/config/mobaws_schwab.toml` |
