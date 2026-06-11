markdown# ElastiCache — Redis Replication Group

## What is ElastiCache?

ElastiCache is AWS's managed in-memory data store service. "In-memory" means data lives in RAM rather than on disk — RAM operates in microseconds while disk operates in milliseconds. That speed difference is why caching dramatically reduces application response times.

Instead of hitting your database every time a user requests the same data, your application checks Redis first. If the data is there (a cache hit), it returns instantly. If it's not (a cache miss), the app fetches from the database and stores the result in Redis for next time.

## Why Redis over Memcached?

ElastiCache supports two engines. Redis is almost always the right choice for production workloads.

| Feature | Redis | Memcached |
|---|---|---|
| Data structures | Strings, lists, sets, hashes, sorted sets | Strings only |
| Persistence | Yes — survives restarts | No |
| Replication | Yes — primary + replicas | No |
| Multi-AZ failover | Yes — automatic | No |
| Use case | Caching, sessions, leaderboards, queues | Simple object caching only |

Choose Memcached only when you need horizontal scaling of simple key-value data and don't need HA.

## Architecture
Internet
↓
ALB
↓
EC2 (App Layer)
↓         ↓
Redis      RDS
(Cache)  (Database)

Your application checks Redis before hitting RDS. Cache hits return in under 1ms. Cache misses fall through to RDS and the result gets stored in Redis for subsequent requests.

## Key Concepts

### Replication Group
The actual Redis cluster. Manages primary and replica nodes, automatic failover, and Multi-AZ deployment. Despite the name it handles both standalone and replicated setups.

### Primary vs Replica
- **Primary node** — handles all write operations
- **Replica node** — handles read operations, promoted to primary on failover
- Your app should write to the primary endpoint and read from the reader endpoint

### Automatic Failover
When Multi-AZ and automatic failover are enabled, ElastiCache detects primary node failure and promotes a replica within 60 seconds. Your application reconnects automatically.

### Subnet Group
Tells ElastiCache which subnets to deploy nodes into. Always use private subnets — Redis should never be directly accessible from the internet.

### Parameter Group
A collection of configuration settings attached to your cluster. Key parameter for caching workloads is `maxmemory-policy` which controls what happens when Redis runs out of memory.

## Memory Eviction Policies

| Policy | Behavior | Use When |
|---|---|---|
| `allkeys-lru` | Evict least recently used keys | General caching — recommended default |
| `volatile-lru` | Evict LRU keys with expiry set | Mixed cache and persistent data |
| `allkeys-lfu` | Evict least frequently used keys | Access patterns are highly skewed |
| `noeviction` | Return error when memory full | You never want data silently dropped |

For most caching workloads use `allkeys-lru`. Data that hasn't been accessed recently is the least valuable.

## Node Types

| Type | vCPU | Memory | Use Case |
|---|---|---|---|
| `cache.t3.micro` | 2 | 0.5 GB | Development only |
| `cache.t3.medium` | 2 | 3.2 GB | Small production |
| `cache.r6g.large` | 2 | 13.07 GB | Production workloads |
| `cache.r6g.xlarge` | 4 | 26.32 GB | High-traffic production |

R-series nodes are memory-optimized — the right choice for production Redis. T-series are burstable and fine for dev/staging.

## Security Considerations

- **Always deploy in private subnets** — Redis has no native authentication by default in older versions
- **Enable transit encryption** — encrypts data between your app and Redis
- **Enable at-rest encryption** — encrypts data stored on disk (Redis persistence files)
- **Security group** — restrict inbound port 6379 to your application security group only
- **Both encryption flags required** for PCI-DSS and HIPAA workloads

## Common Gotchas

**Connection strings change on failover** — use the primary endpoint address, not a node-specific endpoint. The primary endpoint always resolves to the current primary node.

**Redis is not a database** — don't store data in Redis that you can't afford to lose. It's a cache. Your source of truth is RDS.

**Cold start after deployment** — a new Redis cluster starts empty. Your first requests after deployment will all be cache misses and hit RDS. This is normal and the cache warms up over time.

**`num_cache_clusters` requires 2+ for automatic failover** — you cannot enable `automatic_failover_enabled = true` with only one node.

**Encryption requires AUTH token or Redis 6+ with TLS** — if you enable `transit_encryption_enabled` you may need to configure an auth token depending on your Redis version.

## Tips & Gotchas for the SAA Exam

- Redis supports Multi-AZ with automatic failover — Memcached does not
- ElastiCache reduces database load for read-heavy workloads
- Use Redis for session storage, leaderboards, and pub/sub messaging
- ElastiCache nodes live in your VPC — they are not publicly accessible
- Backup and restore is supported in Redis but not Memcached
- For the exam: "in-memory", "microsecond latency", "session store", "leaderboard" → Redis
