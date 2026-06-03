# WAF — Web Application Firewall

## What is WAF?

A Web Application Firewall that prevents and blocks malicious patterns at the application layer. Unlike a security group that only sees IP addresses and ports, WAF reads the actual content of HTTP requests and blocks threats like SQL injection, cross site scripting, known bad IPs, and geo restricted traffic.

It sits in front of your public facing resources and filters out malicious traffic before it ever reaches your application.

## Why do you need it?

Security groups and NACLs protect at the network level — they can't see inside an HTTP request. A SQL injection attack comes in on port 443 just like legitimate traffic. WAF is the layer that understands what's actually inside the request and blocks it if it looks malicious.

For compliance heavy projects like HIPAA and PCI-DSS WAF is not optional — it's a requirement.

## What WAF protects against

- **SQL injection** — malicious SQL in form fields trying to manipulate your database
- **Cross site scripting (XSS)** — malicious scripts injected into web pages targeting your users
- **Known bad IPs** — AWS managed rules block known malicious IP ranges automatically
- **Rate limiting** — block IPs sending too many requests too fast, basic DDoS protection
- **Geo blocking** — block entire countries if your app has no legitimate users there
- **Custom patterns** — block specific request signatures, headers, or body content you define

## Key concepts

### AWS Managed Rules vs Custom Rules

**AWS Managed Rules** — pre-built rule sets maintained and updated by AWS as new threats emerge. Turn them on and they just work. No configuration needed. Cover the most common attack patterns out of the box.

Common managed rule groups:
- `AWSManagedRulesCommonRuleSet` — core protection against common web exploits
- `AWSManagedRulesSQLiRuleSet` — SQL injection protection
- `AWSManagedRulesKnownBadInputsRuleSet` — known malicious patterns
- `AWSManagedRulesAmazonIpReputationList` — known bad IPs

**Custom Rules** — your own logic on top of managed rules. Block a specific IP range, rate limit a specific endpoint, deny requests missing a required header, allow only your known IPs during dev.

### Count Mode vs Block Mode
Every WAF rule runs in one of two modes:
- **Block mode** — matching requests are blocked and return 403
- **Count mode** — matching requests are logged but allowed through

**Always start in count mode during development.** WAF managed rules are broad — your own test requests can look like attacks and get blocked. Count mode lets you see what would be blocked without actually blocking it. Switch to block mode once you've verified legitimate traffic isn't being caught.

### Where WAF attaches
WAF can sit in front of:
- **ALB** — protects your load balancer and everything behind it
- **CloudFront** — global edge protection before traffic hits your infrastructure
- **API Gateway REST API** — protects your API endpoints
  - **Important:** WAF only works with REST API, not HTTP API. This is one of the key reasons to choose REST API for compliance heavy projects.
- **AppSync** — GraphQL API protection

### Web ACL
A Web ACL (Access Control List) is the WAF resource that contains your rules. You create a Web ACL, add rules to it, and associate it with a resource like an ALB or API Gateway.

Rules are evaluated in priority order — lower number evaluated first, same as NACLs.

## When would you use WAF?

- Any public facing application handling sensitive data
- HIPAA, PCI-DSS, or FedRAMP compliance requirements
- Applications that have experienced or are likely targets of automated attacks
- Any API Gateway REST API in production
- Any ALB facing the public internet in a regulated environment

## Tips & gotchas

- **Start in count mode, switch to block mode.** WAF will block your own traffic during testing if you go straight to block mode. Count mode first, always.
- **WAF only works with REST API not HTTP API.** If you need WAF on API Gateway you must use REST API. Plan this before you build.
- **Associate the Web ACL after creating it.** Creating a WAF Web ACL doesn't protect anything until you associate it with a resource.
- **Regional vs CloudFront scope.** WAF Web ACLs are either regional (ALB, API Gateway, AppSync) or global (CloudFront). You can't use a regional ACL with CloudFront or vice versa. Decide scope at creation — it can't be changed.
- **Managed rules can block legitimate traffic.** Review count mode logs before switching to block. Add your own IP to an IP allow list during development.
- **Rate limiting protects against brute force.** Add a rate based rule to block IPs that send more than X requests per 5 minutes — simple and effective DDoS mitigation.
- **WAF logs go to CloudWatch, S3, or Kinesis.** Enable logging in production — you need visibility into what's being blocked and what's getting through.
- **Cost awareness.** WAF charges per Web ACL, per rule, and per million requests. Managed rule groups add cost on top. Plan your rule set before enabling everything.
