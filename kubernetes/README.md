# Kubernetes — Container Orchestration Reference

## What Kubernetes Is and Why It Exists

Docker solves packaging. Kubernetes solves the question that comes next: how do you run and manage hundreds or thousands of containers across many machines in production?

You could run containers manually with Docker on EC2 instances. For one or two containers that works fine. But production applications aren't one container. They're a frontend, an API, a worker, a cache client, a background job processor — maybe twenty separate services. Each one needs to:

- Stay running even when it crashes
- Scale up when traffic increases
- Scale back down when traffic drops
- Get updated without users noticing downtime
- Have its traffic routed correctly as pods come and go

Managing all of that manually across dozens of EC2 instances is an operations nightmare. Kubernetes handles it automatically through a control loop that runs constantly: observe the desired state you defined, compare it to actual state, take action to reconcile any difference.

---

## The Mental Model

If you've built Auto Scaling Groups in AWS, you already understand the core concept. Kubernetes is the same idea applied to containers instead of EC2 instances.

| AWS Concept | Kubernetes Equivalent |
|---|---|
| EC2 Instance | Node |
| Auto Scaling Group | Deployment |
| Desired capacity | replicas |
| Min/Max size | minReplicas/maxReplicas in HPA |
| Target tracking policy | HorizontalPodAutoscaler |
| ALB | Service (LoadBalancer type) |
| Target Group | Service selector |
| Health check | Pod liveness/readiness probes |
| Launch template | Pod spec in Deployment template |

---

## The Three Resources You Always Write

Every application deployment in Kubernetes requires three things:

### 1. Deployment
Defines what runs and how many copies. The Deployment tells Kubernetes "I want 2 copies of this container always running." If one crashes, Kubernetes replaces it. If you push a new image, Kubernetes rolls it out one pod at a time so users never see downtime.

Key fields:
- `replicas` — how many pods to maintain
- `selector.matchLabels` — how the Deployment finds its pods (by label)
- `template.spec.containers.image` — which container image to run
- `resources.requests` — minimum resources guaranteed for scheduling
- `resources.limits` — maximum resources the pod can use before being throttled or killed

### 2. Service
Gives your pods a stable endpoint. Pods are temporary — they get replaced constantly and each new pod gets a new IP address. The Service sits in front of them with a stable IP and DNS name, routing traffic to whatever pods are currently healthy based on label matching.

Key fields:
- `selector` — matches pod labels to determine which pods receive traffic
- `port` — what the Service listens on inside the cluster
- `targetPort` — what port on the pod to forward traffic to
- `nodePort` — external port on the node (NodePort type only, range 30000-32767)

### 3. HorizontalPodAutoscaler
Scales your replica count automatically based on a metric. Watches CPU utilization (or custom metrics) and adds pods when load increases, removes them when load drops — down to your minimum.

Key fields:
- `scaleTargetRef` — which Deployment to scale
- `minReplicas` — floor, always keep at least this many running
- `maxReplicas` — ceiling, never exceed this many
- `averageUtilization` — target CPU percentage that triggers scaling

---

## How Labels Connect Everything

Labels are the glue that holds Kubernetes together. They're key-value pairs attached to resources that other resources use to find each other.

Your Deployment has a `selector` that says "manage pods with label `app: medbridge`."
Your pod template has a label `app: medbridge`.
Your Service has a `selector` that says "route traffic to pods with label `app: medbridge`."

When a pod crashes and gets replaced, the new pod gets the same label automatically. The Service immediately starts routing to it. The Deployment knows it's one of its managed pods. No manual wiring — labels do it all.

If your selector and your pod labels don't match exactly, nothing works. This is the most common beginner mistake.

---

## The Layer Model
Internet

↓

Service (stable endpoint, routes by label)

↓

Deployment (manages pod count and updates)

↓

Pods (running containers)

↓

Containers (your application)

Traffic enters through the Service. The Service routes to healthy pods based on label matching. The Deployment ensures the right number of pods are always running. The HPA watches metrics and tells the Deployment to adjust replica count.

---

## Minikube vs EKS

**Minikube** runs a single-node Kubernetes cluster inside a Docker container on your local machine. One node acts as both the control plane and worker. Good for learning and local testing. Not for production.

**EKS (Elastic Kubernetes Service)** is AWS-managed Kubernetes. AWS runs the control plane — you never touch it. You provision worker nodes (EC2 instances) and deploy your workloads. Your manifests are identical between minikube and EKS — only the infrastructure underneath changes.

The key difference for local development: minikube has its own separate Docker registry. Images built on your machine don't automatically exist inside minikube. You have to explicitly load them:

```bash
minikube image load your-image:latest
```

And set `imagePullPolicy: Never` in your Deployment so Kubernetes doesn't try to pull from a remote registry.

In production on EKS your image lives in ECR and `imagePullPolicy` is `Always` or `IfNotPresent`.

---

## Why This Matters for Your Career

Kubernetes shows up on every mid-to-senior DevOps and cloud engineering job posting. It's the industry standard for running containerized applications at scale. Companies choose it because:

- **Portability** — same manifests work on AWS, GCP, Azure, or on-prem
- **Team autonomy** — each team owns their Deployment, releases independently
- **Self-healing** — crashed pods restart automatically without human intervention
- **Rolling updates** — new versions deploy without downtime
- **Independent scaling** — API pods scale separately from worker pods

Your four AWS projects used Lambda, ECS Fargate, and EC2 for compute. Kubernetes is the third major pattern — and the most widely used in enterprise environments.

The path: minikube for learning → EKS for production → CKA certification when you're ready to specialize.