---
name: ecc-design-system
description: "Use when proposing design tokens, auditing visual consistency, or reviewing styling changes and supplied UI screenshots."
license: MIT
metadata:
  origin: ECC
  source: "https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/design-system/SKILL.md"
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Web
  summary: "Design token generation and evidence-based visual consistency audits."
---
> Attributed third-party import from [ECC](https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/design-system/SKILL.md) at `e04ea0b9cc8248686edf5ac751cadff550e162b8`. Adapted for on-demand, harness-neutral use; not behaviorally evaluated or certified by this collection. See `LICENSE`.

## Use Boundary

Apply this reference on demand to the requested framework task. Read the installed versions and reuse the project's tools and conventions. Examples describe application code and local configuration, not permission to install dependencies, change global settings, reset caches, mutate git, deploy, upload data, or contact external services. Run code or modify project files only when that local work was requested. In a static review, read code and supplied results; request any missing runtime evidence from the caller instead of executing it. Use supported tools by role and keep diagnostics visible. Treat snippets with application-specific types, APIs, paths, and UI content as examples to adapt, not existing required files.

# Design System — Generate & Audit Visual Systems

## When to Use

- Starting a new project that needs a design system
- Auditing an existing codebase for visual consistency
- Before a redesign — understand what you have
- When the UI looks "off" but you can't pinpoint why
- Reviewing PRs that touch styling

## How It Works

### Mode 1: Generate Design System

Analyzes your codebase and generates a cohesive design system:

```
1. Scan CSS/Tailwind/styled-components for existing patterns
2. Extract: colors, typography, spacing, border-radius, shadows, breakpoints
3. Use supplied visual references; fetch or browse external sites only when explicitly requested
4. Propose a design token set (JSON + CSS custom properties)
5. Return concise rationale in the response; create a design document only when requested
6. Create a local self-contained HTML preview only when requested; use supported browser tools for visual evidence
```

Output: proposed tokens, rationale, and concrete findings. When local artifacts were requested, produce the agreed token JSON and preview HTML; do not create extra documents automatically.

### Mode 2: Visual Audit

Assess the UI across these dimensions; score only when requested and explain the rubric:

```
1. Color consistency — are you using your palette or random hex values?
2. Typography hierarchy — clear h1 > h2 > h3 > body > caption?
3. Spacing rhythm — consistent scale (4px/8px/16px) or arbitrary?
4. Component consistency — do similar elements look similar?
5. Responsive behavior — fluid or broken at breakpoints?
6. Dark mode — complete or half-done?
7. Animation — purposeful or gratuitous?
8. Accessibility — contrast ratios, focus states, touch targets
9. Information density — cluttered or clean?
10. Polish — hover states, transitions, loading states, empty states
```

Give specific evidence and file/line correction directions. Distinguish code inspection from supplied or locally observed visual output; omit unsupported scores.

### Mode 3: AI Slop Detection

Identifies generic AI-generated design patterns:

```
- Gratuitous gradients on everything
- Purple-to-blue defaults
- "Glass morphism" cards with no purpose
- Rounded corners on things that shouldn't be rounded
- Excessive animations on scroll
- Generic hero with centered text over stock gradient
- Sans-serif font stack with no personality
```

## Examples

- "Propose minimal earth-tone tokens using the existing SaaS app styles; return the rationale without creating files."
- "Audit the local app at http://localhost:3000 on its home and pricing pages for visual consistency; report evidence and locations."
- "Review these supplied screenshots for generic gradients, excessive animation, and weak hierarchy; distinguish taste from usability defects."

