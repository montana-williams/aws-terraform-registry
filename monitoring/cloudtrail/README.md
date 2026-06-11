# CloudTrail — API Audit Logging

## What it is

CloudTrail records every API call made in your AWS account. Who did it, what they did, when they did it, and where the request came from — all logged automatically.

## Why you need it

CloudWatch tells you what your infrastructure is doing. CloudTrail tells you who changed it. When something breaks or gets misconfigured you need to answer questions like — who deleted that security group, who changed that IAM policy, what happened in the last 24 hours before this outage. CloudTrail is the answer.

It is also required for compliance. HIPAA, PCI-DSS, and most security frameworks require an immutable audit trail of all API activity. CloudTrail is how you prove it.

## How it fits into a real architecture

Every AWS API call → CloudTrail captures it → logs delivered to S3 → optionally streamed to CloudWatch Logs for alerting

The S3 bucket is the long term archive. CloudWatch Logs is optional but useful if you want to alarm on specific API activity like root account logins or security group changes.

## Key concepts

**Trail** — the configuration that tells CloudTrail what to log and where to send it. One trail can cover all regions or a single region.

**Management events** — API calls that manage AWS resources. Creating an EC2 instance, modifying a security group, attaching an IAM policy. Enabled by default. This is what you almost always want.

**Data events** — API calls on data inside resources. S3 object reads and writes, Lambda invocations. High volume and cost extra — enable only when you need them.

**S3 bucket** — where CloudTrail delivers log files. Must have a specific bucket policy that allows CloudTrail to write to it. CloudTrail will fail silently if the policy is wrong — this is a common gotcha.

**Log file integrity validation** — CloudTrail can sign each log file so you can prove it has not been tampered with. Required for most compliance frameworks.

## CloudTrail vs CloudWatch

| | CloudTrail | CloudWatch |
|---|---|---|
| What it watches | API calls and account activity | Infrastructure metrics and application logs |
| Who changed a security group | Yes | No |
| Lambda error rate | No | Yes |
| Required for compliance | Yes | Recommended |
| Use case | Audit and forensics | Monitoring and alerting |

Use both. They answer different questions.

## Tips and gotchas

- The S3 bucket policy must explicitly allow the CloudTrail service principal to write logs — if it is wrong CloudTrail will not deliver logs and will not error loudly
- Enable log file integrity validation in production — it is one checkbox and required for most compliance audits
- CloudTrail keeps 90 days of management event history in the console for free — the Trail sends logs to S3 for longer retention
- Multi-region trails are best practice — a single trail covering all regions means you never miss activity in a region you forgot about
- Never give users delete permissions on the CloudTrail S3 bucket — an attacker covering their tracks will go for the logs first
