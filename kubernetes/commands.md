# Kubernetes Quick Reference

## Cluster
```bash
minikube start                          # Start local cluster
minikube stop                           # Stop local cluster
kubectl get nodes                       # Check cluster status
```

## Deploy
```bash
kubectl apply -f deployment.yaml        # Create or update deployment
kubectl apply -f service.yaml           # Create or update service
kubectl apply -f hpa.yaml              # Create or update HPA
kubectl apply -f .                      # Apply all yaml files in directory
```

## Inspect
```bash
kubectl get pods                        # List all pods and status
kubectl get services                    # List all services
kubectl get hpa                         # List autoscalers
kubectl get all                         # List everything
kubectl describe pod <pod-name>         # Detailed pod info
kubectl logs <pod-name>                 # View pod logs
```

## Debug
```bash
kubectl rollout restart deployment <name>   # Force pod replacement
kubectl rollout status deployment <name>    # Watch rollout progress
kubectl delete pod <pod-name>               # Delete pod (K8s recreates it)
```

## Images (minikube)
```bash
minikube image load <image>:latest      # Load local image into minikube
minikube image ls                       # List images in minikube
```

## State Lock (Terraform equivalent)
```bash
terraform force-unlock <lock-id>        # Release stuck state lock
```