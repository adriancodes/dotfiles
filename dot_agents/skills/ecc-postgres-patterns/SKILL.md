---
name: ecc-postgres-patterns
description: "PostgreSQL database patterns for query optimization, schema design, indexing, and security. Based on Supabase best practices. Use when designing PostgreSQL schemas, indexes, or RLS policies, or when a query is too slow."
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/postgres-patterns/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  adaptation: local-portable-review
---

# PostgreSQL Patterns

Reference for static PostgreSQL reviews. Use the `ecc-database-reviewer` agent where subagents are supported, or the matching shared skill otherwise. Examples are not authorization to run SQL or change a live database. Validate recommendations against the project's PostgreSQL version, domain, and workload.

## When to Activate

- Writing SQL queries or migrations
- Designing database schemas
- Troubleshooting slow queries
- Implementing Row Level Security
- Setting up connection pooling

## Quick Reference

### Index Cheat Sheet

| Query Pattern | Index Type | Example |
|--------------|------------|---------|
| `WHERE col = value` | B-tree (default) | `CREATE INDEX idx ON t (col)` |
| `WHERE col > value` | B-tree | `CREATE INDEX idx ON t (col)` |
| `WHERE a = x AND b > y` | Composite | `CREATE INDEX idx ON t (a, b)` |
| `WHERE jsonb @> '{}'` | GIN | `CREATE INDEX idx ON t USING gin (col)` |
| `WHERE tsv @@ query` | GIN | `CREATE INDEX idx ON t USING gin (col)` |
| Ranges correlated with physical row order | BRIN | `CREATE INDEX idx ON t USING brin (col)` |

### Data Type Quick Reference

| Use Case | Common Choice | Considerations |
|----------|-------------|-------|
| IDs | `bigint` or `uuid` | Match domain/range and distributed-ID needs; existing IDs are not defects by default |
| Strings | `text` | `varchar(255)` |
| Instants | `timestamptz` | Use `timestamp` when a local wall-clock value is intended |
| Money | `numeric` or integer minor units | Choose scale/range from the domain; avoid floating-point rounding |
| Flags | `boolean` | `varchar`, `int` |

### Common Patterns

**Composite Index Order:**
```sql
-- Equality columns first, then range columns
CREATE INDEX idx ON orders (status, created_at);
-- Works for: WHERE status = 'pending' AND created_at > '2024-01-01'
```

**Covering Index:**
```sql
CREATE INDEX idx ON users (email) INCLUDE (name, created_at);
-- Can enable index-only scans when visibility-map and query conditions allow
```

**Partial Index:**
```sql
CREATE INDEX idx ON users (email) WHERE deleted_at IS NULL;
-- Smaller index, only includes active users
```

**RLS Policy (Optimized):**
```sql
-- Supabase-specific identity function and role; adapt to the application.
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY policy ON orders TO authenticated
  USING ((SELECT auth.uid()) = user_id);
-- Also inspect ownership/BYPASSRLS and other policies; this alone is not an isolation proof.
```

**UPSERT:**
```sql
INSERT INTO settings (user_id, key, value)
VALUES (123, 'theme', 'dark')
ON CONFLICT (user_id, key)
DO UPDATE SET value = EXCLUDED.value;
```

**Cursor Pagination:**
```sql
SELECT * FROM products WHERE id > $last_id ORDER BY id LIMIT 20;
-- Uses an indexed seek plus page scan; avoids scanning all skipped OFFSET rows
```

**Queue Processing:**
```sql
UPDATE jobs SET status = 'processing'
WHERE id = (
  SELECT id FROM jobs WHERE status = 'pending'
  ORDER BY created_at LIMIT 1
  FOR UPDATE SKIP LOCKED
) RETURNING *;
```

### Anti-Pattern Detection

```sql
-- Candidate check only: verify column order, composite coverage, validity,
-- and partial-index predicates before concluding a foreign key lacks an index
SELECT conrelid::regclass, a.attname
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
WHERE c.contype = 'f'
  AND NOT EXISTS (
    SELECT 1 FROM pg_index i
    WHERE i.indrelid = c.conrelid AND a.attnum = ANY(i.indkey)
  );

-- Find slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC;

-- Inspect dead-tuple estimates (not a measurement of physical table bloat)
SELECT relname, n_dead_tup, last_vacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
```

### Configuration Review

Inspect connection budgets, memory per operation, transaction/statement timeouts, and monitoring access against actual concurrency and deployment constraints. Do not apply generic `ALTER SYSTEM` settings, install extensions, or revoke privileges during review.

## Related

- `ecc-database-reviewer`: full static database review, available as both a skill and supported-harness agent.
- `ecc-database-migrations`: migration safety and expand-contract checklist.

---

*Based on Supabase Agent Skills (credit: Supabase team) (MIT License)*

## Attribution

Adapted from ECC by Affaan Mustafa, revision `e04ea0b9cc8248686edf5ac751cadff550e162b8`. MIT license; see `LICENSE` in this directory. Local adaptations prioritize project contracts and evidence over blanket prescriptions.
