# ⚙️ GitHub Actions — CI/CD Pipelines & Custom Actions

> **Language / Idioma:** 🇬🇧 **English** (current) | [🇪🇸 Español](../docs/es/github-actions.md)
>
> ← [Back to main README](../README.md) · [Detailed EN docs](../docs/en/github-actions.md) · [Docs ES](../docs/es/github-actions.md)

A step-by-step course through **GitHub Actions** covering every major feature: from your first pipeline to building fully custom reusable actions and workflows.

---

## 🎯 What You'll Learn

- Build multi-job CI/CD pipelines with lint, test, and build stages
- Trigger workflows on different GitHub events with precise filters
- Cache dependencies and manage artifacts between jobs
- Securely handle environment variables and secrets with GitHub Environments
- Run sidecar service containers (e.g., MongoDB) for integration tests
- Create all 4 types of custom GitHub Actions (JS, Docker, Composite, Reusable)

---

## 📁 Projects Overview

| # | Folder | Topics |
|---|--------|--------|
| 1 | [1. github-pipeline-practice/](1.%20github-pipeline-practice/) | Basic pipeline: lint, test, build in single & multi-job |
| 2 | [2. events-and-activity-types/](2.%20events-and-activity-types/) | Event triggers, activity types, branch/path filters |
| 3 | [3. artifacts-cache-outputs/](3.%20artifacts-cache-outputs/) | Dependency caching, artifact upload/download, job outputs |
| 4 | [4. env-vars-and-secrets/](4.%20env-vars-and-secrets/) | Env vars at all scopes, GitHub Secrets, GitHub Environments |
| 5 | [5. service-containers/](5.%20service-containers/) | Sidecar service containers, MongoDB integration testing |
| 6 | [6. custom-actions/](6.%20custom-actions/) | JavaScript, Docker, Composite actions + Reusable Workflows |

---

## 🔬 Project Details

### 1. GitHub Pipeline Practice
**Learning:** GitHub Actions syntax fundamentals. Create workflows with one or multiple jobs. Each job runs lint → test → build steps.

Key files: `.github/workflows/deployment-1-job.yaml`, `deployment-multi-job.yaml`

```yaml
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npm run build
```

### 2. Events & Activity Types
**Learning:** Control exactly when workflows run. Trigger on `push`, `pull_request`, `workflow_dispatch`, with activity type filters and branch/path restrictions.

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
  push:
    branches: [main, 'feature/**']
    paths-ignore: ['docs/**', '*.md']
  workflow_dispatch:
```

### 3. Artifacts, Cache & Outputs
**Learning:** Share data between jobs. Cache `~/.npm` to speed up installs. Upload build artifacts. Pass outputs from one job to another.

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

- uses: actions/upload-artifact@v4
  with:
    name: dist-files
    path: dist/
```

### 4. Env Vars & Secrets
**Learning:** Scoped environment variables (step, job, workflow level). GitHub Secrets for passwords. GitHub Environments (`testing`, `production`) with protection rules.

```yaml
env:
  MONGODB_USERNAME: ${{ vars.MONGODB_USERNAME }}
  MONGODB_PASSWORD: ${{ secrets.MONGODB_PASSWORD }}
jobs:
  test:
    environment: testing   # uses environment-scoped secrets
```

### 5. Service Containers
**Learning:** Spin up Docker containers as sidecars alongside your job steps. Run a real MongoDB instance for integration tests.

```yaml
jobs:
  test:
    services:
      mongodb:
        image: mongo
        env:
          MONGO_INITDB_ROOT_USERNAME: root
          MONGO_INITDB_ROOT_PASSWORD: example
        ports:
          - 27017:27017
```

### 6. Custom Actions
**Learning:** Build 4 types of reusable GitHub Actions.

| Type | Description | Speed | When to use |
|------|-------------|-------|-------------|
| **JavaScript** | Runs in Node.js, direct access to Actions API | ⚡⚡⚡ Fast | Quick automations, GitHub API calls |
| **Docker** | Runs in a container, full environment control | ⚡⚡ Medium | Custom environments, shell scripts |
| **Composite** | Chains multiple existing actions/steps | ⚡⚡⚡ Fast | Reusing common step sequences |
| **Reusable Workflow** | Entire workflow callable from other workflows | Variable | Full pipeline reuse across repos |

---

## ⚡ Key Concepts

| Concept | YAML Key | Example |
|---------|----------|---------|
| Trigger event | `on:` | `on: push` |
| Job runner | `runs-on:` | `runs-on: ubuntu-latest` |
| Reuse action | `uses:` | `uses: actions/checkout@v3` |
| Run command | `run:` | `run: npm test` |
| Env at job level | `env:` under job | `PORT: 8080` |
| Access secret | `${{ secrets.NAME }}` | `${{ secrets.API_KEY }}` |
| Access variable | `${{ vars.NAME }}` | `${{ vars.DB_HOST }}` |
| Job dependency | `needs:` | `needs: test` |
| Job output | `outputs:` | Pass values between jobs |
| Conditional | `if:` | `if: github.ref == 'refs/heads/main'` |

---

## 📄 More Documentation

- [Detailed English docs](../docs/en/github-actions.md)
- [Documentación detallada en español](../docs/es/github-actions.md)
- [Custom Actions README](6.%20custom-actions/README.md)
- [GitHub Actions official docs](https://docs.github.com/en/actions)
