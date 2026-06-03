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
ALB Security Group → EC2 Security Group → RDS Security Group
Each layer only trusts the one directly in front of it. Lambda scales to 500 instances — doesn't matter, they all wear the same security group so they all get through. Nothing else does.

### Stateful vs stateless
| | Security Group | NACL |
|---|---|---|
| Attached to | Resource | Subnet |
| Stateful/Stateless | Stateful | Stateless |
| Rules | Allow only | Allow AND deny |
| Default | Deny all inbound | Allow all |

NACLs are the subnet-level layer — security groups are the resource-level layer. Use both for true defense in depth.

## When would you use this?

Always — every resource in a VPC should have a security group. The design question is:
- Any time two services need to talk to each other — map the chain
- Any time something needs to be reached from outside your VPC — define exactly what port and from where
- Any compliance requirement (HIPAA, PCI-DSS) — least privilege traffic is non-negotiable

## Tips & gotchas

- **Never open `0.0.0.0/0` on sensitive ports.** Port 22 (SSH) and port 3306 (MySQL) open to the world is how breaches happen. Use security group references instead.
- **Reference security groups as sources, not IPs.** IPs change. Security group IDs don't.
- **Default outbound allows everything.** Fine for most cases — tighten it if compliance requires it.
- **Security groups are stateful — NACLs are not.** If you use NACLs you need explicit inbound AND outbound rules or you'll block your own responses.
- **One resource can have multiple security groups.** Rules are additive — the most permissive rule wins.
- **Changes apply immediately.** No reboot needed — security group updates take effect instantly.
