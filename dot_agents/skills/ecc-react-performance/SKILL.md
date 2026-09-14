---
name: ecc-react-performance
description: "Use when investigating React or Next.js waterfalls, bundle size, render cost, hydration, or Core Web Vitals regressions."
license: MIT
metadata:
  origin: ECC
  source: "https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/react-performance/SKILL.md"
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Web
  summary: "Prioritized React and Next.js performance reference with measurement-led decisions."
---
> Attributed third-party import from [ECC](https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/react-performance/SKILL.md) at `e04ea0b9cc8248686edf5ac751cadff550e162b8`. Adapted for on-demand, harness-neutral use; not behaviorally evaluated or certified by this collection. See `LICENSE`.

## Use Boundary

Apply this reference on demand to the requested framework task. Read the installed versions and reuse the project's tools and conventions. Examples describe application code and local configuration, not permission to install dependencies, change global settings, reset caches, mutate git, deploy, upload data, or contact external services. Run code or modify project files only when that local work was requested. In a static review, read code and supplied results; request any missing runtime evidence from the caller instead of executing it. Use supported tools by role and keep diagnostics visible. Treat snippets with application-specific types, APIs, paths, and UI content as examples to adapt, not existing required files.

# React Performance

Performance optimization patterns for React 18/19 and Next.js, adapted from [Vercel Labs `react-best-practices`](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) (MIT, v1.0.0). This skill organizes rules by priority and provides decision-tree guidance for active code review and refactoring.

## When to Activate

- Writing or reviewing React/Next.js code for performance
- Diagnosing slow page loads, slow interactions, or high CPU on the client
- Auditing bundle size or Lighthouse Core Web Vitals regressions
- Removing waterfalls in Server Components / API routes
- Reducing client-side re-renders
- Optimizing long lists, animations, or hydration
- Auditing optimization choices in PRs touching `app/`, `pages/`, `components/`, or data layers

## Priority Index

| Priority | Category | Prefix | When it matters |
|---|---|---|---|
| 1 — CRITICAL | Eliminating Waterfalls | `async-` | Anytime `await` is followed by independent `await` |
| 2 — CRITICAL | Bundle Size Optimization | `bundle-` | First-load JS, route-level imports, third-party libs |
| 3 — HIGH | Server-Side Performance | `server-` | RSC, Server Actions, API routes, SSR |
| 4 — MEDIUM-HIGH | Client-Side Data Fetching | `client-` | SWR / TanStack Query / raw `fetch` in hooks |
| 5 — MEDIUM | Re-render Optimization | `rerender-` | High-frequency state updates, parent-child fan-out |
| 6 — MEDIUM | Rendering Performance | `rendering-` | Long lists, animations, hydration |
| 7 — LOW-MEDIUM | JavaScript Performance | `js-` | Hot loops, frequent allocations |
| 8 — LOW | Advanced Patterns | `advanced-` | Effect-event integration, stable refs |

## 1. Eliminating Waterfalls (CRITICAL)

> "Waterfalls are the #1 performance killer" — every sequential `await` adds full network latency.

### Cheap conditions before await

Check sync conditions (props, env, hardcoded flags) before awaiting remote data.

```ts
// INCORRECT
async function Page({ id }: { id: string }) {
  const flag = await getFlag("show-page");
  if (!flag || !id) return null;
  const data = await getData(id);
  // ...
}

// CORRECT — short-circuit on cheap sync condition first
async function Page({ id }: { id: string }) {
  if (!id) return null;
  const flag = await getFlag("show-page");
  if (!flag) return null;
  const data = await getData(id);
}
```

### Defer awaits until used

Move `await` into the branch that uses it.

```ts
// INCORRECT — awaits before deciding it needs the data
const user = await getUser(id);
if (mode === "guest") return renderGuest();
return renderUser(user);

// CORRECT
if (mode === "guest") return renderGuest();
const user = await getUser(id);
return renderUser(user);
```

### Promise.all for independent work

```ts
// INCORRECT — sequential
const user = await getUser(id);
const posts = await getPosts(id);
const followers = await getFollowers(id);

// CORRECT — parallel
const [user, posts, followers] = await Promise.all([
  getUser(id),
  getPosts(id),
  getFollowers(id),
]);
```

### Partial dependencies — start early, await late

```ts
// CORRECT — kick off all promises, await only when each result is needed
const profile = await getProfile(id);
if (profile.private) return null; // authorize before fetching protected data
const [user, posts] = await Promise.all([getUser(id), getPosts(id)]);
```

### Suspense for streaming

Push `<Suspense>` boundaries close to the data so the page paints what it can while slower sub-trees stream in. The trade-off: layout shift when content arrives — reserve space (skeleton or `min-height`).

### Server Components: parallel through composition

```tsx
// INCORRECT — sibling awaits run sequentially inside one component
export default async function Page() {
  const user = await getUser();
  const cart = await getCart();
  return <View user={user} cart={cart} />;
}

// CORRECT — split into children, React runs them in parallel
export default async function Page() {
  return (
    <View>
      <UserSection />
      <CartSection />
    </View>
  );
}
```

## 2. Bundle Size Optimization (CRITICAL)

### Direct imports, not barrels

Barrel `index.ts` files force the bundler to walk the entire module graph even when tree-shaking removes most of it. Measure module-graph and output cost in the target app before changing imports.

```ts
// INCORRECT
import { Button, Card, Modal } from "@/components";

// CORRECT
import { Button } from "@/components/Button";
import { Card } from "@/components/Card";
import { Modal } from "@/components/Modal";
```

Next.js 13.5+ has [Optimize Package Imports](https://nextjs.org/docs/app/api-reference/next-config-js/optimizePackageImports) that automates this for listed packages — use it; manual direct imports still required for non-listed libs.

### Statically analyzable paths

```ts
// INCORRECT — defeats bundler/trace analysis
const mod = await import(`./pages/${name}`);

// CORRECT — explicit per branch
const mod = name === "home" ? await import("./pages/home") : await import("./pages/about");
```

### Dynamic imports for heavy components

```tsx
import dynamic from "next/dynamic";

const HeavyChart = dynamic(() => import("./HeavyChart"), {
  loading: () => <Skeleton />,
  ssr: false, // when client-only
});
```

### Defer third-party scripts

Load analytics, logging, support widgets AFTER hydration. Use `next/script` with `strategy="afterInteractive"` (default) or `"lazyOnload"`.

### Conditional module loading

```tsx
if (user.role === "admin") {
  const { AdminPanel } = await import("./admin/AdminPanel");
  // ...
}
```

### Preload on hover/focus

Trigger `<link rel="preload">` or `import()` on hover so the bundle is in cache by the time the user clicks.

## 3. Server-Side Performance (HIGH)

### Authenticate Server Actions like API routes

Treat exposed Server Actions as callable endpoints. Authenticate AND authorize inside the action — never rely on the calling Client Component's gating.

```ts
"use server";
export async function deleteUser(formData: FormData) {
  const session = await getSession();
  if (!session?.user) throw new Error("Unauthorized");
  const targetId = formData.get("id");
  if (typeof targetId !== "string" || !targetId) throw new Error("Invalid user ID");
  if (session.user.role !== "admin" && session.user.id !== targetId) {
    throw new Error("Forbidden");
  }
  await db.user.delete({ where: { id: targetId } });
}
```

### `React.cache()` for per-request deduplication

```ts
import { cache } from "react";

export const getUser = cache(async (id: string) => {
  return db.user.findUnique({ where: { id } });
});
```

`React.cache` dedupes within a single request. Calling `getUser("1")` from three Server Components in the same render = one DB query.

### LRU cache for cross-request data

For data that does NOT change per request (config, lookup tables), cache outside React with an LRU cache or `unstable_cache`.

### Avoid duplicate serialization in RSC props

React Flight can deduplicate repeated references within a render; recreated objects may still add payload. Measure serialized data and minimize sensitive or unused props before changing component boundaries.

### Hoist static I/O to module scope

```ts
// CORRECT — runs once at module load
const fontData = readFileSync(fontPath);

export async function Page() {
  return <Banner font={fontData} />;
}
```

### Keep user-specific state request-scoped in RSC/SSR

Module state may be shared across requests; never store per-user mutable data there. Shared caches require correct keys, isolation, and bounded lifetime. Use request-scoped storage (`headers()`, `cookies()`, async context) instead.

### Minimize data passed to Client Components

Only serialize what the Client needs. Strip fields, paginate, project columns at the DB layer.

### Bound independent fetches and prefer batching

```ts
const users = await getUsers();
const postsByUser = await getPostsForUsers(users.map((u) => u.id)); // batched query
const enriched = users.map((u) => ({ ...u, posts: postsByUser.get(u.id) ?? [] }));
```

### Use `after()` for non-blocking work

Next.js 15 `after()` runs work after the response is sent — logging, cache warming, analytics.

```ts
import { after } from "next/server";
export async function GET() {
  const data = await getData();
  after(() => logAnalytics(data));
  return Response.json(data);
}
```

## 4. Client-Side Data Fetching (MEDIUM-HIGH)

### SWR / TanStack Query for deduplication

Multiple components calling `useUser(id)` should share one network request and one cache entry. Use SWR or TanStack Query — never roll your own `useEffect` + `fetch` for shared data.

### Deduplicate global event listeners

```tsx
// INCORRECT — every component adds its own
useEffect(() => {
  window.addEventListener("scroll", handler);
  return () => window.removeEventListener("scroll", handler);
}, []);

// CORRECT — single shared listener via a hook + global subject
const useScroll = createScrollHook(); // singleton subject under the hood
```

### Passive listeners for scroll

```ts
window.addEventListener("scroll", handler, { passive: true });
```

Improves scrolling smoothness; the listener cannot `preventDefault()`.

### localStorage: version + minimize

- Always store a `version` field; bump on schema change and migrate or discard old data
- Keep payloads small — `localStorage` is synchronous and blocks main thread

## 5. Re-render Optimization (MEDIUM)

### Don't subscribe to state used only in callbacks

```tsx
// INCORRECT — re-renders every time count changes
const count = useStore((s) => s.count);
const handler = () => doSomething(count);

// CORRECT — read once on call
const handler = () => {
  const count = useStore.getState().count;
  doSomething(count);
};
```

### Extract expensive work into memoized components

```tsx
// Memo can skip unchanged parent props; own state/context updates still render
const Heavy = memo(function Heavy({ items }: { items: Item[] }) {
  return <Chart data={transform(items)} />;
});
```

### Hoist default non-primitive props

```tsx
// INCORRECT — new array each render breaks memo
<List items={items ?? []} />

// CORRECT
const EMPTY: Item[] = [];
<List items={items ?? EMPTY} />
```

### Primitive dependencies in effects

```tsx
// INCORRECT — new object identity every render
useEffect(() => {}, [{ id, name }]);

// CORRECT — primitives
useEffect(() => {}, [id, name]);
```

### Subscribe to derived booleans, not raw values

```tsx
// INCORRECT — re-renders for any cart change
const cart = useStore((s) => s.cart);
const hasItems = cart.length > 0;

// CORRECT — re-renders only when emptiness flips
const hasItems = useStore((s) => s.cart.length > 0);
```

### Derive during render, never via `useEffect`

```tsx
// INCORRECT
const [full, setFull] = useState("");
useEffect(() => setFull(`${first} ${last}`), [first, last]);

// CORRECT
const full = `${first} ${last}`;
```

### Functional `setState` for stable callbacks

```tsx
// CORRECT
const increment = useCallback(() => setCount((c) => c + 1), []);
```

### Lazy state initializer for expensive values

```tsx
const [tree] = useState(() => parseTree(largeInput));
```

### Avoid memo for simple primitives

`useMemo(() => x + 1, [x])` is overhead. Memo earns its keep on object identity and expensive computation.

### Split hooks with independent deps

```tsx
// INCORRECT — both selectors re-run if either source changes
const { a, b } = useSomething(source1, source2);

// CORRECT
const a = useA(source1);
const b = useB(source2);
```

### Move interaction logic into event handlers

Event handlers run only on the user action — `useEffect` re-runs whenever deps change.

### `startTransition` for non-urgent updates

```tsx
const [pending, startTransition] = useTransition();
startTransition(() => setFilters(newFilters));
```

### `useDeferredValue` for expensive renders

```tsx
const deferredQuery = useDeferredValue(query);
const results = useMemo(() => expensiveSearch(deferredQuery), [deferredQuery]);
```

### `useRef` for transient frequent values

For values that change often but should not trigger re-render (timestamps, last-key, accumulators).

### Don't define components inside components

```tsx
// INCORRECT — Inner is a new component on every Outer render
function Outer() {
  const Inner = () => <span />;
  return <Inner />;
}
```

Each render makes a new `Inner` type, defeating reconciliation and unmounting children.

## 6. Rendering Performance (MEDIUM)

### Animate the wrapper, not the SVG

Compare wrapper and SVG transforms with supplied or requested local browser profiling; compositing depends on element, browser, and animation, not a universal SVG rule.

### `content-visibility: auto` for long lists

```css
.row { content-visibility: auto; contain-intrinsic-size: auto 80px; }
```

Browser skips offscreen rendering — major win for lists with hundreds of rows.

### Hoist static JSX

```tsx
const STATIC_HEADER = <h1>Title</h1>;
function Page() {
  return <>{STATIC_HEADER}<Body /></>;
}
```

### SVG: reduce coordinate precision

`d="M10.123456,20.654321"` → `d="M10.12,20.65"`. Each digit costs bytes; the visual difference is sub-pixel.

### Hydration no-flicker via inline script

For values needed before hydration (theme, locale), inline a `<script>` that sets `document.documentElement.dataset.*` before React mounts.

### Keep hydration deterministic

Serialize the server value for the initial client render, then update client-only time or locale state after mount. Do not hide a hydration defect with warning suppression.

### `<Activity>` for show/hide instead of mount/unmount

In React versions supporting `Activity` (introduced in 19.2), hidden mode preserves state while cleaning up effects; effects are recreated on reveal. Measure the trade-off and check version support.

### Ternary over `&&` for conditional render

```tsx
// INCORRECT — `0` renders as text node
{count && <Badge>{count}</Badge>}

// CORRECT
{count > 0 ? <Badge>{count}</Badge> : null}
```

### `useTransition` for loading states

Pair `startTransition` with the action; React shows the previous UI as `isPending` while the next state computes.

### React DOM resource hints

```tsx
import { preload, preconnect } from "react-dom";
preload("/api/critical", { as: "fetch" });
preconnect("https://api.example.com");
```

### `defer` / `async` on `<script>` tags

`defer` executes external classic scripts after parsing and before DOMContentLoaded in document order; `async` executes when ready without ordering guarantees.

## 7. JavaScript Performance (LOW-MEDIUM)

- **Batch DOM/CSS changes** — apply via class swap or `cssText`, not property-by-property
- **`Map` for repeated lookups** — `O(1)` vs `O(n)` linear scan
- **Cache property access in loops** — `const len = arr.length`
- **Memoize pure functions** — module-level `Map<key, result>`
- **Cache `localStorage` reads** — sync API; one read per render
- **Combine `filter().map()` into one pass** — `flatMap` or single `for`
- **Check array length first** before expensive comparisons
- **Early return** from functions
- **Hoist RegExp** out of loops — compilation is not free
- **Loop for min/max** instead of `sort()` — `O(n)` vs `O(n log n)`
- **`Set`/`Map` for membership** — `O(1)` vs `Array.includes` `O(n)`
- **`toSorted()` over mutation** when immutability matters
- **`flatMap` to map and filter in one pass**
- **`requestIdleCallback`** for non-critical work

## 8. Advanced Patterns (LOW)

### `useEffectEvent` deps

Effect Events read the latest values without making the calling effect reactive to them. Omit Effect Events from effect dependencies according to the installed React/linter rules; do not use them to hide genuinely reactive dependencies or pass them as general callbacks.

### Event handler refs

For stable callbacks passed to memoized children:

```tsx
const handlerRef = useRef(handler);
useEffect(() => { handlerRef.current = handler; });
const stable = useCallback((arg) => handlerRef.current(arg), []);
```

### Init once per app load

For module-level singletons (telemetry, logger), guard with a module-scope flag — not `useEffect`.

### `useLatest` for stable callback refs

```tsx
function useLatest<T>(value: T) {
  const ref = useRef(value);
  useEffect(() => { ref.current = value; }, [value]);
  return ref;
}
```

## Automated Tools

Many of these rules are now automated:

- **Next.js 13.5+ Optimize Package Imports** — barrel import optimization
- **React Compiler** — automatic memoization when the project uses a supported, configured compiler version
- **Turbopack** — faster builds, better tree-shaking
- **Bundle Analyzer** (`@next/bundle-analyzer`) — visualize first-load JS

Check whether React Compiler covers the affected code before adding manual memoization. Preserve memoization whose identity contract matters and measure changes; neither adding nor removing all memoization is a universal rule.

## Lighthouse / Web Vitals Mapping

| Metric | Most relevant categories |
|---|---|
| **LCP** (Largest Contentful Paint) | Waterfalls, Bundle Size, Resource Hints |
| **INP** (Interaction to Next Paint) | Re-render, Rendering, JavaScript |
| **CLS** (Cumulative Layout Shift) | Rendering (Suspense placement, image dimensions) |
| **TBT** (Total Blocking Time) | Bundle Size, JavaScript, Defer Third-Party |
| **FID** (legacy) | Bundle Size, Hydration |

## Related Guidance

- `ecc-react-patterns` if available; otherwise keep renders pure, state localized, and client payloads minimal.
- `ecc-react-testing` if available; otherwise preserve user-observable behavior during optimization.
- `ecc-nextjs-turbopack` if available; otherwise check installed bundler support and supplied bundle reports.

## Attribution

Adapted from Vercel Labs `react-best-practices` skill (MIT License, copyright Vercel Engineering, v1.0.0 January 2026). Source: [https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices).

This skill restructures and adapts the original 70-rule catalog into a single navigable reference. For the full original ruleset with extended examples, see the upstream repository.
