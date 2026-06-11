# SNS — Simple Notification Service

## What it is

SNS is AWS's managed push notification service. It broadcasts messages immediately to every subscriber the moment a message is published — no polling, no waiting.

## Why you need it

Some events need to notify multiple places at once. A failed payment needs to alert your ops team by email, trigger a Lambda to update the order status, and drop a message in an SQS queue for retry logic — all from one publish. SNS handles that fan out in a single call.

Without SNS you would need to write separate code to call each destination individually. SNS decouples the publisher from the subscribers so neither side needs to know about the other.

## How it fits into a real architecture

**Alerting pattern** — CloudWatch detects a threshold breach → publishes to SNS topic → SNS emails your ops team

**Fan out pattern** — one event publishes to SNS → SNS delivers to multiple SQS queues simultaneously → each queue processes independently

## Key concepts

**Topic** — the channel that messages are published to. Publishers send to the topic, subscribers listen to the topic. Publishers and subscribers never talk directly.

**Subscription** — connects a topic to a destination. One topic can have many subscriptions. Common protocols are email, SQS, Lambda, and HTTP.

**Publisher** — anything that sends a message to the topic. CloudWatch alarms, your application code, EventBridge, or another Lambda.

## SNS vs SQS

| | SNS | SQS |
|---|---|---|
| Delivery | Push — immediate | Pull — sits in queue |
| Subscribers | Many at once | One consumer |
| Message retention | No retention | Up to 14 days |
| Use case | Fan out, alerting | Decoupling, retry logic |

Use SNS when you need to notify multiple destinations immediately. Use SQS when you need guaranteed delivery and controlled processing. Use both together for fan out with durability.

## Tips and gotchas

- Email subscriptions require manual confirmation — the recipient must click a link before they receive messages
- SNS does not retain messages — if a subscriber is down when a message is published it will miss it. Use SNS to SQS if you need durability
- Topic names must be unique within your AWS account and region
- For CloudWatch alarms, SNS is the only supported notification target — you cannot alarm directly to email without SNS
