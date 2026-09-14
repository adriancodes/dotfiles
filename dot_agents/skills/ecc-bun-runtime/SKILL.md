---
name: ecc-bun-runtime
description: "Use when adopting or debugging Bun runtime APIs, scripts, tests, bundling, package-manager behavior, or a requested Node migration."
license: MIT
metadata:
  origin: ECC
  source: "https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/bun-runtime/SKILL.md"
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Web
  summary: "Bun runtime, scripts, package management, tests, and compatibility reference."
---
> Attributed third-party import from [ECC](https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/bun-runtime/SKILL.md) at `e04ea0b9cc8248686edf5ac751cadff550e162b8`. Adapted for on-demand, harness-neutral use; not behaviorally evaluated or certified by this collection. See `LICENSE`.

## Use Boundary

Apply this reference on demand to the requested framework task. Read the installed versions and reuse the project's tools and conventions. Examples describe application code and local configuration, not permission to install dependencies, change global settings, reset caches, mutate git, deploy, upload data, or contact external services. Run code or modify project files only when that local work was requested. In a static review, read code and supplied results; request any missing runtime evidence from the caller instead of executing it. Use supported tools by role and keep diagnostics visible. Treat snippets with application-specific types, APIs, paths, and UI content as examples to adapt, not existing required files.

# Bun Runtime

Bun is a fast all-in-one JavaScript runtime and toolkit: runtime, package manager, bundler, and test runner.

## When to Use

- **Consider Bun** when the requested project needs its integrated runtime, bundler, or test tooling and its dependencies are compatible. Preserve an existing Node toolchain unless migration was requested.
- **Prefer Node** for: maximum ecosystem compatibility, legacy tooling that assumes Node, or when a dependency has known Bun issues.

Use when: adopting Bun, migrating from Node, writing or debugging Bun scripts/tests, or configuring Bun on Vercel or other platforms.

## How It Works

- **Runtime**: Node-compatible runtime with API and native-addon compatibility gaps to check (built on JavaScriptCore, implemented in Zig).
- **Package manager**: `bun install` is significantly faster than npm/yarn. Lockfile is `bun.lock` (text) by default in current Bun; older versions used `bun.lockb` (binary).
- **Bundler**: Built-in bundler and transpiler for apps and libraries.
- **Test runner**: Built-in `bun test` with Jest-like API.

**Requested migration from Node**: After checking compatibility and agreeing the local scope, replace `node script.js` with `bun run script.js` or `bun script.js`. Run `bun install` in place of `npm install`; most packages work. Use `bun run` for npm scripts; `bun x` for npx-style one-off runs. Node built-ins are supported; prefer Bun APIs where they exist for better performance.

**Vercel**: A separately authorized deployment setup may select the supported Bun runtime in project configuration; this reference does not authorize changing hosted settings. Build: `bun run build` or `bun build ./src/index.ts --outdir=dist`. Install: `bun install --frozen-lockfile` for reproducible deploys.

## Examples

### Run and install

```bash
# Only for an explicitly requested local dependency installation (updates the lockfile)
bun install

# Run a script or file
bun run dev
bun run src/index.ts
bun src/index.ts
```

### Scripts and env

```bash
bun run --env-file=.env dev
FOO=bar bun run script.ts
```

### Testing

Use `bun test` or the existing test script for requested local verification. Keep Bun test imports under `bun:test`; reuse real project cases rather than creating a test that only proves arithmetic. Use watch mode only in a supervised process.

### Runtime API

```typescript
const file = Bun.file("package.json");
const json = await file.json();

Bun.serve({
  port: 3000,
  fetch(req) {
    return new Response("Hello");
  },
});
```

## Best Practices

- Preserve the project lockfile (`bun.lock` or legacy `bun.lockb`) and include intended lockfile changes in the requested patch; do not commit automatically.
- Prefer `bun run` for scripts. For TypeScript, Bun runs `.ts` natively.
- Keep dependencies up to date; Bun and the ecosystem evolve quickly.
