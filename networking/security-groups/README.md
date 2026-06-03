# Security Groups

## What is a security group?

A security group is a virtual firewall attached directly to a resource — not a subnet, not a VPC, but the resource itself. An EC2 instance, an RDS database, a Lambda function inside a VPC, an ALB — each one gets its own security group with its own rules.

Think of it as a blank wall with no doors and no windows. Nothing gets in, nothing gets out until you explicitly cut a hole and specify exactly what's allowed through that hole. By default a security group denies all inbound traffic and allows all outbound.

You control two directions:
- **Inbound** — what traffic is allowed to reach this resource
- **Outbound** — what traffic this resource is allowed to send out

Security groups are **stateful** — if an inbound connection is allowed in, the response is automatically allowed back out without needing an explicit outbound rule. AWS tracks the connection for you.

## Why do you need one?

Because you never want every service in your infrastructure talking to every other service with no guardrails.

This is called **defense in depth** — you stack security layers so that if one service is compromised, it can't lateral move and take down your entire application. One infected service should be contained, not a master key to everything else.

You can't rely on your VPC or subnets alone. Two resources in the same subnet can have completely different security group rules — the subnet doesn't protect the resource, the security group does.

## Key concepts

### Inbound vs outbound rules
- **Inbound** — controls what can reach your resource. Port, protocol, and source.
- **Outbound** — controls what your resource can reach. By default all outbound is allowed.
- Because security groups are stateful you rarely need to touch outbound rules — responses to allowed inbound connections go out automatically.

### Security group chaining
Instead of opening a port to `0.0.0.0/0` (the whole internet), you reference another security group as the source. The rule says "only allow traffic on this port from resources wearing this specific security group."

This is the production pattern:
