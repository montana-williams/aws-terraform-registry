# EC2 — Elastic Compute Cloud

## What is EC2?

EC2 is your own virtual server in AWS. It lets you configure everything to your needs — CPU, memory, storage, operating system — without having to go to a store, buy parts, and build a physical machine. You spin it up in minutes, configure it for your workload, and tear it down when you're done.

You're creating a server in the cloud that you fully control.

## Why do you need one?

Any time your application needs a persistent server — a web server, an application backend, a bastion host, a database server — EC2 is your foundation. It lives inside your VPC, inside your subnets, protected by your security groups.

## Key concepts

### AMI — Amazon Machine Image
The blueprint for your instance. Operating system, base software, and configurations baked into a single image. AWS provides official AMIs (Ubuntu, Amazon Linux, Windows) and you can create your own.

**Custom AMI (Golden AMI)** — configure an instance exactly how you want it, bake it into an AMI, and every new instance you launch from it comes pre-configured. Critical for consistency and speed in production.

### Instance Types
The hardware spec of your instance — how much CPU, memory, and network bandwidth you get. Grouped into families optimized for different workloads:

| Family | Optimized for | Example use case |
|---|---|---|
| t | General purpose, burstable | Dev environments, low traffic apps |
| c | Compute | Video processing, gaming servers |
| r | Memory | Databases, in-memory caching |
| g | GPU | Machine learning, graphics rendering |
| i | Storage | Big data, high speed local storage |

The number is the generation (`t3` is newer than `t2`). The size is how much of those resources you get (`micro` → `xlarge` → `2xlarge`).

### Pricing Models
| Model | When to use |
|---|---|
| On-demand | Default — pay by the hour, no commitment |
| Reserved | 24/7 workloads — commit 1-3 years, save up to 72% |
| Spot | Fault tolerant workloads — use spare AWS capacity, cheapest option, can be interrupted |

### Storage — EBS vs Instance Store
**EBS (Elastic Block Store)** — persistent, network attached storage. Survives stops, starts, and reboots. Think of it as a hard drive you can detach and reattach. Always use EBS for anything you care about. Supports snapshots to S3 for backups.

**Instance Store** — physically attached to the host server. Blazing fast but completely wiped if the instance stops, terminates, or the host fails. Use only for temporary data like caches or buffers where speed matters and losing it is acceptable.

### Snapshots
Point-in-time backups of your EBS volume stored in S3. Production best practice — automate snapshots on a schedule so you can restore if anything goes wrong.

## When would you use EC2?

- A persistent web or application server that needs to stay running
- A bastion host for SSH access into your private subnets
- Any workload that needs full OS control and custom configuration
- Long running background processes that don't fit a serverless model

## Tips & gotchas

- **Stop vs terminate.** Stopping an instance keeps it — EBS persists, you can restart it. Terminating destroys it permanently including the EBS volume by default.
- **Public IPs change on stop/start.** Use an Elastic IP if you need a consistent address.
- **Right size your instances.** Start small and scale up — it's easy to resize. Don't overprovision from the start.
- **Instance Store is not a backup strategy.** If it matters, it goes on EBS with snapshots.
- **Always launch into a private subnet when possible.** Only put EC2 in a public subnet if it absolutely needs direct internet exposure — use an ALB in front instead.
- **Security groups are your resource level firewall.** Lock down your EC2 security group to only accept traffic from your ALB security group, nothing else.
- **Pick the right instance family.** A memory heavy database on a compute optimized instance is wasted money — match the family to the workload.
