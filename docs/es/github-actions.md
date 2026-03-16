# ⚙️ GitHub Actions — Documentación Detallada

> **Idioma / Language:** 🇪🇸 **Español** (actual) | [🇬🇧 English](../en/github-actions.md)
>
> ← [Volver al README principal](../../README.md) | [README de la carpeta](../../github-actions/README.md)

---

## 📖 Descripción General

**GitHub Actions** es la plataforma de CI/CD integrada de GitHub. Los workflows son archivos YAML almacenados en `.github/workflows/` que se ejecutan automáticamente en respuesta a eventos de GitHub (push, PR, programado, trigger manual, etc.).

```
El desarrollador sube código
        │
        ▼
  GitHub detecta el evento
        │
        ▼
  Un runner de GitHub Actions (VM Ubuntu/macOS/Windows)
  toma el workflow
        │
        ▼
  Se ejecutan los jobs (en paralelo o secuencialmente)
  Cada job tiene steps → actions o comandos de shell
        │
        ▼
  Resultados visibles en GitHub → Checks / Summary
```

---

## 🔑 Conceptos Fundamentales

### Anatomía de un Workflow
```yaml
name: Mi Workflow          # nombre que se ve en la UI de GitHub

on:                        # TRIGGER — cuándo ejecutar
  push:
    branches: [main]

jobs:                      # Grupos de pasos
  mi-job:                  # ID del job
    runs-on: ubuntu-latest # entorno del runner
    steps:
      - name: Checkout del código
        uses: actions/checkout@v3   # usar una acción pre-construida

      - name: Ejecutar tests
        run: npm test               # comando de shell
```

### Variables de Contexto
```yaml
${{ github.sha }}          # SHA del commit
${{ github.ref }}          # rama/tag de referencia
${{ github.actor }}        # usuario que disparó el evento
${{ runner.os }}           # sistema operativo del runner
${{ secrets.NOMBRE }}      # secreto del repositorio
${{ vars.NOMBRE }}         # variable del repositorio (no secreta)
${{ env.NOMBRE }}          # variable de entorno
${{ needs.id-job.outputs.clave }}  # output de otro job
```

---

## 📚 Descripción por Tema

### Tema 1 — Pipeline Básico (github-pipeline-practice)

**Workflow de un solo job:**
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

**Multi-job con dependencia:**
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps: [checkout, instalar, test]

  build:
    needs: test        # solo se ejecuta si test pasa
    runs-on: ubuntu-latest
    steps: [checkout, instalar, build]

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps: [deploy]
```

---

### Tema 2 — Eventos y Tipos de Actividad

**Tipos de eventos y filtros:**
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
    - cron: '0 9 * * 1'   # Cada lunes a las 9am UTC

  workflow_dispatch:       # Trigger manual desde la UI de GitHub
    inputs:
      environment:
        description: 'Entorno destino'
        required: true
        type: choice
        options: [staging, production]

  workflow_call:           # Llamado por otro workflow (reutilizable)
```

**Distinción clave:**
- `push.branches` — ejecutar al hacer push A estas ramas
- `pull_request.branches` — ejecutar al abrir PR que apunta a estas ramas

---

### Tema 3 — Artefactos, Caché y Outputs

**Caché de dependencias (acelera significativamente los workflows):**
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

**Subir y descargar artefactos (compartir archivos entre jobs):**
```yaml
# En el job de build
- uses: actions/upload-artifact@v4
  with:
    name: archivos-dist
    path: dist/
    retention-days: 5

# En el job de deploy
- uses: actions/download-artifact@v4
  with:
    name: archivos-dist
```

**Outputs entre jobs (pasar valores de un job a otro):**
```yaml
jobs:
  build:
    outputs:
      js-filename: ${{ steps.obtener-nombre.outputs.js-filename }}
    steps:
      - id: obtener-nombre
        run: echo "js-filename=app.abc123.js" >> $GITHUB_OUTPUT

  deploy:
    needs: build
    steps:
      - run: echo "Desplegando ${{ needs.build.outputs.js-filename }}"
```

---

### Tema 4 — Variables de Entorno y Secretos

**Ámbitos de variables:**
```yaml
env:                        # ← nivel workflow (todos los jobs lo ven)
  NODE_ENV: production

jobs:
  test:
    env:                    # ← nivel job
      PORT: 8080
    environment: testing    # ← GitHub Environment (con reglas de protección)
    steps:
      - name: Ejecutar
        env:                # ← nivel step (mayor prioridad)
          DEBUG: true
        run: npm test
```

**Secretos vs Variables:**
| Característica | Secretos | Variables |
|----------------|----------|-----------|
| Cifrados en reposo | ✅ Sí | ❌ No |
| Ocultos en logs | ✅ Sí | ❌ No |
| Acceso | `${{ secrets.NOMBRE }}` | `${{ vars.NOMBRE }}` |
| Caso de uso | Contraseñas, tokens, claves | Valores de configuración no sensibles |

**GitHub Environments** permiten:
- Reglas de protección (requieren aprobación manual antes del deploy)
- Secretos/variables específicos por entorno
- Seguimiento de despliegues en GitHub

---

### Tema 5 — Contenedores de Servicio

Ejecutar contenedores Docker junto a tu job — útil para bases de datos y otros servicios necesarios para tests de integración.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mongodb:
        image: mongo:6
        env:
          MONGO_INITDB_ROOT_USERNAME: root
          MONGO_INITDB_ROOT_PASSWORD: ejemplo
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
          MONGODB_URI: mongodb://root:ejemplo@localhost:27017
```

Los contenedores de servicio son accesibles via `localhost:<puerto-mapeado>` desde los steps del job.

---

### Tema 6 — Acciones Personalizadas

#### Acción JavaScript
Rápida, basada en Node.js. Acceso completo al toolkit de GitHub Actions.

```
.github/actions/mi-js-action/
├── action.yml
├── index.js
└── package.json
```

```yaml
# action.yml
name: Mi Acción JS
inputs:
  saludo:
    description: 'Nombre a saludar'
    required: true
outputs:
  mensaje:
    description: 'El mensaje de saludo'
runs:
  using: node20
  main: index.js
```

```js
// index.js
const core = require('@actions/core');
const saludo = core.getInput('saludo');
core.setOutput('mensaje', `¡Hola, ${saludo}!`);
```

#### Acción Docker
Se ejecuta dentro de un contenedor. Control total sobre el entorno.

```yaml
# action.yml
runs:
  using: docker
  image: Dockerfile
  args:
    - ${{ inputs.saludo }}
```

#### Acción Composite
Reutiliza secuencias de steps (puede llamar a otras acciones).

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

#### Workflow Reutilizable
Un workflow completo que otros workflows pueden llamar mediante `workflow_call`.

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
# workflow que llama al reutilizable
jobs:
  llamar-deploy:
    uses: ./.github/workflows/reusable-workflow.yml
    with:
      environment: production
    secrets:
      DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

---

## 📋 Comparación de Tipos de Acciones Personalizadas

| Tipo | Velocidad | N° de archivos | Mejor para |
|------|-----------|---------------|------------|
| JavaScript | ⚡⚡⚡ Rápida | 3+ (`action.yml`, `index.js`, `package.json`) | API de GitHub, automatizaciones rápidas |
| Docker | ⚡⚡ Media | 3+ (`action.yml`, `Dockerfile`, `entrypoint.sh`) | Entorno personalizado, scripts bash |
| Composite | ⚡⚡⚡ Rápida | 1 (`action.yml`) | Agrupar steps existentes |
| Workflow Reutilizable | Variable | 1 (workflow `.yml`) | Reutilización de pipelines completos entre repos |

---

## 🔗 Referencias

- [Documentación de GitHub Actions](https://docs.github.com/es/actions)
- [actions/checkout](https://github.com/actions/checkout)
- [actions/setup-node](https://github.com/actions/setup-node)
- [actions/cache](https://github.com/actions/cache)
- [actions/upload-artifact](https://github.com/actions/upload-artifact)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
