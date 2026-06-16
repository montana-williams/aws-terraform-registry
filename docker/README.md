# Docker — Containerization Reference

## What is Docker and Why Does It Exist

Before Docker, shipping software meant shipping instructions: "install Python 3.11, install these libraries, set these environment variables, make sure you're on Ubuntu not CentOS." It worked on your machine. It broke on the server. It broke differently on your teammate's machine.

Docker solves this by packaging the application AND its entire runtime environment into one portable unit called a container. The container carries everything it needs with it. It runs identically on your laptop, on a CI/CD server, on an EC2 instance, or in EKS. Same image, same behavior, everywhere.

This is why every DevOps job posting you'll ever read lists Docker. It's not optional infrastructure knowledge — it's the foundation of how modern applications are deployed.

---

## The Three Core Concepts

**Image** — a read-only blueprint for a container. Built from a Dockerfile. Think of it like an AMI in AWS — a snapshot that can be used to create instances. Stored in a registry like ECR or Docker Hub.

**Container** — a running instance of an image. Like an EC2 instance spun from an AMI. You can run ten containers from one image simultaneously. Containers are temporary — they start, run, and stop. The image persists.

**Dockerfile** — the recipe for building an image. A set of instructions executed top to bottom. Every instruction creates a new layer.

---

## How Layers and Caching Work

This is the most important concept to internalize because it affects how you write every Dockerfile.

Docker builds images layer by layer. Each instruction in your Dockerfile is one layer. Docker caches each layer. On rebuild, if nothing in a layer has changed, Docker skips it and uses the cached version.

The practical consequence: **put things that change least at the top, things that change most at the bottom.**

Your dependencies (pip install, npm ci) change rarely. Your application code changes constantly. If you copy your code first and then install dependencies, every single code change forces Docker to reinstall all your packages from scratch. That's the difference between a 2-second rebuild and a 3-minute rebuild.

**Wrong order:**
```dockerfile
COPY . .                    # Code changes every commit
RUN pip install -r requirements.txt  # Now this re-runs every commit too
```

**Right order:**
```dockerfile
COPY requirements.txt .     # Only changes when you add/remove packages
RUN pip install -r requirements.txt  # Cached — skipped unless requirements changed
COPY . .                    # Code changes every commit — only this layer rebuilds
```

---

## What .dockerignore Does and Why It Matters

When you run `docker build`, Docker sends your entire project directory to the Docker daemon as the build context before a single instruction executes. Everything in that directory gets bundled up and transferred.

Without `.dockerignore`:
- Your `.terraform` directories go in
- Your `*.tfstate` files go in — containing real infrastructure details
- Your `node_modules` go in — potentially gigabytes
- Result: build context goes from kilobytes to gigabytes, build takes minutes instead of seconds

With `.dockerignore`:
- Only what your container actually needs gets sent
- Build context drops dramatically
- Build is fast
- Sensitive files never end up inside a container image

Real example from this project: AgentFlow's first build sent 1.04GB and took 69 seconds just for the context transfer. After adding `.dockerignore` it dropped to 2.15KB and transferred instantly. Image size went from 1.62GB to 255MB.

The rule: **always create `.dockerignore` before your first build.**

---

## What docker-compose Does

`docker run` with all its flags is fine for learning but impractical for real work:

```bash
docker run -d -p 8080:8080 --name app --env ENV=local --restart unless-stopped app-local:latest
```

That's one command for one container. Add a database, a cache, and a worker and you have four of these to remember and keep in sync.

`docker-compose.yml` is the declarative version. You define everything in a file, commit it to Git, and anyone on your team runs the exact same environment with:

```bash
docker compose up
```

It also automatically creates a shared network so containers can reach each other by service name. Your API container can connect to a database container just by using `db` as the hostname — no IP addresses, no manual networking.

---

## The ECR Workflow

ECR (Elastic Container Registry) is AWS's private Docker registry. It's where your images live in AWS so ECS, EKS, Lambda, or any other compute service can pull them.

The manual workflow:
```bash
# 1. Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin .dkr.ecr.us-east-1.amazonaws.com

# 2. Build your image
docker build -t my-app .

# 3. Tag with ECR URI
docker tag my-app:latest .dkr.ecr.us-east-1.amazonaws.com/my-app:latest

# 4. Push
docker push .dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

Why tag separately? Your local image is named `my-app`. ECR doesn't know what `my-app` is — it only accepts images addressed to its own URI. Tagging creates an alias that maps your local image name to the ECR address. Push sends it there.

The GitHub Actions workflow in this directory automates all four steps on every push to main.

---

## Common Issues and What They Mean

**ErrImagePull** — Kubernetes can't find the image. Either the image name is wrong, the registry requires authentication, or (for minikube) the image exists locally but not inside minikube's separate Docker environment.

**CrashLoopBackOff** — The container starts but exits immediately. Kubernetes sees the exit as a crash and keeps restarting it. Usually means your CMD exits after running (like a print statement) instead of keeping a process running. In production your CMD should start a long-running server process.

**ImagePullBackOff** — Same as ErrImagePull but Kubernetes has given up retrying for now and is waiting before trying again.

**Build context too large** — You forgot `.dockerignore`. Check what's in your project directory and add exclusions.

---

## How This Connects to Your AWS Projects

Every project you've built has Lambda functions, ECS tasks, or EC2 instances running application code. Docker is how that code gets packaged and shipped to those compute services in a professional environment.

The full production flow:
Developer pushes code to GitHub

↓

GitHub Actions builds Docker image

↓

Image pushed to ECR with commit SHA as tag

↓

ECS or EKS pulls image from ECR

↓

New containers replace old ones with zero downtime

You've built everything in that chain across your four projects. Docker is the packaging layer that makes it all work.