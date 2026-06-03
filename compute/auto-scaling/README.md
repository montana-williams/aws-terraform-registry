# Auto Scaling

## What is Auto Scaling?

Auto Scaling automatically adjusts the number of EC2 instances running your application based on demand. When traffic spikes it adds instances. When traffic drops it removes them.

Without it a single instance gets overwhelmed, slows down, and eventually crashes under load. With it your infrastructure thinks for itself — keeping utilization at the right level, controlling cost, maintaining availability, and recovering from failures automatically.

## Why do you need it?

A single EC2 instance has a ceiling. Hit that ceiling and your app slows down, requests fail, and users leave. Auto Scaling removes that ceiling by adding capacity when you need it and pulling it back when you don't.

It gives you four things at once:
- **Availability** — minimum instances always running, never fully down
- **Performance** — utilization stays at your target, never overwhelmed
- **Cost control** — maximum cap prevents runaway scaling and surprise bills
- **Failover** — unhealthy instances are terminated and replaced automatically

## Key concepts

### Launch Template
The blueprint for every new instance Auto Scaling spins up. Contains everything needed to launch an identical copy of your server:
- AMI — the operating system and base software
- Instance type — CPU and memory specs
- Security groups — what traffic is allowed
- Key pair — SSH access
- User data — bootstrap commands to run on first boot

Every instance in your Auto Scaling group is launched from this template. Change the template and new instances pick up the change automatically.

### Minimum, Desired, and Maximum Capacity
| Setting | What it does |
|---|---|
| Minimum | Floor — always keep at least this many instances running |
| Desired | Target — this is your normal steady state |
| Maximum | Ceiling — never scale beyond this, controls your bill |

Example: min 2, desired 2, max 6. You always have 2 running. Traffic spikes and Auto Scaling adds up to 4 more. Traffic drops and it scales back to 2.

### Scaling Policies
How Auto Scaling decides when to add or remove instances:
- **Target tracking** — keep a metric at a target value e.g. keep CPU at 60%
- **Step scaling** — add X instances when CPU goes above 70%, add more when it goes above 90%
- **Scheduled scaling** — scale up at 8am, scale down at 8pm for predictable traffic patterns

### Health Checks
Auto Scaling constantly monitors your instances. A health check is a knock on the door — the load balancer sends a request to a path like `/health` and waits for a `200 OK` response.

- **Healthy** — instance responds with 200, stays in rotation
- **Unhealthy** — instance times out or returns an error, gets terminated and replaced with a fresh one from the Launch Template

### Target Groups
Auto Scaling registers new instances into a target group. The load balancer uses the target group to know which instances are healthy and available to receive traffic. New instances don't get traffic until they pass health checks.

## When would you use Auto Scaling?

- Any production application with variable traffic
- Applications that need high availability across multiple AZs
- Anything where a single instance going down would cause an outage
- Cost sensitive workloads where you don't want to overprovision

## Tips & gotchas

- **Always set a maximum.** Without a cap a traffic spike or misconfigured scaling policy can spin up hundreds of instances and destroy your bill.
- **Set minimum to at least 2 across 2 AZs.** One instance in one AZ is still a single point of failure.
- **Health check grace period matters.** Give new instances enough time to boot and pass health checks before Auto Scaling marks them unhealthy. Too short and it terminates instances that just need more time to start.
- **Launch Templates over Launch Configurations.** Launch Configurations are the old way — Launch Templates support versioning, mixed instance types, and more. Always use Templates.
- **Warm up time.** New instances take time to boot. Factor that into your scaling policies — scale early rather than waiting until you're already overwhelmed.
- **Scale in protection.** You can protect specific instances from being terminated during scale in — useful for instances running long jobs that shouldn't be interrupted.
