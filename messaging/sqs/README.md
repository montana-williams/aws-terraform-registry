# SQS — Simple Queue Service

## What is SQS?

SQS is a queue service that decouples your services and facilitates requests by holding messages in a queue until a consumer picks them up. Services don't talk directly to each other — they drop messages in the queue and move on. The consumer processes them when ready.

It limits blast radius — if one service goes down or gets compromised it can't directly infect the services around it. The queue acts as a buffer between them.

It also provides reliability guarantees — SQS holds your messages safely until they're successfully processed, retries on failure, and moves unprocessable messages to a Dead Letter Queue for inspection rather than silently dropping them.

## Why do you need it?

Direct service to service calls are fragile. If Service B is down when Service A calls it — the request is lost. If Service B is slow — Service A is blocked waiting. If Service B gets compromised — Service A is directly exposed.

SQS removes all of that. Service A drops the message and moves on. Service B processes it when it's ready. Neither service needs to know if the other is up, down, or slow.

## Message lifecycle

1. Producer sends a message to the queue
2. Message sits in the queue until a consumer picks it up
3. Consumer (Lambda, EC2, ECS) receives the message
4. Message becomes invisible to other consumers during processing (visibility timeout)
5. If processing succeeds — message is deleted from the queue
6. If processing fails — message becomes visible again after timeout and gets retried
7. After maxReceiveCount failures — message moves to the Dead Letter Queue

## Key concepts

### Visibility Timeout
When a consumer picks up a message it becomes invisible to other consumers for the duration of the visibility timeout. This prevents two consumers processing the same message simultaneously.

If the consumer finishes successfully the message is deleted. If the consumer fails or the timeout expires before processing is done the message becomes visible again for another attempt.

**Critical gotcha** — if your Lambda takes 45 seconds but visibility timeout is 30 seconds, the message becomes visible again before Lambda finishes. A second Lambda grabs it. Now the same message is being processed twice — duplicate processing.

**Rule:** Set visibility timeout to at least 6x your Lambda timeout.

### Dead Letter Queue (DLQ)
A separate queue that receives messages that failed processing more than `maxReceiveCount` times. Instead of silently dropping failed messages or looping forever the DLQ holds them for inspection and debugging.

Always configure a DLQ in production. Without one failed messages disappear or retry forever with no visibility into what went wrong.

### Standard vs FIFO

| | Standard | FIFO |
|---|---|---|
| Order | Best effort — generally in order but not guaranteed | Guaranteed first in first out |
| Throughput | Nearly unlimited | 300 msg/sec (3,000 with batching) |
| Duplicates | Possible | Exactly once processing |
| Best for | High throughput, order doesn't matter | Order critical workflows |

**Real world examples:**
- **Standard** — video processing, notifications, log ingestion, anything high volume where order doesn't matter
- **FIFO** — payment processing, order fulfillment, anything where sequence is non negotiable

Standard is faster but semi-random. FIFO is slower but guaranteed. Pick based on whether your use case can tolerate out of order processing.

## When would you use SQS?

- Any time two services need to communicate without being directly coupled
- Async processing — accept a request immediately, process it in the background
- Protecting downstream services from traffic spikes — queue absorbs the burst
- Retry logic — automatic retries without building it yourself
- Any workflow where you need guaranteed delivery and DLQ for failures

## Tips & gotchas

- **Set visibility timeout to 6x Lambda timeout.** The most common SQS mistake — timeout too short causes duplicate processing.
- **Always configure a DLQ.** Silent failures are worse than visible ones. DLQ gives you a paper trail.
- **Standard for most things, FIFO only when you need it.** FIFO has a throughput ceiling — don't reach for it unless order and exactly once processing are non negotiable.
- **Batch size matters.** Lambda can process up to 10 SQS messages per invocation in a batch. Tune batch size based on how long each message takes to process.
- **Long polling over short polling.** Long polling waits up to 20 seconds for a message before returning empty. Short polling returns immediately even if the queue is empty. Long polling is cheaper and more efficient — always use it.
- **Message retention is 4 days by default.** Max is 14 days. Set it based on how long you want unprocessed messages to survive before being dropped.
- **Message size limit is 256KB.** For larger payloads store the data in S3 and send the S3 key in the SQS message.
