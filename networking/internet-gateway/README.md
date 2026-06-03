# Internet Gateway (IGW)

## What is an Internet Gateway?

An Internet Gateway is the single connection point between your VPC and the public internet. It attaches directly to the VPC — not to a subnet — and enables two-way communication between your resources and the outside world.

One job. One resource. One per VPC.

## Why do you need one?

Without an IGW your VPC is completely isolated. No inbound traffic from the internet, no outbound traffic to it. Any public-facing resource — an ALB, a bastion host, a NAT Gateway — requires an IGW to function.

## How it fits in the chain

IGW attaches to VPC → route table points public subnets to IGW → public subnets can reach the internet.

The IGW alone does nothing. It needs a route table entry (`0.0.0.0/0 → igw-id`) in the public subnet's route table to actually direct traffic through it.

## Tips & gotchas

- **One IGW per VPC.** You cannot attach more than one.
- **Free to use.** No hourly charge — you only pay for data transfer.
- **Attaches to the VPC, not the subnet.** Route tables handle the subnet-level routing.
- **Private subnets never route to the IGW.** That's what NAT Gateway is for.
