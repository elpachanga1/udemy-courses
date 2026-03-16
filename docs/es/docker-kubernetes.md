# 🐳 Docker + Kubernetes — Documentación Detallada

> **Idioma / Language:** 🇪🇸 **Español** (actual) | [🇬🇧 English](../en/docker-kubernetes.md)
>
> ← [Volver al README principal](../../README.md) | [README de la carpeta](../../dockers-kubernetes/README.md)

---

## 📖 Descripción General

Este módulo cubre el recorrido completo de contenedores: desde escribir tu primer `Dockerfile` hasta desplegar una aplicación multi-servicio de nivel producción en **Google Kubernetes Engine (GKE)**.

**Ruta de aprendizaje:**
```
Fundamentos de Dockerfile
    → Docker Compose con múltiples contenedores
        → Objetos de Kubernetes (Pods, Deployments, Services)
            → K8s en producción (Ingress, PVC, Secrets)
                → CI/CD completo hacia GKE
```

---

## 🐳 Fundamentos de Docker

### Cómo Funciona Docker
```
Dockerfile ──build──→ Imagen ──run──→ Contenedor
                         │
                   docker push
                         │
                    Docker Hub
                         │
                   docker pull (cualquiera puede descargarlo)
```

### Instrucciones Clave del Dockerfile

```dockerfile
FROM alpine                     # Imagen base
WORKDIR /app                    # Directorio de trabajo
COPY package*.json ./           # Copiar archivos a la imagen
RUN npm ci                      # Comando que se ejecuta durante el build (crea una capa)
EXPOSE 8080                     # Documenta qué puerto usa la app
CMD ["node", "server.js"]       # Comando por defecto al ejecutar el contenedor
```

### Caché de Capas
Ordena las instrucciones de menos a más cambiantes para aprovechar el caché:
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./     # ← rara vez cambia → casi siempre en caché
RUN npm ci                # ← solo se vuelve a ejecutar si package.json cambia
COPY . .                  # ← el código fuente cambia frecuentemente
CMD ["node", "server.js"]
```

---

## 📦 Descripción de cada Proyecto

### Proyecto 1 — Imagen de Redis
**Concepto:** Tu primera imagen personalizada de Docker.
```dockerfile
FROM alpine
RUN apk add --update redis
CMD ["redis-server"]
```
```bash
docker build -t mi-redis .
docker run mi-redis
```

---

### Proyecto 2 — App Web Simple en Node.js
**Concepto:** Contenerizar una aplicación real. Mapeo de puertos, `COPY`, `WORKDIR`.
```bash
docker build -t simple-web .
docker run -p 8080:8080 simple-web
# Visitar http://localhost:8080
```

---

### Proyecto 3 — App Visits (Docker Compose)
**Concepto:** Orquestar múltiples contenedores localmente. La app Node.js cuenta visitas almacenadas en Redis.

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

### Proyecto 4 — CI Workflow (Builds Multi-etapa)
**Concepto:** `Dockerfile.dev` separado (con herramientas de desarrollo) y `Dockerfile` de producción (multi-etapa). Solo el resultado compilado va a la imagen final.

```dockerfile
# Etapa 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Etapa 2: Producción (solo sirve archivos estáticos)
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

---

### Proyecto 5 — App Multi-Contenedor (Full Stack)
**Concepto:** Arquitectura real con 5 servicios detrás de un proxy inverso Nginx.

```
Navegador → Nginx :80
               ├── /      → Cliente React  :3000
               └── /api   → API Express    :5000
                                  ├── Redis     :6379
                                  ├── Postgres  :5432
                                  └── Worker (background, sin HTTP)
```

```bash
cd app/
docker compose up
# App completa en http://localhost
```

---

### Proyecto 6 — Kubernetes Simple
**Concepto:** Objetos básicos de K8s. Desplegar un solo contenedor y exponerlo.

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
kubectl describe pod <nombre-del-pod>
```

**Tipos de objetos K8s:**

| Objeto | Propósito |
|--------|-----------|
| `Pod` | Unidad desplegable más pequeña, envuelve 1+ contenedores |
| `Deployment` | Gestiona un conjunto de réplicas de pods con actualizaciones continuas |
| `Service (NodePort)` | Expone pods en un puerto estático en cada nodo |
| `Service (ClusterIP)` | Comunicación interna entre pods |
| `Service (LoadBalancer)` | Acceso externo via balanceador de carga cloud |
| `Ingress` | Reglas de ruteo HTTP (por ruta o host) |
| `PersistentVolumeClaim` | Solicitud de almacenamiento persistente en disco |
| `Secret` | Almacenar datos sensibles (codificado en base64) |

---

### Proyecto 7 — Kubernetes Multi-Contenedor (GKE Producción)
**Concepto:** La app multi-contenedor del Proyecto 5 migrada completamente a Kubernetes de producción en GKE. CI/CD completo con GitHub Actions.

**Arquitectura:**
```
Internet → LoadBalancer Service
                  │
           Nginx Ingress Controller
                  ├── /         → client-deployment (React)
                  └── /api      → server-deployment (API Express)
                                        ├── redis-cluster-ip-service
                                        ├── postgres-cluster-ip-service
                                        └── worker-deployment (sin servicio)

Almacenamiento: postgres-pvc (PersistentVolumeClaim)
Secretos: pgpassword (kubectl create secret generic)
```

**Configurar Secretos:**
```bash
kubectl create secret generic pgpassword --from-literal PGPASSWORD=tucontraseña
kubectl get secrets
```

**Pipeline CI/CD (GitHub Actions):**
```
push a main
    → Ejecutar tests del cliente
    → Construir imágenes Docker (client, server, worker, nginx)
    → Subir a Docker Hub
    → Autenticarse en GKE
    → kubectl apply -f k8s/
    → kubectl set image <deployment> <imagen>:<SHA>
```

**Desarrollo Local con Skaffold:**
```bash
# Instalar Skaffold en Windows
choco install skaffold

# Iniciar ciclo de desarrollo (auto rebuild/redeploy al guardar archivos)
skaffold dev
```

---

## 🔑 Referencia de Comandos

```bash
# Docker
docker build -t nombre:tag .
docker run -p 8080:80 -d nombre:tag
docker ps                            # listar contenedores en ejecución
docker ps -a                         # listar todos los contenedores
docker logs <id-contenedor>
docker exec -it <id-contenedor> sh
docker push usuario/imagen:tag
docker pull usuario/imagen:tag
docker image ls
docker container rm <id>
docker image rm <id>

# Docker Compose
docker compose up --build
docker compose up -d                 # modo detached (background)
docker compose down
docker compose logs -f
docker compose ps

# Kubernetes
kubectl apply -f archivo.yaml
kubectl apply -f directorio/         # aplicar todos los YAMLs de la carpeta
kubectl get pods / svc / deploy / ingress / pvc / secrets
kubectl describe pod <nombre>
kubectl logs <nombre-pod> [-f]       # -f para seguir en tiempo real
kubectl exec -it <nombre-pod> -- sh
kubectl delete -f archivo.yaml
kubectl scale deployment <nombre> --replicas=5
kubectl rollout restart deployment/<nombre>
kubectl get all                      # ver todo
```

---

## 🔗 Referencias

- [Documentación de Docker](https://docs.docker.com/)
- [Documentación de Kubernetes](https://kubernetes.io/docs/home/)
- [Documentación de Skaffold](https://skaffold.dev/)
- [Documentación de GKE](https://cloud.google.com/kubernetes-engine/docs)
- [nginx-ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Guía de configuración GitHub Actions — Proyecto 7](../../dockers-kubernetes/7.%20multi-container-k8s/GITHUB_ACTIONS_SETUP.md)
- [Guía de Debugging — Proyecto 7](../../dockers-kubernetes/7.%20multi-container-k8s/DEBUGGING_GUIDE.md)
