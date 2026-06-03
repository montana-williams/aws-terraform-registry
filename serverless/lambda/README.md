# Lambda

## What is Lambda?

Lambda is serverless compute that lets your application execute functions without managing, creating, or configuring any server infrastructure. You write the code, upload it, and AWS handles everything underneath — no EC2, no OS patching, no capacity planning.

It sits dormant and costs nothing until something triggers it. You only pay for the milliseconds it actually runs.

## Why do you need it?

Any time you need to run code in response to an event without wanting to manage a server. A file gets uploaded, a message lands in a queue, an API request comes in — Lambda fires, does its job, and shuts back down.

It's the glue that connects services together in a serverless architecture.

## How Lambda gets triggered

Lambda doesn't run on its own — something always triggers it:

- **API Gateway** — HTTP request comes in, Lambda fires
- **SQS** — message lands in a queue, Lambda fires
- **DynamoDB Streams** — record changes in a table, Lambda fires
- **EventBridge** — scheduled or event driven rule, Lambda fires
- **S3** — file uploaded to a bucket, Lambda fires
- **SNS** — notification published, Lambda fires
- **CloudWatch Events** — cron schedule, Lambda fires

## Key concepts

### Execution model
Lambda runs your function in a managed execution environment. When nothing is calling it — it does nothing and costs nothing. When triggered AWS spins up the environment, runs your code, and returns the result.

### Timeout limit
Lambda has a hard maximum execution timeout of **15 minutes**. If your function runs longer AWS kills it.

Lambda is the wrong tool for long running jobs — video processing, large file transformations, anything that needs to run for hours. For those use ECS, Fargate, or EC2.

### Cold starts
When Lambda hasn't been called in a while AWS has to spin up a new execution environment before your code can run. That startup time is called a cold start — the first request after inactivity is noticeably slower than subsequent ones.

**Why it matters** — the first user after a period of inactivity gets a slow response while the environment initializes. For user facing APIs that's a bad experience.

**How to fix it:**
- **Provisioned concurrency** — keep X instances always warm and ready. Eliminates cold starts, costs money.
- **Scheduled warming** — ping your Lambda every few minutes with a CloudWatch rule to keep it warm. Cheap workaround.
- **Keep your package small** — smaller deployment package means faster initialization. Don't bundle dependencies you don't need.

### IAM Execution Role
Every Lambda function needs an IAM role that defines what AWS services it's allowed to interact with. Lambda assumes this role when it runs.

Least privilege always — only grant the permissions the function actually needs. A Lambda that reads from S3 should only have `s3:GetObject` on that specific bucket, nothing else.

### Environment Variables
Store configuration values your function needs at runtime — database endpoints, API keys, feature flags. Never hardcode these in your function code.

For sensitive values use AWS Secrets Manager or SSM Parameter Store and fetch them at runtime rather than storing them as plain text environment variables.

### Concurrency
Lambda scales automatically — if 1000 requests come in simultaneously AWS spins up 1000 instances of your function in parallel. Each runs independently.

Be aware of downstream impact — 1000 Lambda instances all hitting your RDS database simultaneously can overwhelm it. Use RDS Proxy to pool connections when Lambda talks to a relational database.

## When would you use Lambda?

- Event driven processing — respond to S3 uploads, SQS messages, API requests
- Glue between services — receive from one service, transform, send to another
- Scheduled jobs — run a function on a cron without a server
- Lightweight APIs — pair with API Gateway for a fully serverless backend
- Any workload that runs in under 15 minutes and doesn't need a persistent server

## Tips & gotchas

- **15 minute hard limit.** Design functions to be fast and focused. If it needs longer, it's the wrong tool.
- **Least privilege IAM role.** Only grant what the function actually needs — nothing more.
- **Cold starts are real.** Plan for them in user facing functions — use provisioned concurrency if latency matters.
- **Use RDS Proxy with relational databases.** Lambda's automatic scaling can exhaust RDS connection limits fast without it.
- **Keep functions small and focused.** One function, one job. Don't build a monolith inside Lambda.
- **Environment variables for config, Secrets Manager for secrets.** Never hardcode endpoints, keys, or passwords in your code.
- **Monitor with CloudWatch.** Lambda automatically logs to CloudWatch — always check logs first when debugging.
- **Layers for shared code.** If multiple functions share the same library or utility code use Lambda Layers to avoid duplicating it across packages.
