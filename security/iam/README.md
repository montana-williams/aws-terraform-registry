# IAM — Identity and Access Management

## What is IAM?

IAM is the internal security system for your AWS environment. It controls everything — what a service can and can't do, what a user or account can and can't do, and what a group or real world job function can and can't do.

Nothing in AWS should have more access than it needs to do its job. IAM is how you enforce that.

## Why do you need it?

Without IAM everything in your AWS account has access to everything else by default. A compromised Lambda function could delete your S3 buckets. A developer could accidentally drop a production database. A misconfigured service could read another service's secrets.

IAM is the guardrail that contains blast radius, enforces least privilege, and ensures every identity — human or machine — can only do exactly what it's supposed to do.

## Key concepts

### Users, Groups, and Roles

**IAM User** — a person. A developer, an admin, a CI/CD service account. Has long term credentials — username/password for console access, access keys for programmatic access. Assign permissions directly or via a group.

**IAM Group** — a collection of users. Attach permissions to the group and all users in it inherit them. Dev group, ops group, read-only group. Never assign permissions to individual users — always use groups for people.

**IAM Role** — assumed by services, not people. Lambda, EC2, ECS, API Gateway — they assume a role to get temporary credentials to interact with other AWS services. No long term credentials, no access keys. Roles are the right way to give AWS services permissions.

### Policies
The actual rules. JSON documents that define what actions are allowed or denied on which resources.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::medbridge-patient-files/*"
    }
  ]
}
```

Two types:
- **AWS managed policies** — pre-built by AWS. Convenient but often too broad. Use as a starting point, not in production.
- **Customer managed policies** — you write them. Specific, least privilege, the right approach for production.

### Least Privilege
Only grant the access needed to do the job. No more, no less.

Not just which services — which **actions** on which **specific resources**:

| Too broad | Least privilege |
|---|---|
| Full S3 access | `s3:GetObject` on `arn:aws:s3:::medbridge-patient-files/*` only |
| Full DynamoDB access | `dynamodb:PutItem` on the specific table ARN only |
| Admin access | Exactly the actions the role needs, nothing else |

A Lambda that reads patient files and writes to DynamoDB needs:
- `s3:GetObject` on the specific bucket
- `dynamodb:PutItem` on the specific table
- Nothing else — not `s3:DeleteObject`, not `dynamodb:Scan`, not access to any other bucket or table

### Permission Boundaries
The absolute ceiling on what an identity can ever do — regardless of what policies are attached.

Real world use — a developer can create IAM roles for their Lambda functions. Without a boundary they could attach admin access to that role and escalate their own privileges. A permission boundary caps what that role can ever have, even if someone tries to attach a more permissive policy.

Common in larger organizations where developers have some IAM access but privilege escalation needs to be prevented.

### IAM Best Practices
- **Never use the root account.** Create an admin IAM user immediately after account creation and lock the root credentials away.
- **Enable MFA on all human users.** Especially the root account and any admin users.
- **Use roles for services, not access keys.** An EC2 instance or Lambda with an IAM role is safer than embedding access keys in code.
- **Rotate access keys regularly.** If you must use access keys set a rotation policy.
- **Never hardcode credentials.** Not in code, not in environment variables, not in Terraform files. Use Secrets Manager or SSM Parameter Store.

## When would you use IAM?

Always — every resource, every service, every person in your AWS account needs IAM. The question is never whether to use IAM, it's whether your policies are tight enough.

Critical moments to think carefully about IAM:
- Any time a service needs to talk to another service
- Any time a developer needs access to AWS resources
- Any compliance requirement — HIPAA, PCI-DSS, FedRAMP all mandate least privilege

## Tips & gotchas

- **Explicit deny always wins.** An explicit deny in any policy overrides any allow — even if another policy allows it.
- **Never use `*` on sensitive resources in production.** `s3:*` on `*` is admin access to all S3. Always scope actions and resources.
- **Groups for people, roles for services.** Never create access keys for a Lambda function — use a role.
- **Audit regularly.** Use IAM Access Analyzer and AWS Config to find overly permissive policies and unused credentials.
- **Condition keys add extra control.** You can restrict access by IP address, time of day, MFA status, and more using condition keys in your policies.
- **Permission boundaries prevent privilege escalation.** Use them in any environment where developers have IAM access.
- **Trust policy vs permission policy.** A role has two parts — the trust policy (who can assume this role) and the permission policy (what the role can do). Both matter.
