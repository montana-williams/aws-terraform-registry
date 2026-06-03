# DynamoDB

## What is DynamoDB?

DynamoDB is AWS's managed NoSQL database. It uses primary keys to store and retrieve items and scales automatically without you ever touching the underlying infrastructure. No instance resizing, no maintenance windows, no capacity planning — it just handles it.

Pick DynamoDB when your data doesn't fit neatly into rows and columns, when you need automatic scaling, or when you want a fully managed database that grows with your traffic without manual intervention.

## SQL vs NoSQL — quick reminder

- **SQL (RDS)** — structured, like a spreadsheet. Every row has the same columns. Great for relational data with complex queries.
- **NoSQL (DynamoDB)** — flexible, like folders of sticky notes. Each item can look completely different. Great for variable data at scale.

## Key concepts

### Primary Key
Every DynamoDB table requires a primary key. Two types:

- **Partition key (hash key)** — the primary identifier. DynamoDB uses this to decide where the item is physically stored. Every item must have one. Example: `job_id`, `user_id`, `order_id`.
- **Sort key** — optional second key that lets you store multiple items under the same partition key and query them in order. Example: partition key `user_id` + sort key `created_at` lets you store all orders for a user sorted by date.

Simple primary key = partition key only. Good when every item has a unique identifier and you look up one item at a time.

Composite primary key = partition key + sort key. Good when you need to store and query multiple related items together.

### Capacity Modes

| Mode | How it works | When to use |
|---|---|---|
| On-demand | Scales instantly per request, pay per use | Dev, unpredictable traffic, new projects |
| Provisioned | You set read/write units upfront, pay for what you provision | Production with consistent predictable traffic |

On-demand is the safe default — no planning, no waste. Switch to provisioned once you understand your traffic patterns and want to optimize cost.

### DynamoDB Streams
Captures every change to a table in real time — creates, updates, and deletes — and makes that change available as an event that can trigger a Lambda function.

Pattern:Record changes in DynamoDB → Stream captures change → Lambda fires → react to the change

Real use cases:
- Job status updated → notify the customer
- New order created → trigger fulfillment
- Record deleted → sync to another system

Streams are how you make DynamoDB event driven without constantly polling the table.

### DAX — DynamoDB Accelerator
An in-memory cache that sits in front of DynamoDB and serves frequently read items in microseconds instead of milliseconds. Use when you have hot items being read thousands of times per second and need to reduce latency and database load.

## When would you use DynamoDB?

- Variable or flexible data structures that don't fit a relational model
- Applications that need to scale automatically without infrastructure management
- High throughput workloads — millions of reads and writes per second
- Event driven architectures where you need to react to data changes via Streams
- Session data, user preferences, real time leaderboards, job queues

## Tips & gotchas

- **Design your primary key carefully.** You can't change it after the table is created. A bad partition key causes hot partitions — one partition gets all the traffic while others sit idle. Distribute evenly.
- **DynamoDB is not a replacement for RDS.** It doesn't support complex joins or SQL queries. If your data is relational and needs complex querying — use RDS.
- **On-demand for dev, provisioned for production.** On-demand is more expensive per request but requires zero planning. Once traffic is predictable switch to provisioned to save cost.
- **Use sparse indexes.** Global Secondary Indexes (GSIs) let you query on non-primary key attributes — but they cost money. Only create indexes you actually query against.
- **Streams + Lambda is powerful.** Pair DynamoDB Streams with Lambda for real time event driven processing without polling.
- **Item size limit is 400KB.** DynamoDB is not for storing large files — use S3 for that and store the S3 key in DynamoDB.
- **TTL for automatic cleanup.** Set a Time To Live attribute on items and DynamoDB will automatically delete expired items. Perfect for sessions, temporary data, and job records you don't need forever.
- **Encrypt by default.** Encryption at rest is enabled by default on all DynamoDB tables — no action needed.
