---
name: ecc-mle-workflow
description: "Use when building, reviewing, or hardening ML systems beyond one-off notebooks."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/mle-workflow/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for mle workflow; adapted for explicit local scope and evidence-backed use."
---

# Mle Workflow — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Machine Learning Engineering Workflow

Use this skill to turn model work into a production ML system with clear data contracts, repeatable training, measurable quality gates, deployable artifacts, and operational monitoring.

## When to Activate

- Planning or reviewing a production ML feature, model refresh, ranking system, recommender, classifier, embedding workflow, or forecasting pipeline
- Converting notebook code into a reusable training, evaluation, batch inference, or online inference pipeline
- Designing model promotion criteria, offline/online evals, experiment tracking, or rollback paths
- Debugging failures caused by data drift, label leakage, stale features, artifact mismatch, or inconsistent training and serving logic
- Adding model monitoring, canary rollout, shadow traffic, or post-deploy quality checks

## Scope Calibration

Use only the lanes that fit the system in front of you. This skill is useful for ranking, search, recommendations, classifiers, forecasting, embeddings, LLM workflows, anomaly detection, and batch analytics, but it should not force one architecture onto all of them.

- Do not assume every model has supervised labels, online serving, a feature store, PyTorch, GPUs, human review, A/B tests, or real-time feedback.
- Do not add heavyweight MLOps machinery when a data contract, baseline, eval script, and rollback note would make the change reviewable.
- Do make assumptions explicit when the project lacks labels, delayed outcomes, slice definitions, production traffic, or monitoring ownership.
- Treat examples as interchangeable scaffolds. Replace metrics, serving mode, data stores, and rollout mechanics with the project-native equivalents.

## Optional Technical Guidance

- `ecc-python-patterns` (optional skill; if unavailable, follow the project Python typing, ownership, and error-handling conventions).
- `ecc-python-testing` (optional skill; if unavailable, use existing isolated Python tests for observable failures and boundaries).
- `ecc-pytorch-patterns` (optional skill; if unavailable, trace tensor shapes, device placement, autograd, data loading, and checkpoint state).
- `ecc-ai-regression-testing` (optional skill; if unavailable, identify realistic failures and compare all affected execution paths with isolated fixtures).
- `ecc-clickhouse-io` (optional skill; if unavailable, review ordering keys, aggregation states, batching, and data accounting).
- `ecc-docker-patterns` (optional skill; if unavailable, inspect image stages, least privilege, network exposure, and persistent volumes).
- `ecc-cost-aware-llm-pipeline` (optional skill; if unavailable, review quality-aware routing, per-attempt cost reservation, and bounded retries).

No installation profile, agent chain, learning system, or harness command is required.

## Ten MLE Review Scenarios

| Scenario | Concrete contract/evidence |
| --- | --- |
| Frame a prediction or ranking capability | Decision owner, mistake cost, acceptable error, baseline and first experiment |
| Define labels and sources | Entity grain, timestamps, confidence, point-in-time joins, split and snapshot |
| Establish a baseline | Scorer contract, confusion matrix, calibration, latency/cost and determinism |
| Generate features | Signal hypothesis, missing/outlier policy, leakage checks and train/serve equivalence |
| Tune thresholds | Precision/recall/calibration and slice tradeoffs without tuning against final test data |
| Analyze errors | Distinguish false positives/negatives, labels, freshness, missing signals and system bugs |
| Package an artifact | Preprocessing, config, schema, versions, safe loading and dependency constraints |
| Serve predictions | Timeout, batching, fallback, model identity and user-visible consequences |
| Plan a rollout | Shadow/canary evidence, traffic bounds, guardrails, previous artifact and rollback trigger |
| Operate or refresh a model | Drift/delayed-label evidence, alert ownership, runbook gaps and retrain criteria |

These scenarios guide the requested work; they are not authorization to train, capture feedback, publish, deploy, or operate a service.

## Iteration Compact

Before touching model code, compress the work into one reviewable artifact. This should be short enough to fit in a PR description and precise enough that another engineer can challenge the tradeoffs.

```text
Goal:
Who cares:
Decision owner:
User or system action changed by the model:
Success metric:
Guardrail metrics:
Mistake budget:
Unacceptable mistakes:
Acceptable mistakes:
Assumptions:
Constraints:
Labels and data snapshot:
Baseline:
Candidate signals:
Threshold or config plan:
Eval slices:
Known risks:
Next experiment:
Rollback or fallback:
```

This compact is the MLE equivalent of a strong SWE design note. It keeps the team from optimizing a metric no one trusts, adding features that do not address the real error mode, or shipping complexity without a rollback.

## Decision Brain

Use this loop whenever the task is ambiguous, high-impact, or metric-heavy:

1. Start from the decision, not the model. Name the action that changes downstream behavior.
2. Name who cares and why. Different stakeholders pay different costs for false positives, false negatives, latency, compute spend, opacity, or missed opportunities.
3. Convert ambiguity into hypotheses. Ask what signal would separate outcomes, what evidence would disprove it, and what simple baseline should be hard to beat.
4. Research prior art or a nearby known problem before inventing a bespoke system.
5. Score choices with `(probability, confidence) x (cost, severity, importance, impact)`.
6. Consider adversarial behavior, incentives, selective disclosure, distribution shift, and feedback loops.
7. Prefer the simplest change that reduces the most important mistake. Simplicity is not laziness; it is a way to minimize blunders while preserving iteration speed.
8. Capture the decision, evidence, counterargument, and next reversible step.

## Metric and Mistake Economics

Choose metrics from failure costs, not habit:

- Use a confusion matrix early so the team can discuss concrete false positives and false negatives instead of abstract accuracy.
- Favor precision when the cost of an incorrect positive decision dominates.
- Favor recall when the cost of a missed positive dominates.
- Use F1 only when the precision/recall tradeoff is genuinely balanced and explainable.
- Use AUC or ranking metrics when ordering quality matters more than a single threshold.
- Track latency, throughput, memory, and cost as first-class metrics because they shape feasible model complexity.
- Compare against a baseline and the current production model before celebrating an offline gain.
- Treat real-world feedback signals as delayed labels with bias, lag, and coverage gaps; do not treat them as ground truth without analysis.

Every metric choice should state which mistake it makes cheaper, which mistake it makes more likely, and who absorbs that cost.

## Data and Feature Hypotheses

Features should come from a theory of separation:

- Text, categorical fields, numeric histories, graph relationships, recency, frequency, and aggregates are candidate signal families, not automatic features.
- For every feature family, state why it should separate outcomes and how it could leak future information.
- For noisy labels, consider adjudication, label confidence, soft targets, or confidence weighting.
- For class imbalance, compare weighted loss, resampling, threshold movement, and calibrated decision rules.
- For missing values, decide whether absence is informative, imputable, or a reason to abstain.
- For outliers, decide whether to clip, bucket, investigate, or preserve them as rare but important signal.
- For correlated features, check whether they are redundant, unstable, or proxies for unavailable future state.

Do not add model complexity until error analysis shows that the baseline is failing for a reason additional signal or capacity can plausibly fix.

## Error Analysis Loop

After each baseline, training run, threshold change, or config change:

1. Split mistakes into false positives, false negatives, abstentions, low-confidence cases, and system failures.
2. Cluster errors by shared traits: language, entity type, source, time, geography, device, sparsity, recency, feature freshness, label source, or model version.
3. Separate model mistakes from data bugs, label ambiguity, product ambiguity, instrumentation gaps, and serving mismatches.
4. Trace each major cluster to one of four moves: better labels, better features, better threshold/config, or better product fallback.
5. Preserve every important mistake as a regression test, eval slice, dashboard panel, or runbook entry.
6. Write the next iteration as a falsifiable experiment, not a vague "improve model" task.

The strongest MLE loop is not train -> metric -> ship. It is mistake -> cluster -> hypothesis -> experiment -> evidence -> simpler system.



## Core Workflow

### 1. Define the Prediction Contract

Capture the product-level contract before writing model code:

- Prediction target and decision owner
- Input entity, output schema, confidence/calibration fields, and allowed latency
- Batch, online, streaming, or hybrid serving mode
- Fallback behavior when the model, feature store, or dependency is unavailable
- Human review or override path for high-impact decisions
- Privacy, retention, and audit requirements for inputs, predictions, and labels

Do not accept "improve the model" as a requirement. Tie the model to an observable product behavior and a measurable acceptance gate.

### 2. Lock the Data Contract

Every ML task needs an explicit data contract:

- Entity grain and primary key
- Label definition, label timestamp, and label availability delay
- Feature timestamp, freshness SLA, and point-in-time join rules
- Train, validation, test, and backtest split policy
- Required columns, allowed nulls, ranges, categories, and units
- PII or sensitive fields that must not enter training artifacts or logs
- Dataset version or snapshot ID for reproducibility

Guard against leakage first. If a feature is not available at prediction time, or is joined using future information, remove it or move it to an analysis-only path.

### 3. Build a Reproducible Pipeline

Training code should be runnable by another engineer without hidden notebook state:

- Use typed config files or dataclasses for all hyperparameters and paths
- Pin package and model dependencies
- Set random seeds and document any nondeterministic GPU behavior
- Record dataset version, code SHA, config hash, metrics, and artifact URI
- Save preprocessing logic with the model artifact, not separately in a notebook
- Keep train, eval, and inference transformations shared or generated from one source
- Make every step idempotent so retries do not corrupt artifacts or metrics

Keep ownership explicit and transformations deterministic. Avoid unintended mutation of shared data frames or global configuration; choose mutable or immutable local structures according to the pipeline contract.

```python
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class TrainingConfig:
    dataset_snapshot: str  # Immutable dataset identity, not only a mutable URI.
    model_dir: Path
    seed: int
    learning_rate: float
    batch_size: int


def artifact_name(config: TrainingConfig, code_sha: str) -> str:
    config_key = json.dumps({"dataset_snapshot": config.dataset_snapshot, "seed": config.seed, "learning_rate": config.learning_rate, "batch_size": config.batch_size}, sort_keys=True, allow_nan=False)
    config_hash = hashlib.sha256(config_key.encode("utf-8")).hexdigest()[:12]
    return f"{code_sha[:12]}-{config_hash}"
```

### 4. Evaluate Before Promotion

Promotion criteria should be declared before training finishes:

- Baseline model and current production model comparison
- Primary metric aligned to product behavior
- Guardrail metrics for latency, calibration, fairness slices, cost, and error concentration
- Slice metrics for important cohorts, geographies, devices, languages, or data sources
- Confidence intervals or repeated-run variance when metrics are noisy
- Failure examples reviewed by a human for high-impact models
- Explicit "do not ship" thresholds

```python
import math

# Illustrative thresholds; use the declared task-owner gate contract.
PROMOTION_GATES = {
    "auc": ("min", 0.82),
    "calibration_error": ("max", 0.04),
    "p95_latency_ms": ("max", 80),
}


def assert_promotion_ready(metrics: dict[str, float]) -> None:
    missing = sorted(name for name in PROMOTION_GATES if name not in metrics)
    if missing:
        raise ValueError(f"Model promotion metrics missing required gates: {missing}")

    failures = {
        name: value
        for name, (direction, threshold) in PROMOTION_GATES.items()
        for value in [metrics[name]]
        if not math.isfinite(value)
        or (direction == "min" and value < threshold)
        or (direction == "max" and value > threshold)
    }
    if failures:
        raise ValueError(f"Model failed promotion gates: {failures}")
```

Use offline metrics as gates, not guarantees. When the model changes product behavior, plan shadow evaluation, canary rollout, or A/B testing before full rollout.

### 5. Package for Serving

A testable serving contract is necessary but not sufficient for a production-readiness decision. Review:

- Model artifact includes version, training data reference, config, and preprocessing
- Input schema rejects invalid, stale, or out-of-range features
- Output schema includes model version and confidence or explanation fields when useful
- Serving path has timeout, batching, resource limits, and fallback behavior
- CPU/GPU requirements are explicit and tested
- Prediction logs avoid PII and include enough identifiers for debugging and label joins
- Integration tests cover missing features, stale features, bad types, empty batches, and fallback path

Never let training-only feature code diverge from serving feature code without a test that proves equivalence.

### 6. Operate the Model

Model monitoring needs both system and quality signals:

- Availability, error rate, timeout rate, queue depth, and p50/p95/p99 latency
- Feature null rate, range drift, categorical drift, and freshness drift
- Prediction distribution drift and confidence distribution drift
- Label arrival health and delayed quality metrics
- Business KPI guardrails and rollback triggers
- Per-version dashboards for canaries and rollbacks

Every deployment should have a rollback plan that names the previous artifact, config, data dependency, and traffic-switch mechanism.

## Review Checklist

- [ ] Prediction contract is explicit and testable
- [ ] Data contract defines entity grain, label timing, feature timing, and snapshot/version
- [ ] Leakage risks were checked against prediction-time availability
- [ ] Training is reproducible from code, config, data version, and seed
- [ ] Metrics compare against baseline and current production model
- [ ] Slice metrics and guardrails are included for high-risk cohorts
- [ ] Promotion gates are automated and fail closed
- [ ] Training and serving transformations are shared or equivalence-tested
- [ ] Model artifact carries version, config, dataset reference, and preprocessing
- [ ] Serving path validates inputs and has timeout, fallback, and rollback behavior
- [ ] Monitoring covers system health, feature drift, prediction drift, and delayed labels
- [ ] Sensitive data is excluded from artifacts, logs, prompts, and examples

## Anti-Patterns

- Notebook state is required to reproduce the model
- Random split leaks future data into validation or test sets
- Feature joins ignore event time and label availability
- Offline metric improves while important slices regress
- Thresholds are tuned on the test set repeatedly
- Training preprocessing is copied manually into serving code
- Model version is missing from prediction logs
- Monitoring only checks service uptime, not data or prediction quality
- Rollback requires retraining instead of switching to a known-good artifact

## Output Expectations

When using this skill, return concrete artifacts: data contract, promotion gates, pipeline steps, test plan, deployment plan, or review findings. Call out unknowns that block production readiness instead of filling them with assumptions.
