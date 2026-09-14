---
name: ecc-cost-aware-llm-pipeline
description: "Use when LLM spend needs to come down, or when routing tasks across model tiers and budgets."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/cost-aware-llm-pipeline/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for cost aware llm pipeline; adapted for explicit local scope and evidence-backed use."
---

# Cost Aware Llm Pipeline — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Cost-Aware LLM Pipeline

Review or design quality-aware model routing, per-attempt cost accounting, bounded retry policy, and provider prompt caching. No API call, paid model run, background job, or telemetry collection is authorized by loading this reference.

## When to Use

- A batch contains tasks of different complexity and has a declared spend ceiling.
- Model routing must balance quality, latency, and cost.
- Retries or repeated prompts are consuming an unexplained budget.

## 1. Route by Measured Task Requirements

Keep model identifiers and prices in caller-supplied configuration. The upstream price table and future model names were not substantiated and are not retained. Read the provider's official current pricing and version documentation when that fact is required; do not infer prices from model names.

```python
from dataclasses import dataclass
from decimal import Decimal

@dataclass
class ModelTier:
    model_id: str
    input_usd_per_million: Decimal
    output_usd_per_million: Decimal

def select_tier(
    text_length: int,
    item_count: int,
    cheap: ModelTier,
    capable: ModelTier,
    *,
    long_text_threshold: int = 10_000,
    many_items_threshold: int = 30,
) -> ModelTier:
    if text_length < 0 or item_count < 0:
        raise ValueError("workload sizes cannot be negative")
    if text_length >= long_text_threshold or item_count >= many_items_threshold:
        return capable
    return cheap
```

The thresholds are illustrative. Compare quality on representative task slices before adopting the router; text length is not a reliable universal complexity measure. A cheaper model is useful only if it meets the same task contract.

## 2. Reserve Cost Before Dispatch

Checking accumulated cost after a response permits the next call to overspend. Reserve a conservative upper bound before every attempt, including retries, output cap, cache write costs, and any tool/provider charges. Use a tokenizer or provider counting API only when separately authorized; an estimate that can undercount is not a hard budget guarantee.

```python
@dataclass
class Budget:
    limit_usd: Decimal
    spent_usd: Decimal = Decimal("0")
    reserved_usd: Decimal = Decimal("0")

    def reserve(self, upper_bound: Decimal) -> None:
        if not upper_bound.is_finite() or upper_bound < 0:
            raise ValueError("reservation must be finite and nonnegative")
        if not self.limit_usd.is_finite() or self.limit_usd < 0:
            raise ValueError("budget must be finite and nonnegative")
        if self.spent_usd + self.reserved_usd + upper_bound > self.limit_usd:
            raise ValueError("budget exhausted before dispatch")
        self.reserved_usd += upper_bound

    def settle(self, reservation: Decimal, actual_usd: Decimal) -> None:
        if not actual_usd.is_finite() or actual_usd < 0:
            raise ValueError("actual charge must be finite and nonnegative")
        if reservation < 0 or reservation > self.reserved_usd:
            raise ValueError("invalid reservation")
        self.reserved_usd -= reservation
        self.spent_usd += actual_usd
        if actual_usd > reservation:
            raise ValueError("provider charge exceeded reserved bound; stop further calls")

def token_cost(tier: ModelTier, input_tokens: int, output_tokens: int) -> Decimal:
    if input_tokens < 0 or output_tokens < 0:
        raise ValueError("token counts cannot be negative")
    prices = (tier.input_usd_per_million, tier.output_usd_per_million)
    if any(not price.is_finite() or price < 0 for price in prices):
        raise ValueError("prices must be finite and nonnegative")
    return (
        Decimal(input_tokens) * tier.input_usd_per_million
        + Decimal(output_tokens) * tier.output_usd_per_million
    ) / Decimal(1_000_000)
```

This budget is a single-owner example, not a concurrent ledger. A concurrent service needs an atomic reservation store and request IDs. Do not release an ambiguous failed request's reservation merely because no response arrived: it may have been billed. Reconcile against authoritative usage before deciding whether to retry.

## 3. Use Narrow, Bounded Retries

Retry only documented transient transport, rate-limit, or server errors, not authentication, schema, validation, or policy failures. Respect `Retry-After`, add jitter, and bound both attempts and elapsed time. Account for SDK retries to avoid multiplicative retry loops.

```python
import random
import time

def call_with_retry(
    operation,
    retryable_errors: tuple[type[Exception], ...],
    *,
    attempts: int = 3,
    deadline_seconds: float = 20.0,
):
    if attempts < 1 or deadline_seconds <= 0:
        raise ValueError("attempts and deadline must be positive")
    deadline = time.monotonic() + deadline_seconds
    for attempt in range(attempts):
        if time.monotonic() >= deadline:
            raise TimeoutError("retry deadline reached")
        try:
            # The supplied operation enforces its own timeout and reserves this attempt.
            return operation(deadline)
        except retryable_errors:
            if attempt + 1 == attempts:
                raise
            delay = min(2 ** attempt + random.random(), 8.0)
            if time.monotonic() + delay >= deadline:
                raise
            time.sleep(delay)
```

The function does not call a provider by itself. Its caller must choose an explicitly authorized operation and documented exception classes. Ambiguous completion and non-idempotent tool effects need reconciliation, not blind retries.

## 4. Understand Provider Prompt Caching

Provider prompt caching usually still sends the prompt; the provider reuses computation for an eligible prefix. Check the exact model's minimum prefix length, cache lifetime, placement API, input/cache-read/cache-write billing, and privacy/retention rules. Do not move trusted system instructions into a user message merely to mark them cacheable.

For a provider with explicit cache-control blocks, keep stable system/tool definitions before variable user content and use its version-matched documented fields. For automatic caching, preserve prefix stability rather than inventing unsupported request fields.

## Composition and Accounting

1. Resolve quality requirements, allowed model IDs, price source, and spend ceiling.
2. Select a tier from evidence-backed routing criteria.
3. Estimate and reserve the maximum charge for the bounded request.
4. Dispatch only under separate caller authorization, with timeouts and bounded retry ownership.
5. Settle authoritative usage; retain reservations for ambiguous attempts.
6. Compare quality, latency, and spend across task slices using supplied metrics.

Return the price/version source, routing decision, spend/reservation totals, retry uncertainty, and quality evidence. Do not capture session learning or send telemetry.

Done when cost and quality tradeoffs are explicit and each proposed attempt has a defensible budget bound; never claim a hard cap from an after-the-fact cost total.

