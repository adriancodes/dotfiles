---
name: ecc-nextjs-turbopack
description: "Use when diagnosing Next.js 16 Turbopack startup, HMR, build caching, bundle analysis, or proxy filename questions."
license: MIT
metadata:
  origin: ECC
  source: "https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/nextjs-turbopack/SKILL.md"
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Web
  summary: "Next.js and Turbopack version-aware development, builds, caching, and proxy guidance."
---
> Attributed third-party import from [ECC](https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/nextjs-turbopack/SKILL.md) at `e04ea0b9cc8248686edf5ac751cadff550e162b8`. Adapted for on-demand, harness-neutral use; not behaviorally evaluated or certified by this collection. See `LICENSE`.

## Use Boundary

Apply this reference on demand to the requested framework task. Read the installed versions and reuse the project's tools and conventions. Examples describe application code and local configuration, not permission to install dependencies, change global settings, reset caches, mutate git, deploy, upload data, or contact external services. Run code or modify project files only when that local work was requested. In a static review, read code and supplied results; request any missing runtime evidence from the caller instead of executing it. Use supported tools by role and keep diagnostics visible. Treat snippets with application-specific types, APIs, paths, and UI content as examples to adapt, not existing required files.

# Next.js and Turbopack

Next.js 16 uses Turbopack by default for development and production builds. It is an incremental bundler written in Rust; measure startup and update behavior in the target project.

## When to Use

- **Turbopack (default dev)**: Use for day-to-day development. Faster cold start and HMR, especially in large apps.
- **Webpack (legacy dev)**: Use only if you hit a Turbopack bug or rely on a webpack-only plugin in dev. Disable with `--webpack` for Next.js 16; confirm the supported flag in the installed version.
- **Production**: Production build behavior (`next build`) may use Turbopack or webpack depending on Next.js version; check the official Next.js docs for your version.

Use when: developing or debugging Next.js 16+ apps, diagnosing slow dev startup or HMR, or optimizing production bundles.

## How It Works

- **Turbopack**: Incremental bundler for Next.js dev. Uses file-system caching so restarts are much faster (measure the actual project).
- **Default in dev**: From Next.js 16, `next dev` runs with Turbopack unless disabled.
- **File-system caching**: Availability and default enablement depend on the Next.js minor and dev/build mode. Check version-specific options and preserve existing `.next` caches.
- **Bundle Analyzer (Next.js 16.1+)**: Experimental Bundle Analyzer to inspect output and find heavy dependencies; enable via config or experimental flag (see Next.js docs for your version).

## Examples

### Commands

```bash
next dev
next build
next start
```

### Usage

Run `next dev` for local development with Turbopack. Use the Bundle Analyzer (see Next.js docs) to optimize code-splitting and trim large dependencies. Prefer App Router and server components where possible.

## Middleware File Naming

Next.js 16 introduced `proxy.ts` as the middleware filename, replacing the older `middleware.ts` convention:

- **Next.js 16+**: use `proxy.ts` at the project root
- **Pre-Next.js 16**: use `middleware.ts` at the project root

The filename change is tied to the **Next.js version**, not to which bundler (Turbopack or webpack) is in use. Always check the official docs for the version you are reviewing.

**Do not flag `proxy.ts` as a misnamed or missing middleware file in Next.js 16 projects.** The file is correct and intentional. Do not request a rename based on older conventions; inspect the installed version and existing migration state.

Reference: [Next.js proxy docs](https://nextjs.org/docs/app/getting-started/proxy)

## Best Practices

- Stay on a recent Next.js 16.x for stable Turbopack and caching behavior.
- If dev is slow, ensure you're on Turbopack (default) and that the cache isn't being cleared unnecessarily.
- For production bundle size issues, use the official Next.js bundle analysis tooling for your version.
