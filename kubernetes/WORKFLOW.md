# Kubernetes — End to End Workflow

## When to Use What

| Situation | What You Need |
|---|---|
| Learning locally | minikube + kubectl |
| Running in AWS production | EKS + kubectl |
| Deploying an app | deployment.yaml |
| Exposing an app | service.yaml |
| Auto scaling an app | hpa.yaml |
| Debugging a crash | kubectl logs + describe |

---

## The Full Sequence — Local Development with Minikube

### Step 1 — Start your cluster
```bash
minikube start

# Verify it's running
kubectl get nodes
# Should show: minikube   Ready   control-plane
```

### Step 2 — Build your Docker image locally
```bash
# Must be done BEFORE loading into minikube
docker build -t your-app-local .
```

### Step 3 — Load image into minikube
```bash
# Minikube has its own Docker registry — separate from yours
# Your local images don't automatically exist inside minikube
minikube image load your-app-local:latest

# Verify it loaded
minikube image ls | grep your-app
```

### Step 4 — Write your deployment.yaml
```bash
touch deployment.yaml
# Copy from template in this registry
# Key things to set:
#   name: your-app-name
#   image: your-app-local:latest
#   imagePullPolicy: Never  ← critical for minikube
#   containerPort: your port
```

### Step 5 — Apply the Deployment
```bash
kubectl apply -f deployment.yaml

# Watch pods come up
kubectl get pods
# Wait for STATUS: Running or Completed
```

### Step 6 — Debug if pods aren't running
```bash
# Check what's happening
kubectl describe pod 

# Check logs
kubectl logs 

# Common statuses and what they mean:
# ErrImagePull / ImagePullBackOff  → image not found, check name and imagePullPolicy
# ErrImageNeverPull                → imagePullPolicy: Never but image not in minikube
# CrashLoopBackOff                 → container starts but exits, check logs
# Completed                        → container ran and exited cleanly (no long-running process)
# Pending                          → waiting for resources, cluster may be starting
```

### Step 7 — Write your service.yaml
```bash
touch service.yaml
# Copy from template in this registry
# Key things to set:
#   selector app: must match your pod labels
#   targetPort: must match your containerPort
#   nodePort: 30000-32767 range
```

### Step 8 — Apply the Service
```bash
kubectl apply -f service.yaml

# Verify it's running
kubectl get services
# Should show your service with CLUSTER-IP and PORT(S)
```

### Step 9 — Write your hpa.yaml
```bash
touch hpa.yaml
# Copy from template in this registry
# Key things to set:
#   scaleTargetRef.name: must match your Deployment name
#   minReplicas: minimum pods always running
#   maxReplicas: ceiling during peak load
#   averageUtilization: CPU % that triggers scaling
```

### Step 10 — Apply the HPA
```bash
kubectl apply -f hpa.yaml

# Verify
kubectl get hpa
# TARGETS will show cpu: /70% until pods generate metrics
```

### Step 11 — Commit your manifests
```bash
git add deployment.yaml service.yaml hpa.yaml
git commit -m "feat: add Kubernetes manifests for deployment, service, and HPA"
git push
```

---

## The Full Sequence — Production on EKS

Production flow is the same but with two differences:

**Image comes from ECR not local:**
```yaml
# deployment.yaml
image: .dkr.ecr.us-east-1.amazonaws.com/your-app:latest
imagePullPolicy: Always  # Pull from ECR every time
```

**Connect kubectl to EKS:**
```bash
aws eks update-kubeconfig --region us-east-1 --name your-cluster-name
kubectl get nodes  # Should show your EKS worker nodes
```

Everything else — apply, get pods, logs, describe — is identical.

---

## Day to Day Commands

**Check what's running:**
```bash
kubectl get pods          # All pods and their status
kubectl get services      # All services
kubectl get hpa           # All autoscalers
kubectl get all           # Everything at once
```

**Deploy a change:**
```bash
# After rebuilding your image and loading into minikube
kubectl rollout restart deployment your-app-name

# Watch the rollout
kubectl rollout status deployment your-app-name
```

**Debug a problem:**
```bash
# See detailed info about a pod
kubectl describe pod 

# See what the container printed
kubectl logs 

# Get a shell inside a running container
kubectl exec -it  -- /bin/bash
```

**Clean up:**
```bash
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
kubectl delete -f hpa.yaml

# Or delete everything at once
kubectl delete -f .

# Stop minikube when done
minikube stop
```

---

## The Order That Always Works

docker build        → create the image
minikube image load → put image inside minikube
kubectl apply -f deployment.yaml  → run the pods
kubectl get pods    → verify pods are up
kubectl apply -f service.yaml     → expose the pods
kubectl apply -f hpa.yaml         → enable autoscaling
git add + commit + push           → save your work


Never skip step 2 for local development.
Never skip step 7 after it works.
