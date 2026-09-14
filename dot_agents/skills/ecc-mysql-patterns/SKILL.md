---
name: ecc-mysql-patterns
description: "Use when designing MySQL or MariaDB schemas and indexes, or when a query, transaction, or replica lags."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/mysql-patterns/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for mysql patterns; adapted for explicit local scope and evidence-backed use."
---

# Mysql Patterns — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# MySQL Patterns

Use this skill when working on MySQL or MariaDB schema design, migrations,
slow-query investigation, queue-style transactions, connection pools, or
production database configuration. Prefer exact version checks before applying a
feature-specific pattern because MySQL and MariaDB have diverged in several SQL
details.

## Activation

- Designing MySQL or MariaDB tables, indexes, and constraints
- Reviewing migrations before they run on large production tables
- Debugging slow queries, lock waits, deadlocks, or connection exhaustion
- Adding keyset pagination, upserts, full-text search, JSON columns, or queues
- Configuring application connection pools, read replicas, TLS, or slow logs

## Version Check

Identify the engine/version from local configuration or request this redacted caller-provided output; do not connect to a database to obtain it:

```sql
SELECT VERSION();
SHOW VARIABLES LIKE 'version_comment';
```

Keep MySQL and MariaDB guidance separate when syntax differs:

- MySQL documents row aliases as the replacement for `VALUES(col)` in
  `ON DUPLICATE KEY UPDATE`; `VALUES(col)` is deprecated there.
- MariaDB documents `VALUES(col)` as the supported way to reference inserted
  values in `ON DUPLICATE KEY UPDATE`; use it for cross-engine compatibility.
- `SKIP LOCKED` is appropriate for queue-like work only. It skips locked rows
  and can return an inconsistent view, so do not use it for general accounting
  or integrity-sensitive reads.

## Schema Defaults

```sql
CREATE TABLE orders (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    account_id BIGINT UNSIGNED NOT NULL,
    status VARCHAR(32) NOT NULL,
    total DECIMAL(15, 2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    PRIMARY KEY (id),
    KEY idx_orders_account_status_created (account_id, status, created_at),
    KEY idx_orders_active (account_id, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

Default choices:

| Use Case | Prefer | Avoid |
| --- | --- | --- |
| Surrogate primary keys | `BIGINT UNSIGNED AUTO_INCREMENT` | `INT` for tables that can grow beyond 2B rows |
| UUID lookup keys | `BINARY(16)` with conversion helpers | `VARCHAR(36)` primary keys on hot tables |
| Money and exact quantities | `DECIMAL(p, s)` | `FLOAT` or `DOUBLE` |
| User-facing text | `utf8mb4` tables and indexes | MySQL `utf8` / `utf8mb3` defaults |
| Application timestamps | `DATETIME` with UTC managed by the app | Assuming `DATETIME` stores time zone metadata |
| Soft deletes | `deleted_at DATETIME NULL` plus scoped indexes | Filtering soft-deleted rows without an index |
| Extensible status values | lookup table or constrained `VARCHAR` | `ENUM` when values change often |

## Indexing

Composite index order usually follows equality predicates first, then range or
sort columns:

```sql
CREATE INDEX idx_orders_account_status_created
    ON orders (account_id, status, created_at);

SELECT id, total
FROM orders
WHERE account_id = ?
  AND status = 'pending'
  AND created_at >= ?
ORDER BY created_at DESC
LIMIT 50;
```

Review a caller-supplied `EXPLAIN` plan before recommending an index; the SQL below is an evidence request, not permission to execute:

```sql
EXPLAIN
SELECT id, total
FROM orders
WHERE account_id = 123 AND status = 'pending'
ORDER BY created_at DESC
LIMIT 50;
```

Signals to investigate:

| Field | Risk Signal |
| --- | --- |
| `type` | `ALL` on a large table |
| `key` | `NULL` when a selective predicate exists |
| `rows` | Very high row estimate for an interactive path |
| `Extra` | `Using temporary`, `Using filesort`, or broad `Using where` |

Avoid adding indexes blindly. Each index increases write cost, migration time,
backup size, and buffer-pool pressure.

## Query Patterns

### Upsert

Cross-engine-compatible form:

```sql
INSERT INTO user_settings (user_id, setting_key, setting_value)
VALUES (?, ?, ?)
ON DUPLICATE KEY UPDATE
    setting_value = VALUES(setting_value),
    updated_at = CURRENT_TIMESTAMP;
```

MySQL row-alias form:

```sql
INSERT INTO user_settings (user_id, setting_key, setting_value)
VALUES (?, ?, ?) AS new
ON DUPLICATE KEY UPDATE
    setting_value = new.setting_value,
    updated_at = CURRENT_TIMESTAMP;
```

Use the row-alias form only after confirming the target is MySQL. Use
`VALUES(col)` for MariaDB or mixed MySQL/MariaDB fleets.

### Keyset Pagination

```sql
SELECT id, name, created_at
FROM products
WHERE (created_at, id) < (?, ?)
ORDER BY created_at DESC, id DESC
LIMIT 50;
```

Back it with an index that matches the cursor:

```sql
CREATE INDEX idx_products_created_id ON products (created_at, id);
```

Do not use deep `OFFSET` pagination on large tables; it makes the server scan
and discard rows before returning the page.

### JSON Fields

Use JSON columns for extension data, not for fields that need heavy relational
filtering or constraints.

```sql
CREATE TABLE events (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payload JSON NOT NULL,
    event_type VARCHAR(64)
        GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(payload, '$.type'))) STORED,
    KEY idx_events_type (event_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

For frequently queried JSON paths, expose a generated column and index that
column. Keep foreign keys, ownership, tenancy, and lifecycle fields relational.

### Full-Text Search

```sql
ALTER TABLE articles ADD FULLTEXT KEY ft_articles_title_body (title, body);

SELECT id, title, MATCH(title, body) AGAINST (? IN NATURAL LANGUAGE MODE) AS score
FROM articles
WHERE MATCH(title, body) AGAINST (? IN NATURAL LANGUAGE MODE)
ORDER BY score DESC
LIMIT 20;
```

Use external search when you need typo tolerance, complex ranking, cross-table
facets, or language-specific analysis beyond built-in full-text behavior.

## Transactions

Keep transactions short and lock rows in a consistent order:

```sql
START TRANSACTION;

SELECT id, balance
FROM accounts
WHERE id IN (?, ?)
ORDER BY id
FOR UPDATE;

UPDATE accounts SET balance = balance - ? WHERE id = ?;
UPDATE accounts SET balance = balance + ? WHERE id = ?;

COMMIT;
```

Deadlock and lock-wait checklist:

- Lock rows in a deterministic order across code paths.
- Do external API calls before opening the transaction, not inside it.
- Add indexes for predicates used in `UPDATE`, `DELETE`, and locking reads.
- On deadlock, roll back and retry the whole transaction with a bounded retry
  budget.
- Capture `SHOW ENGINE INNODB STATUS\G` soon after a deadlock; it is overwritten
  by later events.

Queue-style worker claim:

```sql
START TRANSACTION;

SELECT id
FROM jobs
WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;

UPDATE jobs
SET status = 'processing', started_at = CURRENT_TIMESTAMP
WHERE id = ?;

COMMIT;
```

Use `SKIP LOCKED` only for queue-like workloads where skipping a locked row is
acceptable. It is not a replacement for normal transactional consistency.

## Connection Pools

SQLAlchemy example:

```python
import os
from sqlalchemy import create_engine

engine = create_engine(
    os.environ["DATABASE_URL"],
    pool_size=10,
    max_overflow=5,
    pool_timeout=30,
    pool_recycle=240,
    pool_pre_ping=True,
    connect_args={"connect_timeout": 5},
)
```

Node.js `mysql2` example:

```javascript
import mysql from 'mysql2/promise';

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 100,  // Example bounded admission queue; size to timeout and load budget.
  enableKeepAlive: true,
  keepAliveInitialDelay: 30000,
});

const [rows] = await pool.execute(
  'SELECT id, total FROM orders WHERE account_id = ? LIMIT 50',
  [accountId],
);
```

Keep application pool recycling below the server `wait_timeout`. If the server
uses `wait_timeout = 300`, a `pool_recycle` around 240 seconds is coherent;
`pool_pre_ping` still helps recover from network and failover events.

## Diagnostics

Request narrowly scoped caller-provided results from these diagnostic references; process lists and deadlock output can contain sensitive query text:

```sql
SHOW FULL PROCESSLIST;
SHOW ENGINE INNODB STATUS\G;
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';
```

Changing global slow-log settings is an administrative action, not part of this skill. Review supplied settings and propose a bounded sampling/retention plan only when requested. Logging every non-indexed query can be noisy and expose sensitive statements.



Use `EXPLAIN ANALYZE` only when it is safe to execute the query. It runs the
statement and can be expensive on production-sized data.

## Replication

Read replicas can lag. Do not route read-your-own-write paths, checkout flows,
permission checks, or idempotency-key reads to a replica immediately after a
write.

```sql
-- MySQL legacy terminology, still common in existing fleets
SHOW SLAVE STATUS\G;

-- Newer terminology where supported
SHOW REPLICA STATUS\G;
```

Check the engine/version before standardizing on one command. Monitor replica
SQL thread health, IO thread health, and lag, not just whether the TCP
connection is alive.

## Security

Review supplied grants rather than issuing account-management SQL. A proposed runtime account should be restricted to the actual application host/network, required tables and verbs, and TLS. Anonymous-account removal, account creation, privilege changes, and authentication-plugin changes belong to a separately authorized administration plan; never execute them from review guidance.

Security review points:

- Do not grant `ALL PRIVILEGES` or `*.*` to application users.
- Require TLS for application users when traffic crosses hosts or networks.
- Store credentials in the platform secret manager, not in examples, scripts, or
  repository files.
- Separate migration/admin users from runtime application users.
- Audit public network exposure and bind addresses before tuning performance.

## Configuration

Example starting point for a dedicated database host:

```ini
[mysqld]
innodb_buffer_pool_size = 4G
innodb_flush_log_at_trx_commit = 1
sync_binlog = 1

max_connections = 300
thread_cache_size = 50

wait_timeout = 300
interactive_timeout = 300
innodb_lock_wait_timeout = 10

slow_query_log = ON
long_query_time = 1
log_queries_not_using_indexes = OFF  # Opt in only for a bounded, privacy-reviewed investigation.

log_bin = mysql-bin
binlog_format = ROW
binlog_expire_logs_seconds = 604800
```

Treat configuration values as a prompt for review, not a universal preset. Size
memory, connections, log retention, and durability settings from workload,
hardware, backup policy, and recovery objectives.

## Anti-Patterns

| Anti-Pattern | Risk | Better Pattern |
| --- | --- | --- |
| `SELECT *` in hot paths | Over-fetching and brittle clients | Select explicit columns |
| Deep `OFFSET` pagination | Linear scans and slow pages | Keyset pagination |
| No index on foreign-key joins | Slow joins and lock-heavy deletes | Index FK columns intentionally |
| Long transactions | Lock waits and large undo history | Commit small units of work |
| Direct DML against `mysql.user` | Grant-table corruption risk | Use `CREATE USER`, `ALTER USER`, `DROP USER` |
| Application user with admin grants | High blast radius | Least-privilege runtime user |
| Pool recycle above `wait_timeout` | Stale pooled connections | Recycle below timeout and pre-ping |
| Replica reads after writes | Stale user-facing state | Pin read-after-write flows to primary |

## Output Expectations

When this skill is used for review, return:

1. Engine/version assumptions.
2. Evidence-backed correctness, lock, security, and proposed migration issues.
3. Exact SQL or code changes for the safe path.
4. Validation plan: `EXPLAIN`, migration dry run, lock/deadlock check, and
   rollback criteria.
5. Any MySQL/MariaDB syntax differences that affect the recommendation.

## Optional Related Guidance

- `ecc-postgres-patterns` (optional skill; if unavailable, review PostgreSQL query plans, indexes, transactions, and connection limits from supplied evidence).
- `ecc-database-migrations` (optional skill; if unavailable, review lock risk, expand-and-contract phases, backup, and rollback without running migrations).
- `ecc-database-reviewer` (optional skill; if unavailable, review schema, transaction, indexing, and least-privilege evidence).
- Without another security skill, inspect secret sources, client TLS verification, network exposure, and least-privilege grants.


