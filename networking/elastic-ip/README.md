# Elastic IP (EIP)

## What is an Elastic IP?

An Elastic IP is a static public IP address that you own in AWS. Unlike a regular public IP — which changes every time you stop and start a resource — an Elastic IP stays the same until you explicitly release it.

You own it. You control it. It doesn't change.

## Why do you need one?

Any time an external system needs to reach your resource at a consistent IP address. If a client, payment processor, government system, or partner has your IP whitelisted and it changes — they lose connection.

Common use cases:
- NAT Gateway — needs a consistent public IP for outbound private subnet traffic
- Bastion host — your team SSHs in from a whitelisted IP
- EC2 running a web server or API that external systems have hardcoded
- Any resource that gets stopped and started but must remain reachable at the same address

## Tips & gotchas

- **You get charged if you allocate but don't use it.** AWS charges for unattached Elastic IPs to discourage hoarding public addresses. Always release EIPs you're not using.
- **Free when attached to a running resource.** The charge only kicks in when it's allocated but sitting idle.
- **One EIP per resource.** You can't attach the same EIP to multiple resources simultaneously.
- **Releasing vs disassociating.** Disassociating detaches the EIP from a resource but keeps it allocated to your account. Releasing gives it back to AWS completely. When you're done — release it, don't just disassociate.
- **Region specific.** An EIP allocated in us-east-1 cannot be used in us-west-2.
