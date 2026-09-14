---
name: ecc-marketing-campaign
description: End-to-end marketing campaign planning and execution. Covers audience research, positioning, campaign angle definition, landing page copy, email sequences, social posts, ad copy, short-form video scripts, and content calendars. Use as the orchestration layer for multi-channel product launches. Use when planning or executing a multi-channel product launch, or producing landing page, email, social, or ad copy.
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/marketing-campaign/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  adaptation: local-portable-guide
---

# Marketing Campaign

Plan and execute launch campaigns that convert — not just campaigns that ship.

## Local scope and prerequisites

This guide produces a campaign brief, drafts, and a proposed calendar. A calendar is not a scheduled job. Publishing, sending email, placing ads, spending money, or connecting accounts requires a separate user-authorized operation through an available integration. If live audience or competitor sources are unavailable, use supplied evidence and label the research gap. Tool or sibling-skill mentions do not grant permissions.

## When to Activate

- planning a product or feature launch
- building a full content suite from a single product brief
- defining positioning and campaign angle before writing any copy
- orchestrating multiple content types across channels
- reviewing copy for conversion quality and brand consistency

## Non-Negotiables

1. Define positioning before writing any copy. All copy flows from the angle.
2. Research the audience before assuming you know their language or fears.
3. Each deliverable must serve one clear purpose in the campaign arc.
4. Specificity beats adjectives in every format and on every channel.
5. The same voice must run across every channel and every piece.
6. No copy ships without passing the quality gate.

## Campaign Workflow

### Phase 1: Research

Optionally use `ecc-market-research`, or perform the same source-attributed research directly, to:
- profile the target audience (jobs-to-be-done, fears, language, alternatives they use)
- map 3+ direct or adjacent competitors (positioning, gaps, messaging weaknesses)
- identify 1–3 audience insights the campaign angle will exploit

Deliverable: a short research brief (audience profile + competitive summary + key insights).

### Phase 2: Positioning

Produce:
- core benefit statement (one sentence, no feature list, no jargon)
- positioning formula: "[Product] helps [audience] [achieve outcome] by [mechanism]"
- campaign angle: the specific tension, insight, or moment the whole campaign lives in
- tone profile: lock before writing (optionally use `ecc-brand-voice`; otherwise extract sample-backed rhythm, claim style, preferred moves, and banned moves into a reusable `VOICE PROFILE`)

Do not write any copy until positioning and angle are approved.

### Phase 3: Content Production

Produce in this order — each layer informs the next:

1. **Landing page copy** (all sections: hero, problem, solution, features, how it works, proof, CTA)
2. **Email sequence** (each email has one purpose; follow the arc: problem → education → agitation → solution → proof → urgency → final CTA)
3. **Social posts** (optionally use `ecc-content-engine`; otherwise adapt the strongest source claims to each platform's format and context needs — LinkedIn and X are not the same copy resized)
4. **Short-form video scripts** (timestamp-blocked; written for screen and ear, not the page)
5. **Ad copy variants** (3–4 variants testing different angles or audience segments)
6. **Content calendar** (day-by-day schedule with channel, type, timing, and dependencies)

### Phase 4: Review

Gate every deliverable:
- 5-second test on all hero / above-fold copy (clear who it's for, what it does, why act now)
- CTA audit (one per piece, specific, earned — not demanded)
- Tone consistency check across all channels
- Claim audit (every claim is specific and supportable)
- Cross-channel consistency (ad claims match landing page; email body matches subject)

## Output Contract

A full campaign delivers:

1. **Positioning brief** — angle, core benefit statement, tone profile
2. **Landing page copy** — hero, problem, solution, features, how it works, proof, CTA
3. **Email sequence** — subject + preview + body + CTA for each email, labelled by day and purpose
4. **LinkedIn posts** — 3+ platform-native posts with distinct angles
5. **X posts** — 5+ standalone posts + 1 thread
6. **Short-form video scripts** — 2+ timestamp-blocked scripts with visual direction notes
7. **Ad copy variants** — short headline / long headline / body per variant
8. **Content calendar** — day-by-day schedule with channel, content type, timing, and dependencies
9. **Copy review summary** — flagged issues and open questions before anything goes live

## Quality Gate

Before delivering any piece:

- every deliverable sounds like the same author
- no hollow superlatives or filler adjectives remain
- every CTA is specific and earned (never "learn more" or "click here")
- no copy is duplicated verbatim across platforms
- hero copy passes the 5-second test
- email subjects match email body (no bait-and-switch)
- ad claims match landing page claims exactly
- no copy would work unchanged for any other product in the category

## Hard Bans

Delete and rewrite any:

- "game-changing", "revolutionary", "world-class", "cutting-edge"
- "In today's competitive landscape"
- fake urgency not backed by a real deadline
- hollow social proof without specifics ("thousands trust us")
- generic CTAs ("learn more", "find out more", "click here")
- copy that could be unplugged and dropped into a competitor's campaign unchanged

## Related Skills

- `ecc-brand-voice` — optional source-derived voice capture; the Phase 2 profile is the fallback
- `ecc-content-engine` — optional platform-native production; follow Phase 3 without it
- `ecc-crosspost` — optional distribution variants; write distinct native drafts and flag unresolved publishing constraints without it
- `ecc-market-research` — optional audience and competitive intelligence; follow Phase 1 with source attribution without it
- `ecc-seo` — optional landing-page optimisation; otherwise check search intent, title, description, headings, and truthful claims against the actual page

## Attribution

Adapted from ECC by Affaan Mustafa, revision `e04ea0b9cc8248686edf5ac751cadff550e162b8`. MIT license; see `LICENSE` in this directory. Local adaptations namespace optional references and distinguish campaign artifacts from external execution; no effectiveness or live-integration claim is made.
