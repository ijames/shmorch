# Observability Strategy

↑ [Architecture](index.md)

> Fill this in before shipping to production. Define what you measure, why it matters, and what tools you use. Three audiences: operations (is it healthy?), product (are users succeeding?), quality (is the output correct?).

---

## Audiences and Questions

| Audience | Question | Example metric |
|---|---|---|
| Operations | Is the pipeline healthy? Where do jobs fail? | Job completion rate, error rate by step |
| Product | Are users completing core flows? Are conversions happening? | Funnel completion rate, search-to-result rate |
| Quality | Is the output meaningful and correct? | Score distribution stability, evidence coverage per app |

---

## Log Event Catalog

Every structured log event emitted by the system. Add a row when a new pipeline step is introduced.

| Event name | When emitted | Key fields |
|---|---|---|
| (none yet — add at each build track) | | |

**Required fields on every event:** `timestamp`, `event_type`, `severity` (info/warn/error), `context` (correlation ID or job ID where applicable).

---

## Metrics

Counters, gauges, and histograms that feed dashboards and alerting. Define SLOs here when the project reaches productionization stage.

| Metric | Type | What it signals | SLO target |
|---|---|---|---|
| (none yet) | | | |

---

## Tooling Decision

- **Dev / proof-sprint:** stdout JSON logs (captured by hosting platform automatically)
- **Prod logging sink:** (decide: CloudWatch / Datadog / Grafana Loki / other)
- **Metrics + dashboards:** (decide: CloudWatch Metrics / Grafana Cloud / Datadog / other)
- **Alerting:** (decide: PagerDuty / OpsGenie / email / Slack webhook)
- **Tracing:** (decide when needed: AWS X-Ray / OpenTelemetry / Datadog APM)
