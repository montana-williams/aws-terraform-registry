# RDS — Relational Database Service

## What is RDS?

RDS is AWS's managed relational database service. It holds structured data that needs to be queried — think purchase orders, customer records, medical history, financial transactions. Data that fits neatly into rows and columns with defined relationships between tables.

You'd pick it over running a database on EC2 because AWS handles everything underneath — patching, backups, replication, and failover — so you can focus on building your application instead of babysitting a database server.

## SQL vs NoSQL

RDS is a **SQL database** — relational, structured, every row fits the same mold. Think of it like a spreadsheet where every row has the same columns.

**NoSQL** (like DynamoDB) is the opposite — flexible structure, each record can look completely different. Think folders of sticky notes, each one configured differently.

Use RDS when your data is structured and predictable with relationships between tables. Use NoSQL when your data is flexible, variable, or needs extreme read/write speed at scale.

## Supported engines

| Engine | When to use |
|---|---|
| MySQL | Most common, open source, huge community |
| PostgreSQL | More powerful than MySQL, better for complex queries |
| MariaDB | Open source MySQL fork, nearly identical to MySQL |
| Oracle | Enterprise and legacy systems |
| Microsoft SQL Server | Enterprise, Windows heavy environments |
| Aurora (MySQL) | AWS optimized, up to 5x faster than MySQL, multi-AZ by default |
| Aurora (PostgreSQL) | AWS optimized, up to 3x faster than PostgreSQL, multi-AZ by default |

**Aurora** is worth calling out — it's AWS's own engine that runs on RDS. Built for cloud scale, automatically replicates across 3 AZs, and handles failover in under 30 seconds. If you're building on AWS and don't have a reason to pick vanilla MySQL or PostgreSQL, Aurora is the default choice.

## Key concepts

### Managed service
AWS handles:
- OS and database engine patching
- Automated backups
- Storage scaling
- Replication
- Failover

You connect to it and use it. No SSH, no manual snapshot scripts, no configuring replication yourself.

### Scaling
**Storage** — automatic. RDS Auto Scaling expands storage on its own when you're running low. Set it and forget it.

**CPU and memory** — manual vertical scaling. If your database needs more compute power you resize the instance type. This is called vertical scaling — scaling up the size of one resource rather than adding more of them.

### Read Replicas
A separate copy of your database that handles read traffic. Use when your app has heavy read workloads hammering the primary instance.

- Your app points write queries at the primary
- Your app points read queries at the replica
- Instead of 10,000 reads hitting one instance you split the load

Read replicas are for **performance** — not failover.

### Multi-AZ
A silent standby instance in a different Availability Zone that mirrors your primary database. If the primary goes down AWS automatically promotes the standby and your app reconnects. No manual intervention.

Multi-AZ is for **availability** — not performance. The standby doesn't serve any traffic until failover.

| | Read Replica | Multi-AZ |
|---|---|---|
| Purpose | Performance | Availability |
| Serves traffic | Yes — read queries | No — standby only |
| Failover | No | Yes — automatic |
| Use case | Offload read traffic | Survive AZ failure |

### Backups
RDS takes automated daily backups and stores them in S3. You set a retention period (1-35 days) and can restore to any point in time within that window. You can also take manual snapshots that persist until you delete them.

## When would you use RDS?

- Structured data with relationships between tables
- Applications that need ACID compliance (financial, healthcare, e-commerce)
- Any compliance requirement — HIPAA, PCI-DSS
- When you want a managed database without the operational overhead of running it yourself

## Tips & gotchas

- **Always put RDS in private subnets.** It should never be directly reachable from the internet.
- **Use security group chaining.** Only allow traffic from your app security group on the database port — never open to `0.0.0.0/0`.
- **Enable Multi-AZ in production.** Single AZ RDS is a single point of failure.
- **Enable automated backups.** Set a retention period that matches your recovery requirements.
- **Encrypt at rest.** Enable storage encryption — required for HIPAA and PCI-DSS. Must be set at creation, can't be added after.
- **Aurora for new projects.** If you're starting fresh on AWS, Aurora is almost always the better choice over vanilla MySQL or PostgreSQL.
- **Vertical scaling causes downtime.** Resizing an RDS instance requires a reboot — plan maintenance windows for production.
- **Parameter groups matter.** Database engine settings are controlled via parameter groups. Don't use the default in production — create a custom one you control.
