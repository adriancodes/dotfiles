---
name: ecc-product-lens
description: Use this skill to validate the "why" before building, run product diagnostics, and pressure-test product direction before the request becomes an implementation contract.
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/product-lens/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  adaptation: local-portable-guide
---

# Product Lens — Think Before You Build

This lane owns product diagnosis, not implementation-ready specification writing.

If the user needs a durable PRD-to-SRS or capability-contract artifact, optionally use `ecc-product-capability`; otherwise record actors, states, interfaces, invariants, non-goals, and unresolved decisions in the project's existing specification format.

## Local scope and prerequisites

This guide diagnoses product direction; installation does not start weekly reviews, monitoring, or an implementation. Use project evidence and supplied usage, retention, and revenue data; code or a pricing page is not proof of traction. Label unavailable metrics and inferred scores. Save the brief in the user-requested workspace. Running onboarding, installing software, opening a browser session, or connecting a service requires separate task authorization and available tooling; without it, review supplied journey evidence and state that the journey was not exercised.

## When to Use

- Before starting any feature — validate the "why"
- Weekly product review — are we building the right thing?
- When stuck choosing between features
- Before a launch — sanity check the user journey
- When converting a vague idea into a product brief before engineering planning starts

## How It Works

### Mode 1: Product Diagnostic

Like YC office hours but automated. Asks the hard questions:

```
1. Who is this for? (specific person, not "developers")
2. What's the pain? (quantify: how often, how bad, what do they do today?)
3. Why now? (what changed that makes this possible/necessary?)
4. What's the 10-star version? (if money/time were unlimited)
5. What's the MVP? (smallest thing that proves the thesis)
6. What's the anti-goal? (what are you explicitly NOT building?)
7. How do you know it's working? (metric, not vibes)
```

Output: a `PRODUCT-BRIEF.md` with answers, risks, and a go/no-go recommendation.

If the result is "yes, build this," the next step is an explicit capability contract, optionally using `ecc-product-capability`, rather than another product-diagnosis pass.

### Mode 2: Founder Review

Reviews your current project through a founder lens:

```
1. Read README, project instructions (such as AGENTS.md or CLAUDE.md), package/dependency manifest, recent commits
2. Infer: what is this trying to be?
3. Score: product-market fit signals (0-10)
   - Usage growth trajectory
   - Retention indicators (repeat contributors, return users)
   - Revenue signals (pricing page, billing code, Stripe integration)
   - Competitive moat (what's hard to copy?)
4. Identify: the one thing that would 10x this
5. Flag: things you're building that don't matter
```

### Mode 3: User Journey Audit

Maps the actual user experience:

```
1. With user authorization and available tooling, exercise the product as a new user; clone/install only if that operation is in scope
2. Document every friction point (confusing steps, errors, missing docs)
3. Time each step
4. Compare to competitor onboarding
5. Score: time-to-value (how long until the user gets their first win?)
6. Recommend: top 3 fixes for onboarding
```

### Mode 4: Feature Prioritization

When you have 10 ideas and need to pick 2:

```
1. List all candidate features
2. Score each on: impact (1-5) × confidence (1-5) ÷ effort (1-5)
3. Rank by ICE score
4. Apply constraints: runway, team size, dependencies
5. Output: prioritized roadmap with rationale
```

## Output

All modes output actionable docs, not essays. Every recommendation has a specific next step.

## Integration

Optional follow-on work, not installed services or required companions:
- Verify journey findings with an available browser/manual walkthrough; without runtime access, report unverified steps.
- Assess visual polish against the project's design system; without a specialist, inspect hierarchy, spacing, contrast, and consistency directly.
- Review supplied post-launch monitoring evidence; if none exists, report the gap rather than starting a watcher or scheduling a job.
- Use `ecc-product-capability` for an implementation-ready plan, or capture actors, states, interfaces, invariants, non-goals, and open decisions directly.

## Attribution

Adapted from ECC by Affaan Mustafa, revision `e04ea0b9cc8248686edf5ac751cadff550e162b8`. MIT license; see `LICENSE` in this directory. Local adaptations replace harness commands with optional capability-based handoffs and clarify evidence and execution prerequisites; no effectiveness or live-integration claim is made.
