# 🐳 Docker + Kubernetes — Detailed Documentation

> **Language / Idioma:** 🇬🇧 **English** (current) | [🇪🇸 Español](../es/docker-kubernetes.md)
>
> ← [Back to main README](../../README.md) | [Folder README](../../dockers-kubernetes/README.md)

---

## 📖 Overview

This module covers the full containerization journey: from writing your first `Dockerfile` to deploying a production-grade multi-service application on **Google Kubernetes Engine (GKE)**.

**Learning path:**
```
Dockerfile basics
    → Multi-container Docker Compose
        → Kubernetes objects (Pods, Deployments, Services)
            → Production K8s (Ingress, PVC, Secrets)
                → Full CI/CD to GKE
```

---

## 🐳 Docker Fundamentals

### How Docker Works
```
Dockerfile ──build──→ Image ──run──→ Container
                         │
                   docker push
                         │
                    Docker Hub
                         │
                   docker pull (by anyone)
```

### Key Dockerfile Instructions

```dockerfile
FROM alpine                     # Base image
WORKDIR /app                    # Set working directory
COPY package*.json ./           # Copy files into image
RUN npm ci                      # Run command during build (creates a layer)
EXPOSE 8080                     # Document which port the app uses
CMD ["node", "server.js"]       # Default command to run the container
```

### Image Layer Caching
Order instructions from least-changed to most-changed to maximize cache hits:
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./     # ← rarely changes → cached most of the time
RUN npm ci                # ← only reruns when package.json changes
COPY . .                  # ← source code changes often
CMD ["node", "server.js"]
```

---

## 📦 Project Walkthroughs

### Project 1 — Redis Image
**Concept:** Your first custom Docker image.
```dockerfile
FROM alpine
RUN apk add --update redis
CMD ["redis-server"]
```
```bash
docker build -t my-redis .
docker run my-redis
```

---

### Project 2 — Simple Node.js Web App
**Concept:** Containerize a real application. Map host port to container port.
```bash
docker build -t simple-web .
docker run -p 8080:8080 simple-web
# Visit http://localhost:8080
```

---

### Project 3 — Visits App (Docker Compose)
**Concept:** Multi-container applications. Docker Compose handles networking, startup order, and restart policies.

```yaml
# docker-compose.yml
version: '3'
services:
  redis-server:
    image: "redis:alpine"
    restart: always
  node-app:
    build: .
    restart: always
    ports:
      - "4001:8080"
    depends_on:
      - redis-server
```
```bash
docker compose up --build
docker compose down
```

---

### Project 4 — CI Workflow (Multi-stage Builds)
**Concept:** Separate `Dockerfile.dev` (with dev tools) and production `Dockerfile` (multi-stage). Only the compiled output goes into the final image.

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production (only serves static files)
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

---

### Project 5 — Multi-Container App (Full Stack)
**Concept:** Real-world architecture with 5 services behind an Nginx reverse proxy.

```
Browser → Nginx :80
               ├── /      → React Client :3000
               └── /api   → Express API  :5000
                                  ├── Redis     :6379
                                  ├── Postgres  :5432
                                  └── Worker (background, no HTTP)
```

```bash
cd app/
docker compose up
# Full app at http://localhost
```

---

### Project 6 — Simple Kubernetes
**Concept:** Core K8s objects. Deploy a single app and expose it.

```yaml
# client-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: client-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      component: web
  template:
    metadata:
      labels:
        component: web
    spec:
      containers:
        - name: client
          image: elpachanga1/multi-client
          ports:
            - containerPort: 3000
```

```bash
kubectl apply -f client-deployment.yaml
kubectl apply -f client-node-port.yaml
kubectl get pods
kubectl get services
kubectl describe pod <pod-name>
```

**K8s Object Types:**

| Object | Purpose |
|--------|---------|
| `Pod` | Smallest deployable unit, wraps 1+ containers |
| `Deployment` | Manages a set of pod replicas with rolling updates |
| `Service (NodePort)` | Exposes pods on a static port on every node |
| `Service (ClusterIP)` | Internal communication between pods |
| `Service (LoadBalancer)` | External access via cloud load balancer |
| `Ingress` | HTTP routing rules (path/host based) |
| `PersistentVolumeClaim` | Request for persistent disk storage |
| `Secret` | Store sensitive data (base64 encoded) |

---

### Project 7 — Multi-Container Kubernetes (Production GKE)
**Concept:** Previous multi-container app fully migrated to production Kubernetes on GKE. Full CI/CD with GitHub Actions.

**Architecture:**
```
Internet → LoadBalancer Service
                  │
           Nginx Ingress Controller
                  ├── /         → client-deployment (React)
                  └── /api      → server-deployment (Express API)
                                        ├── redis-cluster-ip-service
                                        ├── postgres-cluster-ip-service
                                        └── worker-deployment (no service)

Storage: postgres-pvc (PersistentVolumeClaim)
Secrets: pgpassword (kubectl create secret generic)
```

**Key K8s manifests in `k8s/`:**
```
k8s/
├── client-deployment.yaml
├── client-cluster-ip-service.yaml
├── server-deployment.yaml
├── server-cluster-ip-service.yaml
├── worker-deployment.yaml
├── redis-deployment.yaml
├── redis-cluster-ip-service.yaml
├── postgres-deployment.yaml
├── postgres-cluster-ip-service.yaml
├── database-persistent-volume-claim.yaml
└── ingress-service.yaml
```

**Setup Secrets:**
```bash
kubectl create secret generic pgpassword --from-literal PGPASSWORD=yourpassword
kubectl get secrets
```

**CI/CD Pipeline (GitHub Actions):**
```
push to main
    → Run client tests
    → Build Docker images (client, server, worker, nginx)
    → Push to Docker Hub
    → Authenticate to GKE
    → kubectl apply -f k8s/
    → kubectl set image <deployment> <image>:<SHA>
```

**Local Development with Skaffold:**
```bash
# Install Skaffold
choco install skaffold   # Windows

# Start dev loop (auto rebuild/redeploy on file save)
skaffold dev
```

---

## 🔑 Commands Reference

```bash
# Docker
docker build -t name:tag .
docker run -p 8080:80 -d name:tag
docker ps                          # list running containers
docker ps -a                       # list all containers
docker logs <container-id>
docker exec -it <container-id> sh
docker push username/image:tag
docker pull username/image:tag
docker image ls
docker container rm <id>
docker image rm <id>

# Docker Compose
docker compose up --build
docker compose up -d               # detached mode
docker compose down
docker compose logs -f
docker compose ps

# Kubernetes
kubectl apply -f file.yaml
kubectl apply -f directory/        # apply all YAMLs in folder
kubectl get pods / svc / deploy / ingress / pvc / secrets
kubectl describe pod <name>
kubectl logs <pod-name> [-f]       # -f to follow
kubectl exec -it <pod-name> -- sh
kubectl delete -f file.yaml
kubectl scale deployment <name> --replicas=5
kubectl rollout restart deployment/<name>
kubectl get all                    # show everything
```

---

## 🔗 References

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Skaffold Documentation](https://skaffold.dev/)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [nginx-ingress Controller](https://kubernetes.github.io/ingress-nginx/)
