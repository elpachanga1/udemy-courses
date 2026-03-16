# 🎓 DevOps & Cloud Engineering — Udemy Courses

> **Language / Idioma:**
> 🇬🇧 **English** (current) | [🇪🇸 Español](docs/es/README.md)

A multi-topic repository collecting hands-on labs and exercises from several DevOps / Cloud Engineering courses on Udemy. Each folder is an **independent learning module** covering a different technology area.

---

## 📦 Projects Overview

| Module | Topics | Folder |
|--------|--------|--------|
| [🔧 Ansible + Terraform](#-ansible--terraform) | Infrastructure automation, configuration management, Azure VMs | [ansible/](ansible/) |
| [🐳 Docker + Kubernetes](#-docker--kubernetes) | Containerization, orchestration, CI/CD, GKE | [dockers-kubernetes/](dockers-kubernetes/) |
| [⚙️ GitHub Actions](#️-github-actions) | CI/CD pipelines, custom actions, secrets, service containers | [github-actions/](github-actions/) |
| [📊 Prometheus + Grafana](#-prometheus--grafana) | Monitoring, metrics, logs, alerting, OpenTelemetry | [prometheus-grafana/](prometheus-grafana/) |

---

## 🔧 Ansible + Terraform

**Folder:** [ansible/](ansible/)

Learn infrastructure as code with **Terraform** for cloud provisioning and **Ansible** for configuration management. Labs run against Azure Virtual Machines provisioned dynamically, using WSL Ubuntu as the control node.

**Key technologies:** Ansible · Terraform · Azure · WSL Ubuntu  
**Topics covered:** Playbooks · Roles · Handlers · Loops · Conditions · Tags · Variables · Ansible Vault · Dynamic Inventory

📄 **Documentation:**
- [Detailed English docs](docs/en/ansible.md)
- [Documentación en español](docs/es/ansible.md)
- [Folder README](ansible/README.md)

---

## 🐳 Docker + Kubernetes

**Folder:** [dockers-kubernetes/](dockers-kubernetes/)

Progressive learning path from writing your first `Dockerfile` all the way to a production-grade Kubernetes deployment on Google Kubernetes Engine (GKE) with a full CI/CD pipeline.

**Key technologies:** Docker · Docker Compose · Kubernetes · GKE · Nginx · GitHub Actions  
**Topics covered:** Images · Docker Compose · Multi-container apps · Pods/Deployments/Services · Ingress · PVC · Secrets · Skaffold

📄 **Documentation:**
- [Detailed English docs](docs/en/docker-kubernetes.md)
- [Documentación en español](docs/es/docker-kubernetes.md)
- [Folder README](dockers-kubernetes/README.md)

---

## ⚙️ GitHub Actions

**Folder:** [github-actions/](github-actions/)

Step-by-step progression through GitHub Actions from basic pipelines to building your own reusable custom actions (JavaScript, Docker, Composite, and Reusable Workflows).

**Key technologies:** GitHub Actions · Node.js · Docker · MongoDB  
**Topics covered:** Events & triggers · Artifacts & cache · Environments & secrets · Service containers · Custom actions

📄 **Documentation:**
- [Detailed English docs](docs/en/github-actions.md)
- [Documentación en español](docs/es/github-actions.md)
- [Folder README](github-actions/README.md)

---

## 📊 Prometheus + Grafana

**Folder:** [prometheus-grafana/](prometheus-grafana/)

Full observability stack setup using Docker Compose — metrics with Prometheus, dashboards with Grafana, log aggregation with Loki + Promtail, distributed tracing with OpenTelemetry, and alerting via Alert Manager.

**Key technologies:** Prometheus · Grafana · Loki · Promtail · OpenTelemetry · Alert Manager · Docker Compose  
**Topics covered:** Metrics scraping · Time-series data · Log aggregation · Distributed tracing · Alerting rules · Dashboards

📄 **Documentation:**
- [Detailed English docs](docs/en/prometheus-grafana.md)
- [Documentación en español](docs/es/prometheus-grafana.md)
- [Folder README](prometheus-grafana/README.md)

---

## 🛠️ Prerequisites

The following tools are used across different modules:

| Tool | Used in |
|------|---------|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Docker + K8s, Prometheus |
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | Ansible, Docker (CI/CD infra) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Kubernetes modules |
| [WSL 2 / Ubuntu](https://learn.microsoft.com/en-us/windows/wsl/) | Ansible control node |
| [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) | Ansible module (inside WSL) |
| [Node.js 20+](https://nodejs.org/) | GitHub Actions app projects |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | Ansible/Terraform Azure labs |

---

## 📁 Repository Structure

```
udemy-courses/
├── README.md                    ← You are here
├── docs/
│   ├── en/                      ← Detailed English documentation
│   │   ├── ansible.md
│   │   ├── docker-kubernetes.md
│   │   ├── github-actions.md
│   │   └── prometheus-grafana.md
│   └── es/                      ← Documentación detallada en español
│       ├── README.md
│       ├── ansible.md
│       ├── docker-kubernetes.md
│       ├── github-actions.md
│       └── prometheus-grafana.md
├── ansible/                     ← Ansible + Terraform labs
├── dockers-kubernetes/          ← Docker + Kubernetes labs
├── github-actions/              ← GitHub Actions labs
└── prometheus-grafana/          ← Monitoring stack labs
```

---

> Each module folder contains its own README with setup instructions, folder structure, and quick-start commands. See the links above to navigate.
