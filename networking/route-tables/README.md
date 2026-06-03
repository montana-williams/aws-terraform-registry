# Route Tables

## What is a route table?

A route table is the traffic director for your VPC. It looks at the destination IP address of every packet and decides where to send it based on a set of rules called routes.

That's it. It doesn't know about services, resource names, or ARNs — just destination IPs and where to forward them.

## Why do you need one?

Without route tables your VPC has no concept of public vs private. Resources would have no path to the internet, no path to a NAT Gateway, and no way to differentiate between subnets that should be public facing and subnets that should be locked down.

Route tables are the glue that connects everything — IGW, NAT Gateway, subnets — into a working network.

## How routes work

Each route has two parts:
- **Destination** — the IP range to match e.g. `0.0.0.0/0` (all traffic) or `10.0.0.0/16` (your VPC range)
- **Target** — where to send matching traffic e.g. `igw-id`, `nat-gateway-id`, or `local`

**Longest prefix matching** — the more specific the route, the higher the priority. `10.0.0.0/16` always wins over `0.0.0.0/0` because it's more specific. Local VPC traffic always stays local.

## Public vs private route tables

**Public route table:**
- Associated with public subnets
- Has a route `0.0.0.0/0 → IGW`
- Traffic destined for the internet goes through the Internet Gateway

**Private route table:**
- Associated with private subnets
- Has a route `0.0.0.0/0 → NAT Gateway`
- Outbound internet traffic goes through NAT — inbound from internet is blocked

## Tips & gotchas

- **Always explicitly associate subnets to a route table.** If you don't, AWS quietly assigns the subnet to the main route table. You might think it's isolated — it's not.
- **Multiple subnets can share one route table.** All your public subnets can share one public route table. All your private subnets can share one private route table.
- **Every VPC has a default main route table.** It only has a local route out of the box. Don't rely on it — create and manage your own.
- **Local route is automatic.** AWS always adds a `local` route for your VPC CIDR range. You can't delete it and you don't need to create it.
- **One route table per subnet association.** A subnet can only be associated with one route table at a time.
- **Longest prefix match wins.** More specific routes take priority over less specific ones — `10.0.1.0/24` beats `10.0.0.0/16` beats `0.0.0.0/0`.
