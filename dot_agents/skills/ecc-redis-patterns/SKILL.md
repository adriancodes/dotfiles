---
name: ecc-redis-patterns
description: "Use when adding caching, a distributed lock, rate limiting, or pub/sub with Redis, or when key design needs review."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/redis-patterns/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for redis patterns; adapted for explicit local scope and evidence-backed use."
---

# Redis Patterns — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Redis Patterns

Quick reference for Redis best practices across common backend use cases.

## How It Works

Redis is an in-memory data structure store that supports strings, hashes, lists, sets, sorted sets, streams, and more. Individual Redis commands are atomic on a single instance; multi-step workflows require Lua scripts, MULTI/EXEC transactions, or explicit synchronization to stay atomic. Data is optionally persisted via RDB snapshots or AOF logs. Clients communicate over TCP using the RESP protocol; connection pools are essential to avoid per-request handshake overhead.

## When to Activate

- Adding caching to an application
- Implementing rate limiting or throttling
- Building distributed locks or coordination
- Setting up session or token storage
- Using Pub/Sub or Redis Streams for messaging
- Configuring Redis in production (pooling, eviction, clustering)

## Data Structure Cheat Sheet

| Use Case | Structure | Example Key |
|----------|-----------|-------------|
| Simple cache | String | `product:123` |
| User session | Hash | `session:abc` |
| Leaderboard | Sorted Set | `scores:weekly` |
| Unique visitors | Set | `visitors:2024-01-01` |
| Activity feed | List | `feed:user:456` |
| Event stream | Stream | `events:orders` |
| Counters / rate limits | String (INCR) | `ratelimit:user:123` |
| Approximate distinct count | HyperLogLog | `hll:pageviews` |

## Core Patterns

### Cache-Aside (Lazy Loading)

```python
import redis
import json

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

def get_product(product_id: int):
    cache_key = f"product:{product_id}"
    cached = r.get(cache_key)

    if cached is not None:
        return json.loads(cached)

    product = db.query("SELECT * FROM products WHERE id = %s", product_id)
    r.setex(cache_key, 3600, json.dumps(product))  # TTL: 1 hour
    return product
```

### Database-First Cache Update

```python
def update_product(product_id: int, data: dict):
    # Commit the DB write first; the cache is not in the database transaction.
    db.execute("UPDATE products SET ... WHERE id = %s", product_id)

    # Cache failure after commit must not be misreported as a rolled-back DB write.
    cache_key = f"product:{product_id}"
    r.setex(cache_key, 3600, json.dumps(data))
```

This does not provide strong consistency: a racing reader can write stale data after the database commit. Use a versioned key, invalidation/outbox protocol, or a database read when the contract requires read-after-write consistency.

### Cache Invalidation

```python
# Tag-based invalidation — group related keys under a set
def cache_product(product_id: int, category_id: int, data: dict):
    key = f"product:{product_id}"
    tag = f"tag:category:{category_id}"
    pipe = r.pipeline(transaction=True)
    pipe.setex(key, 3600, json.dumps(data))
    pipe.sadd(tag, key)
    pipe.expire(tag, 3600)
    pipe.execute()

def invalidate_category(category_id: int):
    tag = f"tag:category:{category_id}"
    keys = r.smembers(tag)
    if keys:
        r.delete(*keys)
    r.delete(tag)
```

### Session Storage

```python
import time
import uuid

def create_session(user_id: int, ttl: int = 86400) -> str:
    session_id = str(uuid.uuid4())
    key = f"session:{session_id}"
    pipe = r.pipeline(transaction=True)
    pipe.hset(key, mapping={
        "user_id": user_id,
        "created_at": int(time.time()),
    })
    pipe.expire(key, ttl)
    pipe.execute()
    return session_id

def get_session(session_id: str) -> dict | None:
    data = r.hgetall(f"session:{session_id}")
    return data if data else None

def delete_session(session_id: str):
    r.delete(f"session:{session_id}")
```

## Rate Limiting

### Fixed Window (Simple)

```python
def is_rate_limited(user_id: int, limit: int = 100, window: int = 60) -> bool:
    key = f"ratelimit:{user_id}:{int(time.time()) // window}"
    pipe = r.pipeline(transaction=True)
    pipe.incr(key)
    pipe.expire(key, window)
    count, _ = pipe.execute()
    return count > limit
```

### Sliding Window (Lua — Atomic)

The entire script uses one Redis key, so it does not accidentally cross Redis Cluster slots. Pass a unique request member from the caller; timestamps alone collide. The clock is caller-supplied and must be trustworthy. Exact distributed rate-limiting semantics require clock and failure-mode design.

```python
import time
import uuid

SLIDING_WINDOW_LUA = """
local key = KEYS[1]
local now = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local limit = tonumber(ARGV[3])
redis.call('ZREMRANGEBYSCORE', key, '-inf', now - window)
if redis.call('ZCARD', key) >= limit then
    return 0
end
redis.call('ZADD', key, now, ARGV[4])
redis.call('PEXPIRE', key, window)
return 1
"""

def allow_request(client, user_id: int, window_ms: int = 60_000, limit: int = 100) -> bool:
    if window_ms <= 0 or limit <= 0:
        raise ValueError("window_ms and limit must be positive")
    return bool(client.eval(
        SLIDING_WINDOW_LUA, 1, f"ratelimit:sliding:{user_id}",
        int(time.time() * 1000), window_ms, limit, uuid.uuid4().hex,
    ))
```

This is a reference function, not permission to connect to Redis. No external `sliding_window.lua` file is required.

## Distributed Locks

### Distributed Lock (Single Node — SET NX PX)

```python
import uuid

def acquire_lock(resource: str, ttl_ms: int = 5000) -> str | None:
    lock_key = f"lock:{resource}"
    token = str(uuid.uuid4())
    acquired = r.set(lock_key, token, px=ttl_ms, nx=True)
    return token if acquired else None

def release_lock(resource: str, token: str) -> bool:
    release_script = """
    if redis.call('get', KEYS[1]) == ARGV[1] then
        return redis.call('del', KEYS[1])
    else
        return 0
    end
    """
    result = r.eval(release_script, 1, f"lock:{resource}", token)
    return bool(result)

# Usage
token = acquire_lock("order:payment:123")
if token:
    try:
        process_payment()
    finally:
        release_lock("order:payment:123", token)
```

> A lease can expire while its owner is still running, and failover may lose a lock write. Do not use this as an exactly-once payment guarantee. Use idempotency and fencing at the protected resource where correctness depends on exclusivity; evaluate any multi-node lock algorithm against its failure assumptions rather than automatically installing Redlock.

## Pub/Sub & Streams

### Pub/Sub (Fire-and-Forget)

```python
# Publisher
def publish_event(channel: str, payload: dict):
    r.publish(channel, json.dumps(payload))

# Subscriber (blocking — run in separate thread/process)
def subscribe_events(channel: str):
    pubsub = r.pubsub()
    pubsub.subscribe(channel)
    for message in pubsub.listen():
        if message['type'] == 'message':
            handle(json.loads(message['data']))
```

### Redis Streams (Durable Queue)

```python
# Producer
def emit(stream: str, event: dict):
    r.xadd(stream, event, maxlen=10000)  # Cap stream length

# Consumer group example; durable recovery also needs persistence and pending-entry reclaim.
try:
    r.xgroup_create('events:orders', 'processor', id='0', mkstream=True)
except redis.ResponseError as exc:
    if not str(exc).startswith("BUSYGROUP"):
        raise

def consume(stream: str, group: str, consumer: str):
    while True:
        messages = r.xreadgroup(group, consumer, {stream: '>'}, count=10, block=2000)
        for _, entries in (messages or []):
            for msg_id, data in entries:
                process(data)
                r.xack(stream, group, msg_id)
```

> Streams supports persisted history and consumer groups. Specify persistence/replication, idempotent processing, pending-entry recovery (`XAUTOCLAIM` where supported), and retention before claiming at-least-once delivery. Trimming can remove entries still needed by a lagging consumer.

## Key Design

### Naming Conventions

```
# Pattern: resource:id:field
user:123:profile
order:456:status
cache:product:789

# Pattern: namespace:resource:id
myapp:session:abc123
myapp:ratelimit:user:123

# Pattern: resource:date (time-bound keys)
stats:pageviews:2024-01-01
```

### TTL Strategy

| Data Type | Suggested TTL |
|-----------|--------------|
| User session | 24h (`86400`) |
| API response cache | 5–15 min |
| Rate limit window | Match window size |
| Short-lived tokens | 5–10 min |
| Leaderboard | 1h–24h |
| Static/reference data | 1h–1 week |

Set TTL or another bounded retention policy for caches and ephemeral state. Durable queues, coordination state, and canonical records may intentionally have no TTL; give them explicit retention and capacity policies.

## Connection Management

### Connection Pooling

```python
from redis import ConnectionPool, Redis

pool = ConnectionPool(
    host='localhost',
    port=6379,
    db=0,
    max_connections=20,
    decode_responses=True,
    socket_connect_timeout=2,
    socket_timeout=2,
)

r = Redis(connection_pool=pool)
```

### Cluster Mode

```python
from redis.cluster import RedisCluster, ClusterNode

r = RedisCluster(
    startup_nodes=[ClusterNode("redis-1", 6379)],
    decode_responses=True,
    require_full_coverage=True,
)
```

### Sentinel (High Availability)

```python
from redis.sentinel import Sentinel

sentinel = Sentinel(
    [('sentinel-1', 26379), ('sentinel-2', 26379)],
    socket_timeout=0.5,
)
master = sentinel.master_for('mymaster', decode_responses=True)
replica = sentinel.slave_for('mymaster', decode_responses=True)
```

## Eviction Policies

| Policy | Behavior | Best For |
|--------|----------|----------|
| `noeviction` | Error on write when full | Queues / critical data |
| `allkeys-lru` | Evict least recently used | General cache |
| `volatile-lru` | LRU only among keys with TTL | Mixed data store |
| `allkeys-lfu` | Evict least frequently used | Skewed access patterns |
| `volatile-ttl` | Evict soonest-to-expire | Prioritize long-lived data |

Set via `redis.conf`: `maxmemory-policy allkeys-lru`

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Unbounded ephemeral keys | Memory grows unbounded | Set TTL or bounded retention |
| `KEYS *` in production | Blocks the server (O(N)) | Use `SCAN` cursor |
| Storing large blobs (>100KB) | Slow serialization, memory pressure | Store reference + fetch from object store |
| Single Redis for everything | Eviction and resource contention between cache & queue | Use separate instances for failure/resource isolation; logical DBs do not isolate memory |
| Ignoring connection pool limits | Connection exhaustion under load | Size pool to workload |
| Not handling cache miss stampede | Thundering herd on cold start | Use locks or probabilistic early expiry |
| `FLUSHALL` without thought | Wipes entire instance | Scope deletes by key pattern |

### Cache Miss Stampede Prevention

```python
import threading
import json

# Fixed stripes bound lock memory; distinct keys may share a lock.
_locks = tuple(threading.Lock() for _ in range(64))

def get_with_lock(client, key: str, fetch_fn, ttl: int = 300):
    cached = client.get(key)
    if cached is not None:
        return json.loads(cached)
    with _locks[hash(key) % len(_locks)]:
        cached = client.get(key)
        if cached is not None:
            return json.loads(cached)
        value = fetch_fn()
        client.setex(key, ttl, json.dumps(value))
        return value
```

This coalesces work only within one process. For multiple processes, review leases, bounded wait/retry, failure behavior, and fencing requirements rather than assuming a lock automatically makes the data consistent.

## Examples

**Add caching to a Django/Flask API endpoint:**
Use cache-aside with `setex` and a 5-minute TTL on the response. Key on the request parameters.

**Rate-limit an API by user:**
Use fixed-window with `pipeline(transaction=True)` for low-traffic endpoints; use sliding-window Lua for accurate per-user throttling.

**Coordinate a background job across workers:**
Use `acquire_lock` with a TTL that exceeds the expected job duration. Always release in a `finally` block.

**Fan-out notifications to multiple subscribers:**
Use Pub/Sub when loss is acceptable. For Streams, define durability, pending recovery, idempotency, and retention before relying on replay.

## Quick Reference

| Pattern | When to Use |
|---------|-------------|
| Cache-aside | Read-heavy, tolerate slight staleness |
| Database-first cache update | Bounded staleness acceptable; does not atomically commit DB and cache |
| Distributed lock | Prevent concurrent access to a resource |
| Sliding window rate limit | Accurate per-user throttling |
| Redis Streams | Durable event queue with consumer groups |
| Pub/Sub | Broadcast with no delivery guarantees needed |
| Sorted Set leaderboard | Ranked scoring, pagination |
| HyperLogLog | Approximate unique count at low memory |

## Optional Related Guidance

- `ecc-postgres-patterns` (optional skill; if unavailable, review PostgreSQL query plans, indexes, transactions, and connection limits from supplied evidence).
- `ecc-django-patterns` (optional skill; if unavailable, follow the existing Django cache, ORM, and service boundaries).
- `ecc-database-migrations` (optional skill; if unavailable, review lock risk, expand-and-contract phases, backup, and rollback without running migrations).
- `ecc-database-reviewer` (optional skill; if unavailable, review schema, transaction, indexing, and least-privilege evidence).


