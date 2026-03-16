# 🎓 DevOps e Ingeniería Cloud — Cursos de Udemy

> **Idioma / Language:**
> [🇬🇧 English](../../README.md) | 🇪🇸 **Español** (actual)

Repositorio multi-temático con laboratorios prácticos y ejercicios de varios cursos de DevOps / Cloud Engineering de Udemy. Cada carpeta es un **módulo de aprendizaje independiente** que cubre una tecnología diferente.

---

## 📦 Descripción de los Proyectos

| Módulo | Temas | Carpeta |
|--------|-------|---------|
| [🔧 Ansible + Terraform](#-ansible--terraform) | Automatización de infraestructura, gestión de configuraciones, VMs de Azure | [ansible/](../../ansible/) |
| [🐳 Docker + Kubernetes](#-docker--kubernetes) | Contenedores, orquestación, CI/CD, GKE | [dockers-kubernetes/](../../dockers-kubernetes/) |
| [⚙️ GitHub Actions](#️-github-actions) | Pipelines CI/CD, acciones personalizadas, secretos, contenedores de servicio | [github-actions/](../../github-actions/) |
| [📊 Prometheus + Grafana](#-prometheus--grafana) | Monitoreo, métricas, logs, alertas, OpenTelemetry | [prometheus-grafana/](../../prometheus-grafana/) |

---

## 🔧 Ansible + Terraform

**Carpeta:** [ansible/](../../ansible/)

Aprende infraestructura como código con **Terraform** para aprovisionar recursos en la nube y **Ansible** para gestión de configuraciones. Los laboratorios se ejecutan contra máquinas virtuales de Azure aprovisionadas dinámicamente, usando WSL Ubuntu como nodo de control.

**Tecnologías clave:** Ansible · Terraform · Azure · WSL Ubuntu  
**Temas:** Playbooks · Roles · Handlers · Loops · Condiciones · Tags · Variables · Ansible Vault · Inventario dinámico

📄 **Documentación:**
- [Documentación detallada en español](ansible.md)
- [Detailed English docs](../en/ansible.md)
- [README de la carpeta](../../ansible/README.md)

---

## 🐳 Docker + Kubernetes

**Carpeta:** [dockers-kubernetes/](../../dockers-kubernetes/)

Ruta de aprendizaje progresiva desde escribir tu primer `Dockerfile` hasta un despliegue en Kubernetes de nivel producción en Google Kubernetes Engine (GKE) con pipeline de CI/CD completo.

**Tecnologías clave:** Docker · Docker Compose · Kubernetes · GKE · Nginx · GitHub Actions  
**Temas:** Imágenes · Docker Compose · Apps multi-contenedor · Pods/Deployments/Services · Ingress · PVC · Secrets · Skaffold

📄 **Documentación:**
- [Documentación detallada en español](docker-kubernetes.md)
- [Detailed English docs](../en/docker-kubernetes.md)
- [README de la carpeta](../../dockers-kubernetes/README.md)

---

## ⚙️ GitHub Actions

**Carpeta:** [github-actions/](../../github-actions/)

Progresión paso a paso a través de GitHub Actions desde pipelines básicos hasta construir tus propias acciones personalizadas reutilizables (JavaScript, Docker, Composite y Reusable Workflows).

**Tecnologías clave:** GitHub Actions · Node.js · Docker · MongoDB  
**Temas:** Eventos y triggers · Artefactos y caché · Entornos y secretos · Contenedores de servicio · Acciones personalizadas

📄 **Documentación:**
- [Documentación detallada en español](github-actions.md)
- [Detailed English docs](../en/github-actions.md)
- [README de la carpeta](../../github-actions/README.md)

---

## 📊 Prometheus + Grafana

**Carpeta:** [prometheus-grafana/](../../prometheus-grafana/)

Configuración de un stack de observabilidad completo usando Docker Compose — métricas con Prometheus, dashboards con Grafana, agregación de logs con Loki + Promtail, trazabilidad distribuida con OpenTelemetry y alertas con Alert Manager.

**Tecnologías clave:** Prometheus · Grafana · Loki · Promtail · OpenTelemetry · Alert Manager · Docker Compose  
**Temas:** Scraping de métricas · Datos de series temporales · Agregación de logs · Trazabilidad distribuida · Reglas de alertas · Dashboards

📄 **Documentación:**
- [Documentación detallada en español](prometheus-grafana.md)
- [Detailed English docs](../en/prometheus-grafana.md)
- [README de la carpeta](../../prometheus-grafana/README.md)

---

## 🛠️ Prerrequisitos

Las siguientes herramientas se usan en los diferentes módulos:

| Herramienta | Usada en |
|-------------|----------|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Docker + K8s, Prometheus |
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | Ansible, Docker (infra CI/CD) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Módulos de Kubernetes |
| [WSL 2 / Ubuntu](https://learn.microsoft.com/en-us/windows/wsl/) | Nodo de control Ansible |
| [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) | Módulo Ansible (dentro de WSL) |
| [Node.js 20+](https://nodejs.org/) | Proyectos de aplicaciones GitHub Actions |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | Labs Ansible/Terraform con Azure |

---

## 📁 Estructura del Repositorio

```
udemy-courses/
├── README.md                    ← Página principal en inglés
├── docs/
│   ├── en/                      ← Documentación detallada en inglés
│   │   ├── ansible.md
│   │   ├── docker-kubernetes.md
│   │   ├── github-actions.md
│   │   └── prometheus-grafana.md
│   └── es/                      ← Aquí estás
│       ├── README.md
│       ├── ansible.md
│       ├── docker-kubernetes.md
│       ├── github-actions.md
│       └── prometheus-grafana.md
├── ansible/                     ← Labs de Ansible + Terraform
├── dockers-kubernetes/          ← Labs de Docker + Kubernetes
├── github-actions/              ← Labs de GitHub Actions
└── prometheus-grafana/          ← Labs del stack de monitoreo
```

---

> Cada carpeta de módulo contiene su propio README con instrucciones de configuración, estructura de carpetas y comandos de inicio rápido. Usa los enlaces de arriba para navegar.
