---
name: ecc-database-migrations
description: "Review database schema/data migrations for locking, constraint validation, backfill progress, rollback safety, and expand-contract ordering. Includes PostgreSQL-specific caveats; use when a change adds or alters a migration."
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/database-migrations/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  adaptation: local-portable-review
---

# Database Migration Patterns

Selected ECC migration safety guidance for static reviews and migration planning. Examples are not authorization to apply migrations or connect to production. Check the project's engine/version and migration runner; rollback may require a forward repair or restore rather than a reversible DOWN script.

## When to Activate

- Creating or altering database tables
- Adding/removing columns or indexes
- Running data migrations (backfill, transform)
- Planning zero-downtime schema changes
- Setting up migration tooling for a new project

## Core Principles

1. **Every change is a migration** — never alter production databases manually
2. **Migrations are forward-only in production** — rollbacks use new forward migrations
3. **Schema and data migrations are separate** — never mix DDL and DML in one migration
4. **Test migrations against production-sized data** — a migration that works on 100 rows may lock on 10M
5. **Migrations are immutable once deployed** — never edit a migration that has run in production

## Migration Safety Checklist

Before applying any migration:

- [ ] Migration has both UP and DOWN (or is explicitly marked irreversible)
- [ ] Required lock modes and wait times are understood; bound lock acquisition and avoid long exclusive locks on live tables
- [ ] Existing rows can satisfy new constraints; use nullable/backfill/validate steps where required
- [ ] Indexes created concurrently (not inline with CREATE TABLE for existing tables)
- [ ] Data backfill is a separate migration from schema change
- [ ] Tested against a copy of production data
- [ ] Rollback plan documented

## PostgreSQL Patterns

### Adding a Column Safely

```sql
-- Metadata-only change, but ALTER TABLE still requires an exclusive lock
ALTER TABLE users ADD COLUMN avatar_url TEXT;

-- Postgres 11+: constant default avoids a table rewrite, not lock acquisition
ALTER TABLE users ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true;

-- BAD for a populated table: existing rows would be NULL, so this fails
ALTER TABLE users ADD COLUMN role TEXT NOT NULL;
-- Add nullable, backfill, and validate a constraint before enforcing NOT NULL
```

### Adding an Index Without Downtime

```sql
-- BAD: Blocks writes on large tables
CREATE INDEX idx_users_email ON users (email);

-- Allows concurrent writes; still takes locks, waits for transactions, and adds load
CREATE INDEX CONCURRENTLY idx_users_email ON users (email);

-- Note: CONCURRENTLY cannot run inside a transaction block
-- Most migration tools need special handling for this
```

### Renaming a Column (Zero-Downtime)

When old and new application versions must coexist, use expand-contract rather than a direct rename:

```sql
-- Step 1: Add new column (migration 001)
ALTER TABLE users ADD COLUMN display_name TEXT;

-- Step 2: Deploy code that atomically writes BOTH columns; keep reading old
-- Step 3: Backfill in bounded batches and reconcile concurrent changes
-- Step 4: Switch reads to the new column; verify consistency
-- Step 5: Retire old application versions and stop using the old column
-- Step 6: Drop it in a separate migration after the rollback window
ALTER TABLE users DROP COLUMN username;
```

### Removing a Column Safely

```sql
-- Step 1: Remove all application references to the column
-- Step 2: Deploy application without the column reference
-- Step 3: Drop column in next migration
ALTER TABLE orders DROP COLUMN legacy_status;

-- For Django: use SeparateDatabaseAndState to remove from model
-- without generating DROP COLUMN (then drop in next migration)
```

### Large Data Migrations

Backfill in bounded, restartable transactions with an explicit progress marker. Check source NULL/empty values so a transformation cannot repeatedly select rows it cannot change. Rows skipped because they are locked are not proof that backfill is complete: reconcile after all workers finish. Respect the migration runner's transaction model; do not put a COMMIT loop inside a transaction-wrapped migration.

## Zero-Downtime Migration Strategy

For critical production changes, follow the expand-contract pattern:

```
Phase 1: EXPAND
  - Add new column/table (nullable or with default)
  - Deploy: app writes to BOTH old and new
  - Backfill existing data

Phase 2: MIGRATE
  - Deploy: app reads from NEW, writes to BOTH
  - Verify data consistency

Phase 3: CONTRACT
  - Deploy: app only uses NEW
  - Drop old column/table in separate migration
```

### Timeline Example

```
Day 1: Migration adds new_status column (nullable)
Day 1: Deploy app v2 — writes to both status and new_status
Day 2: Run backfill migration for existing rows
Day 3: Deploy app v3 — reads from new_status only
After all old readers/writers are retired and rollback window closes: drop old column
```

## Anti-Patterns

| Anti-Pattern | Why It Fails | Better Approach |
|-------------|-------------|-----------------|
| Manual SQL in production | No audit trail, unrepeatable | Always use migration files |
| Editing deployed migrations | Causes drift between environments | Create new migration instead |
| Adding NOT NULL column without a usable default to populated table | Existing rows violate constraint; operation fails | Add nullable, backfill, then validate/enforce constraint |
| Inline index on large table | Blocks writes during build | CREATE INDEX CONCURRENTLY |
| Schema + data in one migration | Hard to rollback, long transactions | Separate migrations |
| Dropping column before removing code | Application errors on missing column | Remove code first, drop column next deploy |

## PostgreSQL References

- https://www.postgresql.org/docs/current/ddl-alter.html
- https://www.postgresql.org/docs/current/sql-createindex.html

Concurrent index builds cannot run inside a transaction block. A failed build can leave an invalid index; inspect its definition and validity rather than treating `IF NOT EXISTS` as proof of success.

## Attribution

Adapted from ECC by Affaan Mustafa, revision `e04ea0b9cc8248686edf5ac751cadff550e162b8`. MIT license; see `LICENSE` in this directory. Local adaptations prioritize project contracts and evidence over blanket prescriptions.
