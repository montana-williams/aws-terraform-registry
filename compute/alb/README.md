# ALB — Application Load Balancer

## What is an ALB?

An Application Load Balancer is the single entry point for all user traffic into your application. Instead of exposing individual EC2 instances directly, users hit one DNS name and the ALB decides which healthy instance gets the request.

Without it you'd have to hand every user a specific IP address. If that instance goes down — they get nothing. The ALB removes that single point of failure and keeps your application highly available, elastic, and performant regardless of what's happening behind the scenes.

## Why do you need one?

- **Single entry point** — one DNS name for your entire application, no matter how many instances are running
- **High availability** — traffic is only sent to healthy instances, dead instances are automatically removed from rotation
- **Elasticity** — works hand in hand with Auto Scaling, new instances are registered into the target group and start receiving traffic as soon as they pass health checks
- **Performance** — distributes traffic evenly so no single instance gets overwhelmed

## Key concepts

### Listeners
A listener sits on the ALB and watches a specific port for incoming traffic from users. It's the front door.

- Port 443 — HTTPS listener for production traffic
- Port 80 — HTTP listener, typically used to redirect to HTTPS

Each listener has rules that decide where to forward traffic based on the request content.

### Target Groups
The collection of instances behind the ALB that actually receive traffic. The listener decides where to send it, the target group is where it lands.

**Target groups are the bridge between ALB and Auto Scaling:**
- ALB sends traffic to the target group
- Auto Scaling registers new instances into the target group
- When an instance fails a health check it gets removed from the target group and ALB stops sending it traffic

One target group, two services using it for different purposes.

### Layer 7 Routing
ALB operates at layer 7 — the application layer. It can read the actual content of HTTP and HTTPS requests and route based on:

**Path based routing:**
- `/api/*` → API server target group
- `/images/*` → image processing target group

**Host based routing:**
- `app.yoursite.com` → application target group
- `admin.yoursite.com` → admin target group

This is impossible with a basic layer 4 load balancer that only sees IPs and ports.

### Health Checks
The ALB constantly checks instances by sending a request to a configured path like `/health` and waiting for a `200 OK`. Healthy instances receive traffic. Unhealthy instances are pulled from rotation until they recover.

## When would you use an ALB?

- Any production application with multiple EC2 instances
- Applications with multiple services that need path or host based routing
- Any Auto Scaling setup — ALB and Auto Scaling are almost always paired
- HTTPS termination — decrypt SSL at the ALB so your instances don't have to

## Tips & gotchas

- **Always use HTTPS on your listener.** HTTP is fine for redirect only — all real traffic should be encrypted.
- **ALB lives in public subnets, instances live in private.** The ALB faces the internet, your EC2 instances never need to.
- **SSL certificate goes on the ALB.** Use AWS Certificate Manager (ACM) — free SSL certificates that auto renew.
- **Health check path must return 200.** Make sure your application has a `/health` endpoint that returns 200 OK or health checks will fail and instances get pulled from rotation.
- **ALB has its own security group.** Open port 443 to `0.0.0.0/0` on the ALB SG, then only allow traffic from the ALB SG on your EC2 SG — never open EC2 directly to the internet.
- **Cross zone load balancing is on by default.** Traffic is distributed evenly across all instances in all AZs — no AZ gets starved.
- **Connection draining.** When an instance is removed from rotation the ALB waits for in-flight requests to complete before fully pulling it. Prevents dropped requests during scale in or deployments.
