# AWS Terraform Registry

A personal reference registry for building production-ready AWS infrastructure with Terraform.

Every entry in this registry follows the same format — a plain English explanation of what the service is and why you need it, followed by annotated Terraform code with `# FILL IN` comments that show exactly what to configure and why. Built for engineers who are learning AWS and Terraform by doing, not just reading.

---

## Who this is for

This registry was built for anyone transitioning into cloud engineering who wants to understand AWS services at a conceptual level before writing a single line of code. Every explanation is written in plain English first — no assumed knowledge, no jargon without context. The Terraform examples are designed to be readable, not just functional.

If you are studying for the AWS Solutions Architect Associate, building your first portfolio projects, or just want a reference you can actually understand — this is for you.

---

## How to use this registry

Each service lives in its own folder with two files:

- **README.md** — explains what the service is, why you need it, how it fits into a real architecture, and tips and gotchas from real experience
- **main.tf** — annotated Terraform example with `# FILL IN` comments showing what to change, why each value matters, and what your options are

Start with the README to understand the concept. Then use the main.tf as a starting point for your own infrastructure — replace the `# FILL IN` values with your project specific configuration.

---

## Registry

### Networking
The foundation of every AWS architecture. Build this first.

| Service | What it does |
|---|---|
| [VPC](networking/vpc/) | Your private network inside AWS — defines your IP range and isolates your infrastructure |
| [Internet Gateway](networking/internet-gateway/) | The two-way door between your VPC and the public internet |
| [NAT Gateway](networking/nat-gateway/) | One-way glass — lets private resources reach the internet without being reachable from it |
| [Elastic IP](networking/elastic-ip/) | A static public IP address that never changes |
| [Security Groups](networking/security-groups/) | Resource level firewall — controls what traffic can reach each service |
| [Route Tables](networking/route-tables/) | The traffic director — tells packets where to go based on destination IP |
| [NACLs](networking/nacls/) | Subnet level stateless firewall — an additional security layer on top of security groups |

### Compute
Your servers and traffic distribution layer.

| Service | What it does |
|---|---|
| [EC2](compute/ec2/) | Virtual servers in AWS — fully configurable compute without buying hardware |
| [Auto Scaling](compute/auto-scaling/) | Automatically adds and removes EC2 instances based on demand |
| [ALB](compute/alb/) | Application Load Balancer — single entry point that distributes traffic across healthy instances |

### Storage
Your data layer.

| Service | What it does |
|---|---|
| [RDS](storage/rds/) | Managed relational database — MySQL, PostgreSQL, Aurora and more |
| [ElastiCache](storage/elasticache/) | Managed in-memory cache — Redis or Memcached for sub-millisecond data retrieval |
| [S3](storage/s3/) | Object storage for files, backups, logs, static assets — virtually unlimited scale |

### Serverless
Event driven compute and data without managing servers.

| Service | What it does |
|---|---|
| [Lambda](serverless/lambda/) | Runs code in response to triggers without any server infrastructure |
| [API Gateway](serverless/api-gateway/) | HTTPS endpoint for your serverless backend — the front door to Lambda |
| [DynamoDB](serverless/dynamodb/) | Managed NoSQL database that scales automatically |

### Messaging
The glue that connects services without coupling them directly.

| Service | What it does |
|---|---|
| [SQS](messaging/sqs/) | Queue service that decouples services and guarantees message delivery |
| [EventBridge](messaging/eventbridge/) | Event bus that routes events to targets — scheduling, AWS service events, fan out |
| [SNS](messaging/sns/) | Push notification service — broadcasts messages immediately to email, SQS, or Lambda |

### Monitoring
Visibility into your infrastructure. Build this alongside every other layer.

| Service | What it does |
|---|---|
| [CloudWatch](monitoring/cloudwatch/) | Metrics, alarms, and logs — the foundation of observability for every AWS service |
| [CloudTrail](monitoring/cloudtrail/) | API audit logging — records every action taken in your AWS account for security and compliance |

### Security
Wraps everything. Build this alongside every other layer.

| Service | What it does |
|---|---|
| [IAM](security/iam/) | Controls who and what can access your AWS resources — users, roles, groups, policies |
| [WAF](security/waf/) | Web Application Firewall — blocks malicious HTTP traffic before it reaches your application |
| [Cognito](security/cognito/) | Managed user authentication — handles sign up, sign in, and JWT issuance |

---

## Architecture build order

If you are building a project from scratch follow this order — each layer depends on the one before it:

\`\`\`
Networking   — VPC, subnets, IGW, NAT Gateway, route tables, security groups
Security     — IAM roles and policies for every service you are about to build
Compute      — EC2, Auto Scaling, ALB inside your VPC
Storage      — RDS, ElastiCache, and S3 attached to your compute layer
Serverless   — Lambda, API Gateway, DynamoDB for event driven workloads
Messaging    — SQS, EventBridge, and SNS to connect everything together
Monitoring   — CloudWatch alarms and logs across every layer
WAF          — attach to ALB or API Gateway as the final security layer
\`\`\`

---

## About

Built by [Montana Williams](https://www.linkedin.com/in/montana-williams) — a Help Desk Analyst transitioning into cloud engineering. AWS Certified Cloud Practitioner, active security clearance, currently pursuing AWS Solutions Architect Associate.

This registry grew out of building four portfolio projects — a HIPAA compliant patient portal, a PCI-DSS sports betting platform, a serverless AI agent automation platform, and a financial dashboard — and wanting a reference that explained not just *how* to write the Terraform but *why* each decision was made.

If this helped you or you want to connect — find me on LinkedIn.

---

## Disclaimer

The Terraform examples in this registry are for learning and reference purposes. Always review and test infrastructure code in a non-production environment before deploying. AWS costs real money — pay attention to the cost warnings in each entry, especially NAT Gateway and WAF.
EOF
