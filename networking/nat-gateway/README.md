# NAT Gateway

## What is a NAT Gateway?

A NAT Gateway is the middleman between your private subnets and the internet. It lets resources in private subnets reach out to the internet — for updates, downloads, external APIs — without ever exposing them to inbound connections from the outside world.

One way glass. Your private resources can see out. Nobody outside can see in.

## Why do you need one?

Your private resources still need to reach the internet occasionally — package updates, dependency downloads, external API calls. Without a NAT Gateway they have no path out. Without the isolation it provides, you'd have to put those resources in a public subnet and expose them directly.

## How it fits in the chain

Private subnet route table → NAT Gateway (in public subnet) → IGW → internet.

The NAT Gateway sits in a public subnet so it has internet access. Private resources route their outbound traffic through it. The response comes back through the NAT Gateway and is forwarded to the private resource. At no point can the internet initiate a connection directly to your private resource.

## Key concepts

### Elastic IP
A NAT Gateway requires an Elastic IP — a static public IP address that stays consistent. This is what the internet sees when your private resources make outbound requests.

### Availability
NAT Gateways are AZ-specific. For true high availability create one NAT Gateway per AZ and update each AZ's private route table to use its local NAT Gateway. This prevents one AZ failure from cutting off all private outbound traffic.

## Tips & gotchas

- **NAT Gateway lives in a PUBLIC subnet.** It needs internet access to do its job — putting it in a private subnet defeats the purpose entirely.
- **It costs money.** Hourly charge plus data processing fees. Destroy it when not in use during learning and dev.
- **Requires an Elastic IP.** Create the EIP first — NAT Gateway depends on it.
- **Not the same as an IGW.** IGW is two-way for public subnets. NAT Gateway is outbound only for private subnets.
- **One per AZ for production.** A single NAT Gateway is a single point of failure if that AZ goes down.
