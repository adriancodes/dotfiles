> Adapted from [ECC](https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/motion-foundations/SKILL.md), revision `e04ea0b9cc8248686edf5ac751cadff550e162b8`, MIT. Original author credit: jeff. Local supporting reference, not a separately installed skill.

# Motion Foundations

The base layer of the motion system. Defines every value, constraint, and
rule that downstream skills (`motion-patterns`, `motion-advanced`) inherit.
Read this bundled reference when adapting the motion examples; it is not a separate skill installation.

## When to Activate

- Starting any animated component from scratch
- Setting up tokens, spring presets, or easing values
- Implementing `prefers-reduced-motion` support
- Debugging hydration mismatches from animation initial states
- Evaluating whether an animation should exist at all

## Outputs

This skill produces:

- A shared `motionTokens` object (duration, easing, distance, scale)
- A shared `springs` preset map (5 named configs)
- A `shouldAnimate()` gate used by all components
- Accessibility-compliant animation defaults via `useReducedMotion`
- SSR-safe initial states with zero hydration warnings

## Principles

Motion must do at least one of the following or it must be removed:

- Guide attention
- Communicate state
- Preserve spatial continuity

Responsiveness always outranks smoothness. A 60 fps animation that causes
input delay is worse than no animation.

## Adaptation Rules

- Reuse the installed compatible motion library; these examples use `motion/react`. Do not migrate or install a package automatically.
- Keep server output and the first client render deterministic. Motion may render its initial styles on the server; an opacity-zero initial value alone does not prove a hydration mismatch.
- Respect reduced-motion preferences for every animation, including hover, tap, drag, and exit. Prefer immediate final state when motion is unnecessary.
- Prefer transform and opacity for performance; measure justified layout animations rather than treating every dimensional animation as forbidden.
- Reuse existing design tokens and spring presets; the bundled values are examples, not universal policy.
- Place client-only hooks behind the framework's client boundary. Not every imported module needs its own client directive.
- Read browser globals after mount where they affect rendering. A typeof guard alone does not ensure matching initial renders.
- Hardware concurrency is a coarse optional heuristic, not a reliable device-performance classification.

## Decision Guidance

### Choosing a duration

| Token | Use when |
| --------- | -------------------------------------------- |
| `instant` | Tooltip show/hide, focus ring, badge update |
| `fast` | Button feedback, icon swap, chip toggle |
| `normal` | Modal open, card expand, page element enter |
| `slow` | Hero entrance, full-page transition |
| `crawl` | Deliberate storytelling; use sparingly |

### Choosing a spring

| Preset | Use when |
| --------- | ------------------------------------------ |
| `snappy` | Default UI — buttons, chips, nav items |
| `gentle` | Cards, modals, panels landing softly |
| `bouncy` | Playful moments — empty states, onboarding |
| `instant` | Tooltips, popovers, dropdowns |
| `release` | Drag release — natural physics feel |

### When to disable animation entirely

Disable (make `shouldAnimate()` return `false`) when:

- `prefersReduced` is `true`
- `isLowEnd` is `true` and the animation is non-essential
- The element is off-screen and will never enter the viewport
- The animation is purely decorative with no UX purpose

## Core Concepts

### Token system

```ts
// lib/motion-tokens.ts
export const motionTokens = {
  duration: {
    instant: 0.08,
    fast:    0.18,
    normal:  0.35,
    slow:    0.6,
    crawl:   1.0,
  },
  easing: {
    smooth: [0.22, 1, 0.36, 1],
    sharp:  [0.4, 0, 0.2, 1],
    bounce: [0.34, 1.56, 0.64, 1],
    linear: [0, 0, 1, 1],
  },
  distance: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 48,
  },
  scale: {
    subtle: 0.98,
    press:  0.95,
    pop:    1.04,
  },
}

export const springs = {
  snappy:  { type: "spring", stiffness: 300, damping: 30 },
  gentle:  { type: "spring", stiffness: 120, damping: 14 },
  bouncy:  { type: "spring", stiffness: 400, damping: 10 },
  instant: { type: "spring", stiffness: 600, damping: 35 },
  release: { type: "spring", stiffness: 200, damping: 20, restDelta: 0.001 },
}
```

### Runtime flags

```ts
// lib/motion-config.ts
import { motionTokens } from "./motion-tokens"
export const motionConfig = {
  isLowEnd() {
    return (
      typeof navigator !== "undefined" &&
      navigator.hardwareConcurrency <= 4
    )
  },

  prefersReduced() {
    return (
      typeof window !== "undefined" &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches
    )
  },

  shouldAnimate({ essential = false } = {}) {
    if (this.prefersReduced()) return false
    if (!essential && this.isLowEnd()) return false
    return true
  },

  duration() {
    return this.isLowEnd() || this.prefersReduced()
      ? motionTokens.duration.instant
      : motionTokens.duration.normal
  },
}
```

### Accessibility

**Priority order (highest to lowest):**

1. `prefers-reduced-motion: reduce` — disables all transforms, limits opacity transitions to ≤ 0.2s
2. Low-end device detection — reduces duration, removes non-essential animations
3. Design preference — everything else

Motion must degrade gracefully. It must never disappear abruptly in a way
that causes layout shift or confuses orientation.

```tsx
// hooks/use-reduced-motion.tsx
"use client"
import { useReducedMotion } from "motion/react"

export function useSafeMotion(fullY: number = 16) {
  const reduce = useReducedMotion()
  return {
    initial: { opacity: 0, y: reduce ? 0 : fullY },
    animate: { opacity: 1, y: 0 },
    exit:    { opacity: 0, y: reduce ? 0 : -fullY },
  }
}
```

```css
/* globals.css */
@media (prefers-reduced-motion: reduce) {
  .motion-safe-transition  { transition: opacity 0.15s; }
  .motion-reduce-transform { transform: none !important; }
}
```

```html
<!-- Tailwind -->
<div class="motion-safe:animate-fade motion-reduce:opacity-100"></div>
```

### SSR / hydration safety

Match server markup and the first client render. Do not branch initial output on browser-only preferences or hardware. Motion can serialize initial styles during SSR; use `initial={false}` when content should be visible immediately. Read changing reduced-motion preferences with the installed hook and ensure disabled animation leaves content visible and operable.

## Code Examples

### End-to-end: tokens + springs + accessibility + SSR guard

```tsx
// components/fade-in-card.tsx
"use client"

import { useState, useEffect } from "react"
import { motion } from "motion/react"
import { motionTokens, springs } from "@/lib/motion-tokens"
import { useSafeMotion } from "@/hooks/use-reduced-motion"
import { motionConfig } from "@/lib/motion-config"

interface FadeInCardProps {
  children: React.ReactNode
  delay?: number
}

export function FadeInCard({ children, delay = 0 }: FadeInCardProps) {
  // SSR guard — initial must match server output (opacity: 1)
  const [mounted, setMounted] = useState(false)
  useEffect(() => setMounted(true), [])

  // Accessibility — disables transform when reduced motion is preferred
  const safeMotion = useSafeMotion(motionTokens.distance.md)

  // Device gate — skip animation on low-end hardware
  if (!motionConfig.shouldAnimate() || !mounted) {
    return <div>{children}</div>
  }

  return (
    <motion.div
      initial={safeMotion.initial}
      animate={safeMotion.animate}
      exit={safeMotion.exit}
      transition={{
        ...springs.gentle,
        delay,
      }}
      whileHover={{ scale: motionTokens.scale.pop }}
      whileTap={{ scale: motionTokens.scale.press }}
    >
      {children}
    </motion.div>
  )
}
```

## Constraints / Non-Goals

This skill does **not** cover:

- UI component patterns (button, modal, stagger) → see `motion-patterns`
- Drag, gestures, SVG, text animations, custom hooks → see `motion-advanced`
- CSS-only animations or Tailwind `animate-*` classes without `motion/react`
- Third-party animation libraries (GSAP, anime.js, etc.)
- Motion design decisions (when to animate, what to emphasize) — that is a design concern, not a code constraint

## Integration Checks

Check the installed library version, client boundary, reduced-motion behavior, hydration identity, accessible visibility, and performance evidence. The examples are recipes rather than conformance guarantees. Preserve keyboard and focus behavior separately from animation.

## Related Guidance

- `ecc-motion-patterns` if available; otherwise adapt button, modal, list, and route transitions to the existing accessibility contract.
- `ecc-motion-advanced` if available; otherwise use cleanup and reduced-motion gates for gestures, SVG, and imperative sequences.

