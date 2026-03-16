# ⚙️ GitHub Actions — Detailed Documentation

> **Language / Idioma:** 🇬🇧 **English** (current) | [🇪🇸 Español](../es/github-actions.md)
>
> ← [Back to main README](../../README.md) | [Folder README](../../github-actions/README.md)

---

## 📖 Overview

**GitHub Actions** is GitHub's built-in CI/CD platform. Workflows are YAML files stored in `.github/workflows/` that automatically run in response to GitHub events (push, PR, schedule, manual trigger, etc.).

```
Developer pushes code
        │
        ▼
  GitHub detects event
        │
        ▼
  GitHub Actions runner (Ubuntu/macOS/Windows VM)
  picks up the workflow
        │
        ▼
  Jobs run (in parallel or sequentially)
  Each job has steps → actions or shell commands
        │
        ▼
  Results shown in GitHub → Checks / Summary
```

---

## 🔑 Core Concepts

### Workflow Anatomy
```yaml
name: My Workflow          # display name in GitHub UI

on:                        # TRIGGER — when to run
  push:
    branches: [main]

jobs:                      # Groups of steps
  my-job:                  # job ID
    runs-on: ubuntu-latest # runner environment
    steps:
      - name: Checkout code
        uses: actions/checkout@v3   # use a pre-built action

      - name: Run tests
        run: npm test               # shell command
```

### Context Variables
```yaml
${{ github.sha }}          # commit SHA
${{ github.ref }}          # branch/tag ref
${{ github.actor }}        # user who triggered
${{ runner.os }}           # OS of runner
${{ secrets.NAME }}        # repository secret
${{ vars.NAME }}           # repository variable (non-secret)
${{ env.NAME }}            # environment variable
${{ needs.job-id.outputs.key }}  # output from another job
```

---

## 📚 Topic Walkthroughs

### Topic 1 — Basic Pipeline (github-pipeline-practice)

**Single-job workflow:**
```yaml
name: Deploy
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npm run build
```

**Multi-job with dependency:**
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps: [checkout, install, test]

  build:
    needs: test        # only runs if test passes
    runs-on: ubuntu-latest
    steps: [checkout, install, build]

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps: [deploy]
```

---

### Topic 2 — Events & Activity Types

**Event types and filters:**
```yaml
on:
  push:
    branches: [main, 'release/**']
    branches-ignore: ['feature/**']
    paths: ['src/**', 'package.json']
    paths-ignore: ['docs/**', '*.md']

  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [main]

  schedule:
    - cron: '0 9 * * 1'   # Every Monday at 9am UTC

  workflow_dispatch:       # Manual trigger from GitHub UI
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options: [staging, production]

  workflow_call:           # Called by another workflow (reusable)
```

**Key distinction:**
- `push.branches` — run when pushing TO these branches
- `pull_request.branches` — run when opening PR targeting these branches

---

### Topic 3 — Artifacts, Cache & Outputs

**Dependency caching (speeds up workflows significantly):**
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

**Upload and download artifacts (share files between jobs):**
```yaml
# In the build job
- uses: actions/upload-artifact@v4
  with:
    name: dist-files
    path: dist/
    retention-days: 5

# In the deploy job
- uses: actions/download-artifact@v4
  with:
    name: dist-files
```

**Job outputs (pass values between jobs):**
```yaml
jobs:
  build:
    outputs:
      js-filename: ${{ steps.get-filename.outputs.js-filename }}
    steps:
      - id: get-filename
        run: echo "js-filename=app.abc123.js" >> $GITHUB_OUTPUT

  deploy:
    needs: build
    steps:
      - run: echo "Deploying ${{ needs.build.outputs.js-filename }}"
```

---

### Topic 4 — Environment Variables & Secrets

**Variable scopes:**
```yaml
env:                        # ← workflow-level (all jobs see this)
  NODE_ENV: production

jobs:
  test:
    env:                    # ← job-level
      PORT: 8080
    environment: testing    # ← GitHub Environment (with protection rules)
    steps:
      - name: Run
        env:                # ← step-level (highest priority)
          DEBUG: true
        run: npm test
```

**Secrets vs Variables:**
| Feature | Secrets | Variables |
|---------|---------|-----------|
| Encrypted at rest | ✅ Yes | ❌ No |
| Hidden in logs | ✅ Yes | ❌ No |
| Access | `${{ secrets.NAME }}` | `${{ vars.NAME }}` |
| Use case | Passwords, tokens, keys | Non-sensitive config values |

**GitHub Environments** allow:
- Protection rules (require manual approval before deployment)
- Environment-specific secrets/variables
- Deployment tracking in GitHub

---

### Topic 5 — Service Containers

Run Docker containers alongside your job — useful for databases and other services needed for integration tests.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mongodb:
        image: mongo:6
        env:
          MONGO_INITDB_ROOT_USERNAME: root
          MONGO_INITDB_ROOT_PASSWORD: example
        ports:
          - 27017:27017
        options: >-
          --health-cmd "mongosh --eval 'db.runCommand(\"ping\").ok'"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm test
        env:
          MONGODB_URI: mongodb://root:example@localhost:27017
```

Service containers are accessible via `localhost:<mapped-port>` from job steps.

---

### Topic 6 — Custom Actions

#### JavaScript Action
Fast, Node.js-based. Has access to the full GitHub Actions toolkit.

```
.github/actions/my-js-action/
├── action.yml
├── index.js
└── package.json
```

```yaml
# action.yml
name: My JS Action
inputs:
  greeting:
    description: 'Name to greet'
    required: true
outputs:
  message:
    description: 'The greeting message'
runs:
  using: node20
  main: index.js
```

```js
// index.js
const core = require('@actions/core');
const greeting = core.getInput('greeting');
core.setOutput('message', `Hello, ${greeting}!`);
```

#### Docker Action
Runs inside a container. Full control over the environment.

```yaml
# action.yml
runs:
  using: docker
  image: Dockerfile
  args:
    - ${{ inputs.greeting }}
```

#### Composite Action
Reuse sequences of steps (can call other actions).

```yaml
# action.yml
runs:
  using: composite
  steps:
    - uses: actions/setup-node@v3
      with:
        node-version: '20'
    - run: npm ci
      shell: bash
    - run: npm test
      shell: bash
```

#### Reusable Workflow
An entire workflow that other workflows can call via `workflow_call`.

```yaml
# reusable-workflow.yml
on:
  workflow_call:
    inputs:
      environment:
        type: string
        required: true
    secrets:
      DEPLOY_KEY:
        required: true
```

```yaml
# caller workflow
jobs:
  call-deploy:
    uses: ./.github/workflows/reusable-workflow.yml
    with:
      environment: production
    secrets:
      DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

---

## 📋 Custom Actions Comparison

| Type | Speed | File count | Best for |
|------|-------|-----------|---------|
| JavaScript | ⚡⚡⚡ Fast | 3+ (`action.yml`, `index.js`, `package.json`) | GitHub API, fast automations |
| Docker | ⚡⚡ Medium | 3+ (`action.yml`, `Dockerfile`, `entrypoint.sh`) | Custom environment, bash scripts |
| Composite | ⚡⚡⚡ Fast | 1 (`action.yml`) | Grouping existing steps |
| Reusable Workflow | Variable | 1 (`.yml` workflow) | Full pipeline reuse across repos |

---

## 🔗 References

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [actions/checkout](https://github.com/actions/checkout)
- [actions/setup-node](https://github.com/actions/setup-node)
- [actions/cache](https://github.com/actions/cache)
- [actions/upload-artifact](https://github.com/actions/upload-artifact)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
