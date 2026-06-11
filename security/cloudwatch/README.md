# CloudWatch — Monitoring and Observability

## What it is

CloudWatch is AWS's managed monitoring service. It collects metrics, stores logs, and fires alarms when something goes wrong — all in one place.

## Why you need it

You cannot fix what you cannot see. Every production system needs visibility into what is happening, what has happened, and when something crosses a threshold that requires attention. CloudWatch gives you all three without running your own monitoring infrastructure.

## How it fits into a real architecture

**Metrics** — AWS services automatically publish metrics to CloudWatch. CPU utilization, request count, DLQ depth, RDS connections — all available without any configuration.

**Alarms** — watches a metric over a time period and triggers when it crosses a threshold. Alarms publish to SNS which notifies your team by email or triggers a Lambda.

**Logs** — Lambda, EC2, API Gateway, and most AWS services send logs to CloudWatch Log Groups. When something breaks, logs are the first place you look.

## Key concepts

**Metric** — a time series of numbers. CPU at 80%, 5 errors in the last minute, 3 messages in the DLQ. AWS publishes these automatically. Your application can publish custom metrics too.

**Alarm** — watches one metric and changes state when a threshold is crossed. Three states: OK, ALARM, and INSUFFICIENT_DATA. When state changes to ALARM it notifies an SNS topic.

**Log Group** — a container for log streams from one service. Each Lambda function gets its own Log Group automatically. You set the retention period on the Log Group.

**Log Stream** — a sequence of log events from one source. One Lambda invocation = one log stream inside the Log Group.

**Dashboard** — a visual overview of your metrics in one place. Optional but useful for showing stakeholders system health at a glance.

## Common alarm patterns

| What to watch | Metric | Threshold |
|---|---|---|
| Lambda errors | Errors | Greater than 0 |
| DLQ messages | ApproximateNumberOfMessagesVisible | Greater than 0 |
| RDS CPU | CPUUtilization | Greater than 80% |
| ALB 5xx errors | HTTPCode_ELB_5XX_Count | Greater than 0 |

## Tips and gotchas

- Lambda Log Groups are created automatically on first invocation — you do not need to create them manually, but you should set retention or logs accumulate forever
- Alarms need at least one data point in the evaluation period to change state — set evaluation periods appropriately for your traffic pattern
- CloudWatch Logs cost money at scale — always set a retention period, never leave it at Never Expire in production
- SNS topic must exist before the alarm can notify it — build SNS before CloudWatch in your module order
- Custom metrics cost extra — use them sparingly and only where AWS does not already publish what you need
