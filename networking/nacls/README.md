# Network ACLs (NACLs)

## What is a NACL?

A Network ACL is a stateless firewall that sits at the subnet boundary. Every subnet in your VPC has a NACL associated with it — it's the first line of defense before traffic even reaches your resources.

Think of it as the bouncer at the subnet door. Security groups are the bodyguard on each individual resource inside.

## Stateless vs stateful

This is the most important concept to understand about NACLs.

**Security groups are stateful** — if inbound traffic is allowed in, the response is automatically allowed back out. The connection is tracked.

**NACLs are stateless** — they have no memory. Every packet is evaluated independently. If a client sends a request inbound on port 443 and your server sends a response back, the NACL treats that response as a brand new connection and checks it against the outbound rules. If there's no matching outbound rule — the response is dropped.

This means you must explicitly allow both directions of traffic.

## Ephemeral ports

When a client connects to your server it picks a random high port between 1024 and 65535 for the response to come back on. This is called an ephemeral port.

Because you can't predict which port the client picked you need to allow the full ephemeral port range `1024-65535` on outbound rules to ensure responses can get back to any client.

This is the most common NACL gotcha — inbound rules look perfect but traffic still drops because ephemeral ports aren't open outbound.

## Rule ordering

NACL rules are numbered and evaluated in order — lowest number first. The NACL stops at the first match and applies that rule. Everything after is ignored.

- Rule 100 allow port 443 → Rule 200 deny port 443 → **allow wins** — hits 100 first
- Rule 100 deny port 443 → Rule 200 allow port 443 → **deny wins** — hits 100 first

AWS recommends numbering in increments of 100 so you have room to insert rules later without renumbering.

The last rule is always `*` — implicit deny all. Anything that doesn't match a rule is dropped. You cannot delete this rule.

## NACL vs Security Group

| | NACL | Security Group |
|---|---|---|
| Attached to | Subnet | Resource |
| Stateful/Stateless | Stateless | Stateful |
| Rule types | Allow AND deny | Allow only |
| Rule evaluation | In order, first match wins | All rules evaluated |
| Default | Allow all | Deny all inbound |

## When would you use NACLs?

NACLs are your subnet level guardrail. Use them for:
- Blocking a specific IP or IP range at the subnet level — security groups can't deny, only allow
- Adding a second layer of defense on top of security groups
- Compliance requirements that mandate subnet level controls
- Fully isolating a subnet — no inbound, no outbound, nothing

## Tips & gotchas

- **Always allow ephemeral ports 1024-65535 outbound.** Forgetting this is the number one NACL mistake.
- **Rules are evaluated in order — first match wins.** Deny rules must have a lower number than allow rules to take effect.
- **Number rules in increments of 100.** Leaves room to insert rules later.
- **Stateless means both directions.** Every rule you write for inbound needs a corresponding outbound rule.
- **Default NACL allows all traffic.** AWS creates a default NACL that allows everything. Always replace it with explicit rules.
- **Changes apply to all resources in the subnet.** Unlike security groups, one NACL rule affects every resource in that subnet simultaneously.
