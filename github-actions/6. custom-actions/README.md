# Custom Actions Examples

Este proyecto contiene ejemplos de los 4 tipos principales de acciones personalizadas en GitHub Actions:

## 1. JavaScript Action
**Archivo**: `.github/workflows/javascript-action.yml`

Una acción que se ejecuta en Node.js. Es rápida y tiene acceso completo a las APIs de GitHub Actions.

**Características**:
- Usa Node.js 20
- Lee inputs y establece outputs
- Accede al contexto de GitHub

**Archivos relacionados**:
- `.github/actions/hello-world-js/action.yml` - Definición de la acción
- `.github/actions/hello-world-js/index.js` - Código JavaScript
- `.github/actions/hello-world-js/package.json` - Dependencias

## 2. Docker Action
**Archivo**: `.github/workflows/docker-action.yml`

Una acción que se ejecuta dentro de un contenedor Docker. Ideal cuando necesitas un entorno específico.

**Características**:
- Usa Alpine Linux como base
- Ejecuta un script bash
- Totalmente aislada en contenedor

**Archivos relacionados**:
- `.github/actions/hello-world-docker/action.yml` - Definición de la acción
- `.github/actions/hello-world-docker/Dockerfile` - Imagen Docker
- `.github/actions/hello-world-docker/entrypoint.sh` - Script de entrada

## 3. Composite Action
**Archivo**: `.github/workflows/composite-action.yml`

Una acción que combina múltiples steps en una sola acción reutilizable.

**Características**:
- Combina múltiples acciones existentes
- Setup de Node.js
- Instalación de paquetes
- Verificación de instalación

**Archivos relacionados**:
- `.github/actions/setup-and-test/action.yml` - Definición con steps combinados

## 4. Reusable Workflow
**Archivos**: 
- `.github/workflows/call-reusable-workflow.yml` (caller)
- `.github/workflows/reusable-workflow.yml` (reusable)

Un workflow completo que puede ser llamado desde otros workflows.

**Características**:
- Define inputs y outputs
- Maneja secrets
- Puede ser llamado desde múltiples workflows
- Simula un proceso de deployment

## Cómo usar

1. **JavaScript Action**: Requiere instalar dependencias primero
   ```bash
   cd .github/actions/hello-world-js
   npm install
   ```

2. **Docker Action**: Se construye automáticamente al ejecutar

3. **Composite Action**: No requiere setup adicional

4. **Reusable Workflow**: Se llama usando `workflow_call`

## Diferencias clave

| Tipo | Velocidad | Flexibilidad | Uso típico |
|------|-----------|--------------|------------|
| JavaScript | ⚡⚡⚡ | Alta | Automatización rápida |
| Docker | ⚡ | Muy Alta | Entornos específicos |
| Composite | ⚡⚡ | Media | Reutilizar steps |
| Reusable | ⚡⚡ | Alta | Reutilizar workflows |
