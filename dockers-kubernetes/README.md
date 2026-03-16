# 🐳 Docker + Kubernetes — Containerization & Orchestration Labs

> **Language / Idioma:** 🇬🇧 **English** (current) | [🇪🇸 Español](../docs/es/docker-kubernetes.md)
>
> ← [Back to main README](../README.md) · [Detailed EN docs](../docs/en/docker-kubernetes.md) · [Docs ES](../docs/es/docker-kubernetes.md)

A progressive learning journey from writing your first `Dockerfile` to running a production-grade multi-service application on **Google Kubernetes Engine (GKE)** with a full CI/CD pipeline via GitHub Actions.

---

## 🎯 What You'll Learn

- Build custom Docker images and push them to Docker Hub
- Manage multi-container apps locally with Docker Compose
- Deploy and scale workloads on Kubernetes
- Configure Ingress controllers, Persistent Volumes, and Secrets
- Build automated CI/CD pipelines that deploy to GKE

---

## 📁 Projects Overview

| # | Folder | Topics | Stack |
|---|--------|--------|-------|
| 1 | [1. redis-image/](1.%20redis-image/) | Dockerfile basics, Alpine, RUN/CMD | Docker, Redis, Alpine |
| 2 | [2. simple-web/](2.%20simple-web/) | Containerizing a Node.js app | Docker, Node.js |
| 3 | [3. visits-docker-compose/](3.%20visits-docker-compose/) | Multi-container with Docker Compose | Docker Compose, Node.js, Redis |
| 4 | [4. ci-workflow/](4.%20ci-workflow/) | Multi-stage builds, CI/CD, AWS deployment | Docker, Nginx, CI/CD |
| 5 | [5. multi-container/](5.%20multi-container/) | Full-stack multi-service app with Nginx reverse proxy | Docker Compose, React, Express, Redis, Postgres, Nginx |
| 6 | [6. simple-k8s/](6.%20simple-k8s/) | Kubernetes basics: Pods, Deployments, Services | kubectl, K8s |
| 7 | [7. multi-container-k8s/](7.%20multi-container-k8s/) | Production K8s deployment on GKE with CI/CD | K8s, GKE, GitHub Actions, Skaffold |

---

## 🔬 Project Details

### 1. Redis Image
**Learning:** Docker fundamentals — base images, `RUN`, `CMD`, layer caching.  
Build a custom Docker image that installs and starts Redis using an Alpine base — minimal and fast.
```bash
docker build -t my-redis .
docker run my-redis
```

### 2. Simple Web App
**Learning:** Containerizing a real Node.js application, port mapping, `COPY`, `WORKDIR`.
```bash
docker build -t simple-web .
docker run -p 8080:8080 simple-web
```

### 3. Visits — Docker Compose
**Learning:** Multi-container orchestration locally. Node.js app tracks visit counts stored in Redis. `depends_on`, named services, restart policies.
```bash
docker compose up
# App on http://localhost:4001
```

### 4. CI Workflow
**Learning:** Multi-stage Docker builds (dev + production), CI/CD integration. The frontend app has separate stages for testing and production.
```bash
docker build -f Dockerfile.dev -t frontend-dev .
docker build -t frontend-prod .
```

### 5. Multi-Container App
**Learning:** Full-stack application architecture with Nginx as reverse proxy. Services: React (client), Express API (server), Worker (Fibonacci calculation), Redis (cache), Postgres (DB).
```bash
cd app/
docker compose up
```
Architecture:
```
Browser → Nginx (port 80)
              ├── / → React Client (port 3000)
              └── /api → Express Server (port 5000)
                              ├── Redis (port 6379)
                              ├── Postgres (port 5432)
                              └── Worker (subscribes to Redis)
```

### 6. Simple Kubernetes
**Learning:** Core Kubernetes objects — Pods, Deployments, NodePort Services. Deploy a single container and expose it.
```bash
kubectl apply -f client-deployment.yaml
kubectl apply -f client-node-port.yaml
kubectl get pods
kubectl get services
```

### 7. Multi-Container Kubernetes (Production)
**Learning:** Production-grade Kubernetes. Full application from Project 5, migrated to K8s on GKE with:
- **Ingress** (nginx-ingress) for path-based routing
- **ClusterIP Services** for internal communication
- **Persistent Volume Claims** for Postgres data
- **Kubernetes Secrets** for DB passwords
- **Skaffold** for local K8s development
- **GitHub Actions** CI/CD pipeline (build → push to Docker Hub → deploy to GKE)

```bash
# Local development with Skaffold
skaffold dev

# Apply all k8s manifests
kubectl apply -f k8s/

# Check deployments
kubectl get deployments
kubectl get services
kubectl get ingress
```

---

## 🛠️ Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| Docker Desktop | Build & run containers | [docker.com](https://www.docker.com/products/docker-desktop/) |
| kubectl | K8s CLI | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/) |
| Skaffold | Local K8s dev loop | [skaffold.dev](https://skaffold.dev/docs/install/) |
| Google Cloud SDK | GKE access | [cloud.google.com](https://cloud.google.com/sdk/docs/install) |
| Terraform | Infrastructure | [hashicorp.com](https://developer.hashicorp.com/terraform/downloads) |

---

## ⚡ Key Commands

```bash
# Docker
docker build -t image-name .
docker run -p <host>:<container> image-name
docker compose up --build
docker compose down

# Kubernetes
kubectl apply -f <manifest.yaml>
kubectl get pods / services / deployments / ingress
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/sh
kubectl delete -f <manifest.yaml>

# Skaffold
skaffold dev          # watch & rebuild on file changes
skaffold run          # one-shot build & deploy
skaffold delete       # clean up K8s resources
```

---

## 📄 More Documentation

- [Detailed English docs](../docs/en/docker-kubernetes.md)
- [Documentación detallada en español](../docs/es/docker-kubernetes.md)
- [Kubernetes Docs](https://kubernetes.io/docs/home/)
- [Docker Docs](https://docs.docker.com/)
- [K8s — Project 7 GitHub Actions Setup](7.%20multi-container-k8s/GITHUB_ACTIONS_SETUP.md)
- [K8s — Project 7 Debugging Guide](7.%20multi-container-k8s/DEBUGGING_GUIDE.md)
