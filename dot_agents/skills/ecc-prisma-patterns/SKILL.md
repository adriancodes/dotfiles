---
name: ecc-prisma-patterns
description: "Use when writing a Prisma schema or query, or debugging transactions, migrations, or serverless connection limits."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/prisma-patterns/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for prisma patterns; adapted for explicit local scope and evidence-backed use."
---

# Prisma Patterns — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Prisma Patterns

Production patterns and non-obvious traps for Prisma ORM in TypeScript backends.

Identify the Prisma CLI/client, generator, driver adapter, database provider, and exact installed version from manifests, lockfiles, generated declarations, or caller-supplied version output. Do not auto-download the CLI to check it.

- `prisma` is the CLI/tooling package, not a blanket replacement name for `@prisma/client`. Client imports depend on the configured generator output.
- Adapter requirements, `prisma.config.ts`, schema URL configuration, relation loading, and migration CLI flags vary by major release.
- Use installed declarations and version-matched official documentation rather than declaring CLI behavior unchanged across versions.

## When to Activate

- Designing or modifying Prisma schema models and relations
- Writing queries, transactions, or pagination logic
- Using `updateMany`, `deleteMany`, or any bulk operation
- Running or planning database migrations
- Deploying to serverless environments (Vercel, Lambda, Cloudflare Workers)
- Implementing soft delete or multi-tenant row filtering

## Core Concepts

### ID Strategy

| Strategy | Use When | Avoid When |
|---|---|---|
| `@default(cuid())` | Application-generated string IDs; evaluate index locality and collision assumptions | Sequential IDs needed for external systems |
| `@default(uuid())` | Interoperability with non-Prisma systems required | High-write tables (random UUIDs fragment B-tree indexes) |
| `@default(autoincrement())` | Internal join tables, audit logs | Public-facing IDs (exposes record count) |

### Schema Defaults

```prisma
model User {
  id        String    @id @default(cuid())
  email     String    @unique  // @unique already creates an index — no @@index needed
  name      String
  role      Role      @default(USER)
  posts     Post[]
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  deletedAt DateTime?

  @@index([createdAt])
  @@index([deletedAt, createdAt]) // composite for soft-delete + sort queries
}
```

- Justify indexes with query shape, selectivity, provider behavior, write cost, and supplied plans; avoid indexing every filtered column blindly.
- Declare `deletedAt DateTime?` upfront when soft delete is a foreseeable requirement — adding it later requires a migration on a live table.
- `@updatedAt` is Prisma-managed rather than a database trigger. Verify actual generated-client behavior for updates/bulk writes, empty data objects, raw SQL, and external writers.

### `include` vs `select`

| | `include` | `select` |
|---|---|---|
| Returns | All scalar fields + specified relations | Only specified fields |
| Use when | You need most fields plus a relation | Hot paths, large tables, avoiding over-fetch |
| Performance | May over-fetch on wide tables | Minimal payload, faster on large datasets |
| Version/provider note | Query count depends on supported relation load strategy and configuration | Inspect generated queries rather than assuming JOIN behavior |

```ts
// include — all columns + relation
const user = await prisma.user.findUnique({
  where: { id },
  include: { posts: { select: { id: true, title: true } } },
});

// select — explicit allowlist
const user = await prisma.user.findUnique({
  where: { id },
  select: { id: true, email: true, name: true },
});
```

Never return raw Prisma entities from API responses — map to response DTOs to control exposed fields:

```ts
// BAD: leaks passwordHash, deletedAt, internal fields
return await prisma.user.findUniqueOrThrow({ where: { id } });

// GOOD: explicit DTO mapping
const user = await prisma.user.findUniqueOrThrow({ where: { id } });
return { id: user.id, name: user.name, email: user.email };
```

### Transaction Form Selection

| Situation | Use |
|---|---|
| Independent operations, no inter-dependency | Array form |
| Later step depends on earlier result | Interactive form |
| External calls (email, HTTP) involved | Outside transaction entirely |

```ts
// Array form — sequential operations in a transaction; not a universal single-round-trip guarantee.
const [user, post] = await prisma.$transaction([
  prisma.user.update({ where: { id }, data: { name } }),
  prisma.post.create({ data: { title, authorId: id } }),
]);

// Interactive form — use tx client only, never the outer prisma client
const post = await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUniqueOrThrow({ where: { id } });
  if (user.role !== 'ADMIN') throw new Error('Forbidden');
  return tx.post.create({ data: { title, authorId: user.id } });
});
```

### PrismaClient Singleton

Each `PrismaClient` instance opens its own connection pool. Instantiate once.

```ts
// lib/prisma.ts

// Option A — adapter-based initialization (required by newer Prisma installs)
import { PrismaClient } from '@prisma/client'; // or the generated client path for your setup
import { PrismaPg } from '@prisma/adapter-pg';

function createPrismaClient() {
  const adapter = new PrismaPg({
    connectionString: process.env.DATABASE_URL!,
  });
  return new PrismaClient({
    adapter,
    log: ['error'], // Do not enable query/parameter capture automatically.
  });
}

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma = globalForPrisma.prisma ?? createPrismaClient();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

// Option B — direct initialization (older installs, no adapter needed)
// import { PrismaClient } from '@prisma/client';
// export const prisma = globalForPrisma.prisma ?? new PrismaClient({ ... });
```

Use Option A if your Prisma install requires an `adapter` argument in the `PrismaClient` constructor.
Use Option B if `new PrismaClient()` works without arguments. Let the compiler tell you which is correct.

The `globalThis` pattern prevents duplicate instances during hot reload (Next.js, nodemon, ts-node-dev).

### N+1 Problem

Loading relations inside a loop issues one query per row.

```ts
// BAD: N+1 — one extra query per user
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } });
}

// GOOD: avoid per-row application queries; inspect the actual relation load strategy.
const users = await prisma.user.findMany({ include: { posts: true } });
```

Relation JOIN loading depends on installed version, provider, and enabled features. Compare generated SQL, row cardinality, and payload size with supplied measurements; `include` does not universally imply a single JOIN.

## Code Examples

### Cursor Pagination (preferred for feeds and large datasets)

```ts
async function getPosts(cursor?: string, limit = 20) {
  if (!Number.isInteger(limit) || limit < 1 || limit > 100) throw new RangeError("limit must be 1..100");
  const items = await prisma.post.findMany({
    where: { published: true },
    orderBy: [
      { createdAt: 'desc' },
      { id: 'desc' }, // secondary sort prevents unstable pagination on duplicate timestamps
    ],
    take: limit + 1,
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
  });

  const hasNextPage = items.length > limit;
  if (hasNextPage) items.pop();

  return { items, nextCursor: hasNextPage ? items[items.length - 1].id : null };
}
```

Fetch `limit + 1` and pop — canonical way to detect `hasNextPage` without an extra count query. Always include a unique field (e.g. `id`) as a secondary `orderBy` to prevent unstable pagination when multiple rows share the same timestamp. Use offset pagination only when users need to jump to arbitrary pages (admin tables).

### Soft Delete

```ts
// Always filter explicitly — do not rely on middleware (hides behavior, hard to debug)
const activeUsers = await prisma.user.findMany({ where: { deletedAt: null } });

await prisma.user.update({ where: { id }, data: { deletedAt: new Date() } });
await prisma.user.update({ where: { id }, data: { deletedAt: null } }); // restore
```

### Error Handling

```ts
import { Prisma } from '@prisma/client'; // or the generated client path for your setup

try {
  await prisma.user.create({ data: { email } });
} catch (e) {
  if (e instanceof Prisma.PrismaClientKnownRequestError) {
    if (e.code === 'P2002') throw new ConflictError('Email already exists');
    if (e.code === 'P2025') throw new NotFoundError('Record not found');
    if (e.code === 'P2003') throw new BadRequestError('Referenced record does not exist');
  }
  throw e;
}
```

Common codes: `P2002` unique violation · `P2025` not found · `P2003` foreign key violation.

Catch at the service boundary and translate to domain errors. Never expose raw Prisma messages to API consumers.

### Connection Pool — Serverless

For legacy engine-managed pools, use the documented URL parameters for that engine. Adapter-based pools use the native driver configuration (for example `max` on the PostgreSQL pool); legacy URL parameters are not a universal adapter pool limit. Preserve existing query parameters when constructing URLs:

```bash
# .env — preferred: embed params in the URL
DATABASE_URL="postgresql://user:pass@host/db?connection_limit=1&pool_timeout=20"

# With an external pooler (PgBouncer, Supabase pooler)
DATABASE_URL="postgresql://user:pass@host/db?pgbouncer=true&connection_limit=1"
```

```ts
// Vercel, AWS Lambda, and similar serverless runtimes:
// Size aggregate connections across all instances; adapter pools use their driver options.

// Adapter-based setup (if your Prisma install requires an adapter):
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL, max: 1, connectionTimeoutMillis: 5_000 }),
});

// Direct setup (if your Prisma install does not require an adapter):
// const prisma = new PrismaClient();
```

## Anti-Patterns

### `updateMany` returns a count, not records

```ts
// BAD: result is { count: 2 } — users[0] is undefined
const users = await prisma.user.updateMany({ where: { role: 'GUEST' }, data: { role: 'USER' } });

// When supported by the installed version/provider, updateManyAndReturn returns rows.
// Otherwise define transaction isolation and concurrent-writer semantics before
// using read/update/read; that sequence is not an atomic row-returning operation.
```

Same applies to `deleteMany` — returns `{ count: n }`, never the deleted rows.

### `$transaction` interactive form times out after 5 seconds

```ts
// BAD: external call inside transaction exceeds 5s default → "Transaction already closed"
await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUniqueOrThrow({ where: { id } });
  await sendWelcomeEmail(user.email); // external call
  await tx.user.update({ where: { id }, data: { emailSent: true } });
});

// GOOD: external calls outside the transaction
const user = await prisma.user.findUniqueOrThrow({ where: { id } });
await sendWelcomeEmail(user.email);
await prisma.user.update({ where: { id }, data: { emailSent: true } });

// Only raise timeout when bulk processing genuinely needs it
await prisma.$transaction(async (tx) => { ... }, { timeout: 30_000 });
```

### `migrate dev` can reset the database

`migrate dev` detects schema drift and may prompt to reset the DB, dropping all data.

`migrate dev` is for an isolated development database and can request a destructive reset. `migrate deploy` applies migrations and is not universally safe. `migrate diff` flags vary by version, and comparisons involving migrations may use and mutate a shadow database. Treat all migration/shadow-database commands as separately authorized work, with exact target verification, backups, lock budgets, and rollback planning.

### Applied Migrations and Staged Schema Changes

Applied migration history is checked against recorded checksums. Do not rewrite an already-applied migration to conceal drift. Exact errors depend on the CLI and command; `P3006` specifically concerns applying a migration to a shadow database, not a universal checksum error.

Review expand-and-contract changes as a plan: add a compatible nullable field, migrate callers, define resumable backfill and accounting, validate data, then propose constraints/removal. No phase is automatically run by loading this skill.

### `@updatedAt` Is Client-Managed

Do not assume `updateMany` leaves timestamps stale; Prisma versions can populate `@updatedAt` on bulk writes. Inspect the installed client contract and representative supplied results. Raw SQL and other clients do not receive Prisma's client-managed behavior. Use an explicit domain timestamp when business semantics require one and account for empty-update behavior.

### Soft delete + `findUniqueOrThrow` leaks deleted records

`findUniqueOrThrow` throws `P2025` only when the row does not exist in the DB. Soft-deleted rows still exist and are returned without error.

Modern Prisma versions allow extra non-unique filters alongside a unique field in `WhereUniqueInput`. Older generated clients may reject them. Use the installed generated type; both paths must enforce tenant and soft-delete policy.

```ts
// BAD: returns soft-deleted user
const user = await prisma.user.findUniqueOrThrow({ where: { id } });

// Supported by modern generated clients; confirm installed version/type.
const user = await prisma.user.findUniqueOrThrow({ where: { id, deletedAt: null } });

// GOOD: findFirstOrThrow supports arbitrary where conditions
const user = await prisma.user.findFirstOrThrow({ where: { id, deletedAt: null } });
```

### `deleteMany` without `where` deletes every row

```ts
// BAD: silently wipes the table
await prisma.post.deleteMany();

// GOOD
await prisma.post.deleteMany({ where: { authorId: userId } });
```

## Best Practices

| Rule | Reason |
|---|---|
| `migrate deploy` in CI/CD, `migrate dev` only locally | `migrate dev` can reset the DB on drift |
| Map entities to response DTOs | Prevents leaking internal fields |
| Catch `PrismaClientKnownRequestError` at service boundary | Translate to domain errors |
| Prefer `*OrThrow` methods over manual null checks | Throws P2025 automatically; use `findFirstOrThrow` when filtering non-unique fields |
| Bound aggregate pool capacity across instances | Configure the active engine or driver adapter, not unsupported URL parameters |
| Always provide `where` on `deleteMany` | Prevents accidental table wipe |
| Confirm client-managed timestamp behavior | Raw SQL/external writers differ; blanket bulk-write claims are incorrect |

## Optional Related Guidance

- `ecc-nestjs-patterns` (optional skill; if unavailable, follow existing NestJS module, provider, and exception boundaries).
- `ecc-postgres-patterns` (optional skill; if unavailable, review PostgreSQL query plans, indexes, transactions, and connection limits from supplied evidence).
- `ecc-database-migrations` (optional skill; if unavailable, review lock risk, expand-and-contract phases, backup, and rollback without running migrations).


