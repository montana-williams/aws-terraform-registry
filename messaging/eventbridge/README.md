# EventBridge

## What is EventBridge?

EventBridge is an event bus that decouples your services by routing events to targets based on rules. Something happens in your system or in AWS — EventBridge sees it, matches it against your rules, and fires the right target automatically.

AWS runs a default event bus in the background that captures AWS service events like Auto Scaling launches, EC2 state changes, and CodePipeline failures without any setup from you. You can also create custom event buses for your own application events.

## EventBridge vs SQS

Both can trigger Lambda but they solve different problems:

| | SQS | EventBridge |
|---|---|---|
| Built around | Messages to be processed | Events that happened |
| Direction | Pull based — consumer fetches messages | Push based — event finds the target |
| Fan out | One queue, one consumer | One event, multiple targets simultaneously |
| Scheduling | No | Yes — cron and rate expressions |
| AWS service events | No | Yes — reacts to native AWS events |

**Use SQS** when something needs to be processed and order, retries, and delivery guarantees matter.

**Use EventBridge** when something happened and you want to react to it — especially for scheduling, AWS service events, or fanning out to multiple targets at once.

## Key concepts

### Events
Everything in EventBridge starts with an event — a JSON object describing something that happened. AWS services publish events automatically. Your application can publish custom events too.

Example event structure:
```json
{
  "source": "my.application",
  "detail-type": "job.completed",
  "detail": {
    "job_id": "abc123",
    "status": "success"
  }
}
```

### Event Rules
Rules match incoming events against a pattern and route matching events to a target. The pattern is JSON that must exactly match the structure of the incoming event.

Example pattern — matches only job.completed events:
```json
{
  "source": ["my.application"],
  "detail-type": ["job.completed"]
}
```

**Critical gotcha — EventBridge fails silently.** If your pattern doesn't match the incoming event nothing fires and you get zero error messages. No logs, no indication, total silence. Always test your event patterns in the AWS console Event Pattern tester before deploying. One wrong character or spelling mistake and you get nothing.

### Targets
What EventBridge triggers when a rule matches. One rule can fan out to multiple targets simultaneously:
- Lambda function
- SQS queue
- SNS topic
- Step Functions
- Another EventBridge bus
- And more

### Event Buses
- **Default bus** — where AWS service events land automatically. EC2 state changes, Auto Scaling events, CodePipeline failures — all published here without any setup.
- **Custom bus** — create your own for application events. Keeps your business logic events separate from AWS infrastructure events.

### Scheduling
EventBridge can trigger targets on a schedule without any incoming event:
- **Rate expression** — `rate(5 minutes)`, `rate(1 hour)`, `rate(1 day)`
- **Cron expression** — `cron(0 9 * * ? *)` fires every day at 9am UTC

Use for nightly jobs, cleanup tasks, report generation — anything that needs to run on a schedule without a dedicated server.

## When would you use EventBridge?

- Scheduled jobs — run Lambda on a cron without an EC2 instance
- React to AWS service events — EC2 stops, deployment fails, scaling event fires
- Fan out — one event needs to trigger multiple downstream services simultaneously
- Decouple application services — services publish events, other services subscribe without direct coupling
- Replace polling — instead of checking if something changed every few seconds, react when it actually changes

## Tips & gotchas

- **EventBridge fails silently.** Pattern doesn't match = nothing happens, no error. Always use the Event Pattern tester in the AWS console before deploying.
- **JSON must be exact.** One typo in your event pattern and it silently stops matching. This is the number one EventBridge debugging issue.
- **Default bus for AWS events, custom bus for your events.** Keep them separate — mixing application events with AWS infrastructure events gets messy fast.
- **EventBridge is not a queue.** It doesn't retry failed deliveries the way SQS does. If your Lambda fails to process an event consider pairing EventBridge with SQS for retry guarantees.
- **Test patterns before deploying.** AWS console has a built in Event Pattern tester — use it every time.
- **DynamoDB Streams don't use EventBridge.** DynamoDB Streams trigger Lambda directly. Don't try to route DynamoDB stream events through EventBridge — use the Lambda event source mapping instead.
- **Use dead letter queues on rules.** EventBridge can send failed invocations to an SQS DLQ — configure this in production so you don't lose events silently.
