# Docker — End to End Workflow

## When to Use What

| Situation | What You Need |
|---|---|
| Starting a new project | Dockerfile + .dockerignore |
| Running locally | docker-compose.yml |
| Pushing to AWS | ECR repository + tag + push |
| Automating deployments | GitHub Actions workflow |
| Deploying to Kubernetes | Kubernetes manifests |

---

## The Full Sequence — New Project

### Step 1 — Create .dockerignore FIRST
Before you write a single line of Dockerfile, create .dockerignore.
Why: your first build sets the baseline image size. If you forget this
step your first build will include Terraform state, node_modules, and
everything else in your repo. Cleaning that up after is annoying.

```bash
touch .dockerignore
# Add exclusions — see dockerignore-template in this registry
```

### Step 2 — Write your Dockerfile
Build your image recipe. Remember layer order matters for caching:
- Base image first
- Dependencies before code
- Code last

```bash
touch Dockerfile
# Write your Dockerfile — see template in this registry
```

### Step 3 — Build your image locally
```bash
docker build -t your-app-local .

# Verify it built and check the size
docker images
# If size is unexpectedly large — check your .dockerignore
```

### Step 4 — Run it locally to verify it works
```bash
docker run your-app-local

# Or run in background
docker run -d -p 8080:8080 your-app-local

# Check it's running
docker ps

# Check logs
docker logs 

# Stop it
docker stop 
```

### Step 5 — Write docker-compose.yml
For local development with one command:
```bash
touch docker-compose.yml
# Write your compose file — see template in this registry

# Run everything
docker compose up

# Stop everything
docker compose down
```

### Step 6 — Create ECR repository in AWS
```bash
aws ecr create-repository \
  --repository-name your-app-name \
  --region us-east-1
```

### Step 7 — Authenticate Docker to ECR
```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  .dkr.ecr.us-east-1.amazonaws.com
```

### Step 8 — Tag your image with ECR URI
```bash
docker tag your-app-local:latest \
  .dkr.ecr.us-east-1.amazonaws.com/your-app-name:latest

# The tag must match the ECR repository name EXACTLY
# This is the most common mistake — mismatched names
```

### Step 9 — Push to ECR
```bash
docker push \
  .dkr.ecr.us-east-1.amazonaws.com/your-app-name:latest

# Verify it's there
# Go to AWS Console → ECR → your repository
```

### Step 10 — Add GitHub Actions for automation
```bash
mkdir -p .github/workflows
touch .github/workflows/docker-build-push.yml
# Copy from github-actions-ecr.yml in this registry
# Update the repository name in the last two lines
```

Add these GitHub Secrets to your repo:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`  
- `AWS_ACCOUNT_ID`

Now every push to main automatically builds and pushes your image.

---

## The Full Sequence — Existing Project

If Docker is already set up and you just want to rebuild and push:

```bash
# Build new image
docker build -t your-app-local .

# Authenticate to ECR (tokens expire after 12 hours)
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  .dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag your-app-local:latest \
  .dkr.ecr.us-east-1.amazonaws.com/your-app-name:latest
docker push \
  .dkr.ecr.us-east-1.amazonaws.com/your-app-name:latest
```

---

## Common Mistakes and How to Fix Them

**Image size is huge**
```bash
# Check what's making it large
docker images
# Fix: add or update .dockerignore
# Rebuild: docker build -t your-app-local .
```

**Push fails with repository does not exist**
```bash
# Your tag doesn't match your ECR repository name
# Check your ECR repo name
aws ecr describe-repositories --region us-east-1

# Re-tag with correct name
docker tag your-app-local:latest \
  .dkr.ecr.us-east-1.amazonaws.com/CORRECT-NAME:latest
```

**Push fails with no basic auth credentials**
```bash
# Your ECR login expired — re-authenticate
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  .dkr.ecr.us-east-1.amazonaws.com
```

**Container exits immediately**
```bash
# Check logs to see what happened
docker logs 
# Usually means your CMD exits after running
# Need a long-running process in CMD
```
