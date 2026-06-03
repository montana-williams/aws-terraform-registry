# VPC — Virtual Private Cloud

## What is a VPC?

A VPC is AWS's way of giving you your own private network inside their cloud infrastructure. Think of AWS as a city — the VPC is your building inside that city. You own the building, you control who gets in, and nobody from the street can walk through your walls.

You define your own IP range using a CIDR block (e.g. `10.0.0.0/16`), which gives you 65,536 addresses to work with. From there you carve that range up into subnets — smaller sections of your network with different purposes.

## Why do you need one?

Any time your application has sensitive data, compliance requirements, or needs high availability across multiple Availability Zones — you need a custom VPC. The default AWS VPC exists but gives you no real control over security boundaries or network design.

Real triggers:
- Databases holding PII or sensitive data (HIPAA, PCI-DSS)
- Applications that need public-facing and private-facing tiers separated
- Multi-AZ architecture for high availability
- Any project where you control who can reach what

## Key components

### Subnets
Subnets are how you divide your VPC into sections with different access rules.

- **Public subnet** — the reception desk. Outside traffic can reach it directly. Used for load balancers, bastion hosts, NAT Gateways.
- **Private subnet** — the back office. No direct access from the internet. Used for databases, application servers, anything holding sensitive data.

### Internet Gateway (IGW)
The two-way door. Attaches to your VPC and allows your public subnets to communicate with the internet — and the internet to communicate back.

### NAT Gateway
The one-way glass. Sits in a public subnet and lets your private resources reach out to the internet (for updates, downloads, external APIs) without exposing them. The outside world cannot initiate a connection in.

### Route Tables
The traffic director. Every subnet has a route table that tells traffic where to go. Public subnets route `0.0.0.0/0` to the IGW. Private subnets route `0.0.0.0/0` to the NAT Gateway.

### CIDR Blocks
Your IP range. `/16` gives you 65,536 addresses at the VPC level. Subnets carve that up further — a `/24` gives you 256 addresses per subnet (minus 5 AWS reserves per subnet for network address, router, DNS, future use, and broadcast).

## Tips & gotchas

- **Always plan your CIDR range before you build.** Once set, you can't change the VPC CIDR without rebuilding. Give yourself room — `/16` at the VPC level is standard.
- **NAT Gateway costs money.** It's not free tier. Destroy it when not in use during learning/dev.
- **One IGW per VPC.** You don't need more than one.
- **Subnets live in one AZ.** For high availability, create at least one public and one private subnet in each AZ you're using.
- **Route tables are easy to forget.** A subnet with no route table association does nothing useful — always double check your routes after applying.

## When would you use this?

Any project with:
- Sensitive or regulated data (healthcare, finance, government)
- A multi-tier architecture (public ALB → private app servers → private database)
- Multi-AZ requirements for availability
- Any compliance framework (HIPAA, PCI-DSS, FedRAMP)
