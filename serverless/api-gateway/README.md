# API Gateway

## What is API Gateway?

API Gateway is a front facing gateway accessible via the internet that allows customers to interact with your compute backend. It sits in front of your Lambda functions and exposes a clean HTTPS endpoint that browsers, mobile apps, and third party services can call.

Without it Lambda has no public URL — no IP, no endpoint, nothing the outside world can reach. API Gateway gives your serverless backend a front door.

## Why do you need it?

Lambda alone cannot receive HTTP requests from the internet. API Gateway receives the request, translates it, invokes your Lambda, gets the response back, and returns it to the caller. It's the bridge between the public internet and your serverless backend.

On top of that it gives you:
- **Authentication** — verify who is calling before the request reaches Lambda
- **Throttling and rate limiting** — protect your backend from being overwhelmed
- **CORS** — control which domains can call your API
- **Logging** — every request logged to CloudWatch automatically

## REST API vs HTTP API

API Gateway offers two types — pick based on your requirements:

| | HTTP API | REST API |
|---|---|---|
| Cost | ~70% cheaper | More expensive |
| Speed | Faster | Slower |
| Best for | Most use cases — Lambda, Cognito auth, basic routing | Complex requirements — WAF, API keys, usage plans, request transformation |
| Compliance heavy projects | Not recommended | Yes — HIPAA, PCI-DSS |

**Simple rule:** Start with HTTP API. Only reach for REST API when you need WAF integration, per customer API keys, usage plans, or complex request/response transformation.

Real examples:
- **AgentFlow** — HTTP API. Straightforward Lambda routing with Cognito auth.
- **MedBridge** — REST API. HIPAA compliance, WAF integration, fine grained access control.
- **BetPulse** — REST API. PCI-DSS, API keys per client, usage plans to prevent abuse.

## Authorizers — Authentication at the gateway

An authorizer sits in front of your API and verifies every request before it reaches Lambda. Three types:

- **Cognito authorizer** — validates JWT tokens against a Cognito user pool. The most common pattern for user facing APIs.
- **Lambda authorizer** — custom auth logic in a Lambda function. Use for complex or non-standard auth requirements.
- **IAM authorizer** — for service to service calls inside AWS using IAM roles.

Without an authorizer your API is open to anyone with the URL.

## How it fits in the flow

Internet → API Gateway → Authorizer (Cognito) → Lambda → Response

API Gateway receives the request, checks the authorizer, invokes Lambda if auth passes, and returns the response. Lambda never touches unauthenticated traffic.

## When would you use API Gateway?

- Any serverless backend that needs a public HTTPS endpoint
- Mobile or web apps calling Lambda functions
- Microservices that need a single entry point with auth and routing
- Any project where you want throttling and rate limiting without building it yourself

## Tips & gotchas

- **Always use an authorizer in production.** An open API endpoint is an open door — lock it down with Cognito or a Lambda authorizer.
- **HTTP API for most projects.** It's cheaper, faster, and handles the majority of use cases. Don't reach for REST API unless you need its specific features.
- **CORS trips everyone up.** If your frontend can't reach your API the answer is almost always a missing CORS configuration. Enable it explicitly on your API and your Lambda response headers.
- **Throttling defaults exist but set your own.** API Gateway has default throttle limits but set explicit limits per route for production — prevents one noisy caller from affecting everyone else.
- **Stage variables for environments.** Use API Gateway stages (dev, staging, prod) with stage variables to point to different Lambda aliases or backends per environment.
- **Enable CloudWatch logging.** Off by default — turn it on. You can't debug API issues without request and response logs.
- **Lambda integration timeout is 29 seconds max.** API Gateway will cut off the request after 29 seconds regardless of your Lambda timeout setting. Design your functions to respond well within that window.
