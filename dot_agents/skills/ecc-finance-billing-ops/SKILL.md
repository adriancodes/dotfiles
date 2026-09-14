---
name: ecc-finance-billing-ops
description: Evidence-first revenue, pricing, refunds, team-billing, and billing-model truth workflow. Use when the user wants a sales snapshot, pricing comparison, duplicate-charge diagnosis, or code-backed billing reality instead of generic payments advice.
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/finance-billing-ops/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  adaptation: local-portable-guide
---

# Finance Billing Ops

Use this when the user wants to understand money, pricing, refunds, team-seat logic, or whether the product actually behaves the way the website and sales copy imply.

This is broader than `ecc-customer-billing-ops`. That optional guide is for customer remediation. This skill is for operator truth: revenue state, pricing decisions, team billing, and code-backed billing behavior. Without the companion, classify customer incidents using Step 2 and return a proposed remedy without changing billing state.

## Portable Guide Scope and Prerequisites

This instruction-only import installs no billing connector, service, account connection, credentials, settings, agents, hooks, or schedules. Instructions neither grant permissions nor enforce them; the user's authorized scope and the active harness controls determine permitted actions.

Live financial evidence requires an already-authorized billing surface such as Stripe in the correct account and test/live environment. Code-backed claims require access to the actual checkout and entitlement code and, where relevant, deployment/version evidence. Current pricing comparisons require accessible current sources. If any are missing, use supplied snapshots with timestamps and identify the unavailable evidence; never fabricate sales, successful payments, or product behavior.

Default to requested read, analysis, and recommendation work. Refunds, cancellations, charges, subscription/seat changes, portal creation, issue creation, customer sends, and live checkout tests are separate external actions requiring specific authorization. Do not inspect credentials, connect services, or initiate real financial transactions to verify a recommendation. Report recommendations separately from completed operations. This workflow is operational evidence gathering, not tax, legal, accounting, or investment advice.

## Optional Skill Stack

Use these guides when available; otherwise perform the inline scope described here:

- `ecc-customer-billing-ops` for customer-specific remediation; otherwise identify the customer, classify the incident, and draft a proposed remedy and follow-up
- `ecc-deep-research` for current competitor evidence; otherwise read current primary pricing sources, cite dates and terms, and flag gaps. The upstream `research-ops` companion is not required or installed
- `ecc-market-research` for a pricing recommendation; otherwise compare like-for-like billing units and terms, separate facts from assumptions, and explain the decision
- The upstream `github-ops` companion is optional and not installed; inspect already-accessible code, backlog, and release records directly without changing them
- The upstream `verification-loop` companion is optional and not installed; trace the checkout-to-entitlement path and use existing safe test evidence or separately authorized sandbox verification. If runtime evidence is unavailable, label that limitation instead of claiming behavior is proven

## When to Use

- user asks for Stripe sales, refunds, MRR, or recent customer activity
- user asks whether team billing, per-seat billing, or quota stacking is real in code
- user wants competitor pricing comparisons or pricing-model benchmarks
- the question mixes revenue facts with product implementation truth

## Guardrails

- distinguish live data from saved snapshots
- separate:
  - revenue fact
  - customer impact
  - code-backed product truth
  - recommendation
- do not say "per seat" unless the actual entitlement path enforces it
- do not assume duplicate subscriptions imply duplicate value
- avoid exposing secret keys, full card details, or unnecessary customer PII

## Workflow

### 1. Start from the freshest billing evidence

Prefer live billing data when authorized and available. If the data is not live, state the snapshot timestamp explicitly.

Normalize the picture:

- paid sales
- active subscriptions
- failed or incomplete checkouts
- refunds
- disputes
- duplicate subscriptions

### 2. Separate customer incidents from product truth

If the question is customer-specific, classify first:

- duplicate checkout
- real team intent
- broken self-serve controls
- unmet product value
- failed payment or incomplete setup

Then separate that from the broader product question:

- does team billing really exist?
- are seats actually counted?
- does checkout quantity change entitlement?
- does the site overstate current behavior?

### 3. Inspect code-backed billing behavior

If the answer depends on implementation truth, inspect the code path:

- checkout
- pricing page
- entitlement calculation
- seat or quota handling
- installation vs user usage logic
- billing portal or self-serve management support

Distinguish what the inspected revision implements from behavior observed in the deployed product.

### 4. End with a decision and product gap

Report:

- sales snapshot
- issue diagnosis
- product truth
- recommended operator action
- product or backlog gap

## Output Format

```text
SNAPSHOT
- timestamp and live-data or saved-snapshot status
- revenue / subscriptions / anomalies

CUSTOMER IMPACT
- who is affected
- what happened

PRODUCT TRUTH
- what the inspected code actually does
- what the website or sales copy claims
- runtime evidence or verification gap

DECISION
- recommended refund / preserve / convert / no-op
- any separately authorized action actually taken and its evidence

PRODUCT GAP
- exact follow-up item to build or fix
```

## Pitfalls

- do not conflate failed attempts with net revenue
- do not infer team billing from marketing language alone
- do not compare competitor pricing from memory when current evidence is available
- do not jump from diagnosis straight to refund without classifying the issue

## Verification

- the answer includes a live-data statement or snapshot timestamp
- product-truth claims are code-backed, with runtime claims distinguished
- customer-impact and broader pricing/product conclusions are separated cleanly
- financial recommendations are not reported as executed transactions

## Attribution

Adapted from ECC by Affaan Mustafa, revision `e04ea0b9cc8248686edf5ac751cadff550e162b8`. MIT license; see `LICENSE` in this directory. Local adaptations namespace optional references and clarify evidence, financial limitations, prerequisites, and mutation boundaries. Live integrations, effectiveness, and routing have not been verified.
