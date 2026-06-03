# Observability

Three pillars — every project needs a strategy for all three from day one:

- **Logs** — what happened and why. Structured (JSON), queryable, consistent fields: timestamp, event_type, severity, context. Write explicitly at every meaningful system event.
- **Metrics** — how much, how often, how fast. Counters, gauges, histograms. Drive alerting and SLOs.
- **Traces** — where time was spent. Spans linking a user action through every system hop. Essential for distributed or multi-service systems.

## Stage Expectations

| Stage | Minimum |
|---|---|
| R&D | Print/stdout logs with event names. Enough to replay what happened. |
| proof-sprint | Structured JSON logs at every pipeline step: job start, each external call (scrape/API), job complete/failed. Stdout sink. |
| productionization | Metrics + alerting on SLOs. P95 latency, error rate, job success rate. Dashboard per audience: ops/product/quality. |
| maintenance | Distributed traces for cross-service flows. Alert coverage for all known failure modes. |

## Build Track Rule

Every track that introduces a new pipeline step must answer in its spec: *"What log events does this feature introduce?"* The answer is a required field before implementation begins.

## Template

`docs/architecture/observability.md` — scaffolded by `init` for all projects. Three sections: audiences + questions, log event catalog, tooling decision.

## Interaction with Other Dimensions

Observability and Analytics are distinct: observability answers "is the system healthy?" (infrastructure), analytics answers "is the product delivering value?" (user behaviour). Both are needed at productionization; they share no tooling.

Progressive Delivery and Observability interact: every feature flag flip is a system event that should be logged. Ops toggles (kill switches) must have observability before they're useful — a kill switch you can't monitor is a kill switch you can't trust.
