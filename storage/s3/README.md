# S3 — Simple Storage Service

## What is S3?

S3 is AWS's object storage service — virtually unlimited storage for anything you don't need to edit in place. You store it, you retrieve it whole. Images, videos, backups, logs, static websites, Terraform state — S3 is the universal storage layer that shows up in almost every AWS architecture.

Unlike EBS which is block storage you can edit line by line, S3 treats everything as a complete object. To change something you download it, edit it, and reupload the whole thing. That tradeoff gives you virtually unlimited scale at low cost.

## Why do you need it?

Any time you need to store files, assets, backups, or data outside of a database — S3 is the answer. It's not tied to any specific instance or service, it's globally accessible within your account, and it scales without you thinking about it.

## Common use cases

- **Static website hosting** — serve HTML, CSS, and JS directly from a bucket
- **Media storage** — images, videos, and documents uploaded by users
- **Backups** — RDS snapshots, EBS snapshots, and application backups all land in S3
- **Logs** — CloudTrail, ALB access logs, and VPC flow logs
- **Terraform state** — remote state backend so your team shares the same state file
- **Data lake** — raw data storage for analytics pipelines
- **Application assets** — files your app reads at runtime

## Key concepts

### Objects and Buckets
- **Bucket** — the container. Globally unique name across all of AWS.
- **Object** — the file stored inside the bucket. Each object has a key (the file path), the data itself, and metadata.

### Bucket Policy vs S3 ACL
- **Bucket policy** — IAM style JSON policy applied at the bucket level. Controls what services and principals can access the entire bucket. This is the modern approach — use this.
- **S3 ACL** — legacy permissions applied at the individual object level. Mostly deprecated in modern AWS. Bucket policy overrides ACLs — a bucket level deny wins every time.

### Versioning
Keeps every version of every object. If someone overwrites or deletes a file you can restore the previous version instantly.

The downside — every version is stored and you pay for all of it. A busy bucket with versioning enabled and no cleanup policy can get expensive fast. Pair versioning with lifecycle policies to automatically expire old versions.

### Lifecycle Policies
Rules that automatically move objects between storage classes or expire them after a set number of days. Set it once and S3 manages your storage costs automatically.

Example:
- Days 0-30 → S3 Standard
- Days 31-90 → S3 Standard-IA
- Days 91+ → S3 Glacier

### Storage Classes

| Class | Best for | Retrieval |
|---|---|---|
| Standard | Frequently accessed data | Milliseconds |
| Intelligent-Tiering | Unknown or changing access patterns | Milliseconds |
| Standard-IA | Infrequent access, fast when needed | Milliseconds, retrieval fee |
| One Zone-IA | Infrequent access, okay with single AZ | Milliseconds, retrieval fee |
| Glacier Instant Retrieval | Quarterly access, archive | Milliseconds |
| Glacier Flexible Retrieval | Rare access, archive | Minutes to hours |
| Glacier Deep Archive | Coldest storage, compliance records | Up to 12 hours |

The pattern — less frequent access = cheaper storage, slower and more expensive retrieval.

## When would you use S3?

- Storing user uploaded files — images, documents, receipts
- Any backup or snapshot destination
- Static frontend hosting
- Log aggregation from other AWS services
- Sharing files between services without coupling them directly

## Tips & gotchas

- **Bucket names are globally unique.** Across all AWS accounts worldwide — not just yours. Plan your naming convention early.
- **Buckets are private by default.** Nothing is publicly accessible unless you explicitly allow it. Keep it that way unless you're hosting a static site.
- **Bucket policy overrides ACLs.** A deny at the bucket level wins. Don't rely on object level ACLs for security.
- **Enable versioning on important buckets.** Pair it immediately with a lifecycle policy to avoid runaway storage costs.
- **Block public access is your safety net.** AWS has a account level setting that blocks all public S3 access. Leave it on unless you have a specific reason to turn it off.
- **Encryption is easy — turn it on.** Server side encryption is one checkbox. No reason not to enable it, required for HIPAA and PCI-DSS.
- **S3 is not a file system.** You can't edit objects in place, you can't lock files, and there's no true folder structure — just key prefixes that look like folders.
- **Requester pays.** By default the bucket owner pays for all data transfer. For public buckets with heavy traffic this adds up fast.
