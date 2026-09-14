---
name: ecc-latency-critical-systems
description: "Use when p95 latency or data freshness matters \u2014 realtime dashboards, market data, streaming agents, queues, or caches."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/latency-critical-systems/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for latency critical systems; adapted for explicit local scope and evidence-backed use."
---

# Latency Critical Systems — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Latency Critical Systems

Use this skill when the user cares about realtime behavior, hot paths, streaming
freshness, or execution speed. This includes HFT-like infrastructure, but the
skill is engineering-focused. It does not authorize live trading or financial
advice.

## Split The Metrics

Do not collapse everything into "fast." Track:

- p50, p95, and p99 latency;
- throughput;
- freshness age;
- queue depth;
- cache hit rate;
- provider/API response time;
- browser render time;
- correctness under load;
- failure and retry behavior.

## Map The Hot Path

Write the path from user/event to final visible state:

```text
source event -> provider API -> ingest worker -> queue -> cache -> edge route
-> client stream -> browser render -> user-visible state
```

Review supplied measurements for each segment separately; an authorized local fixture may collect missing measurements without external services.

## Optimization Order

1. Remove unnecessary round trips.
2. Cache stable reads with freshness metadata.
3. Batch small calls and writes.
4. Move compute closer to the data or the user.
5. Split hot and cold paths.
6. Apply backpressure before queues grow unbounded.
7. Use streaming only when it improves freshness or user experience.
8. Propose canary conditions for stale data, degraded providers, and bad cache state; instrumentation or deployment is separate authorized work.

## Verification

Request redacted operator-provided readbacks for deployed surfaces; do not contact production or providers:

- HTTP timing and response headers;
- provider freshness timestamp;
- queue or job state;
- edge/cache state;
- browser verification for actual UI freshness;
- logs around retries and degraded mode.

For market-data or execution-adjacent paths, also verify orderbook age, VWAP
assumptions, provider status, and kill-switch behavior before calling the path
ready.

## Guardrails

- Do not optimize latency by dropping required validation.
- Do not hide stale data behind fast cache hits.
- Do not claim millisecond behavior from client labels without measurement.
- Do not run live orders, destructive migrations, or customer-impacting deploys
  without an explicit approval gate.
- Keep secrets and private payloads out of logs and benchmark artifacts.
