# Guía de Debugging - GitHub Actions

## 🔍 Verificación Rápida de Secrets

Para verificar que tus secrets están correctamente configurados, revisa lo siguiente:

### 1. Verificar que los Secrets existen
1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Debes ver estos 3 secrets:
   - ✅ `GCP_SERVICE_ACCOUNT_KEY`
   - ✅ `DOCKER_USERNAME`
   - ✅ `DOCKER_PASSWORD`

### 2. Verificar el formato del GCP_SERVICE_ACCOUNT_KEY

El JSON debe tener esta estructura:
```json
{
  "type": "service_account",
  "project_id": "multik8s-480817",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "fai-k8s-test@multik8s-480817.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "...",
  "universe_domain": "googleapis.com"
}
```

**Checklist:**
- [ ] El JSON es válido (puedes verificarlo en https://jsonlint.com/)
- [ ] Contiene todos los campos requeridos
- [ ] El `private_key` incluye `-----BEGIN PRIVATE KEY-----` y `-----END PRIVATE KEY-----`
- [ ] El `client_email` termina en `@multik8s-480817.iam.gserviceaccount.com`
- [ ] No tiene espacios extra al inicio o final

### 3. Verificar DOCKER_USERNAME y DOCKER_PASSWORD

```
DOCKER_USERNAME debe ser: elpachanga1
DOCKER_PASSWORD debe ser: tu contraseña o Access Token de Docker Hub
```

**Para crear un Access Token en Docker Hub:**
1. Ve a https://hub.docker.com/settings/security
2. Click en "New Access Token"
3. Nombre: `github-actions-kubernetes`
4. Permisos: Read, Write, Delete
5. Copia el token generado
6. Usa ese token como `DOCKER_PASSWORD`

## 🐛 Errores Comunes y Soluciones

### Error 1: "You do not currently have an active account selected"

**Mensaje completo:**
```
ERROR: (gcloud.container.clusters.get-credentials) You do not currently have an active account selected.
Please run:
  $ gcloud auth login
```

**Causa:** El secret `GCP_SERVICE_ACCOUNT_KEY` no está configurado correctamente.

**Solución:**
1. Verifica que el secret existe en GitHub
2. Elimina y vuelve a crear el secret con el JSON completo
3. **IMPORTANTE:** Al pegar el JSON, asegúrate de copiar desde el primer `{` hasta el último `}`
4. No agregues espacios, comillas extra, o cualquier otro carácter

**Cómo recrear el secret:**
```bash
# En tu máquina local, verifica que el JSON es válido:
cat multik8s-480817-178af3bdc5fd.json | jq .

# Si el comando anterior funciona, el JSON es válido
# Copia el contenido COMPLETO del archivo
```

### Error 2: "Invalid JSON in credentials"

**Causa:** El JSON tiene formato incorrecto.

**Solución:**
1. Copia el contenido de `multik8s-480817-178af3bdc5fd.json`
2. Pégalo en https://jsonlint.com/ para validar
3. Si hay errores, corrígelos
4. Copia el JSON validado y créalo como secret en GitHub

### Error 3: "Permission denied" o "403 Forbidden"

**Causa:** La service account no tiene los permisos necesarios.

**Solución en GCP Console:**
1. Ve a https://console.cloud.google.com/iam-admin/iam?project=multik8s-480817
2. Busca la service account: `fai-k8s-test@multik8s-480817.iam.gserviceaccount.com`
3. Click en el lápiz (editar)
4. Asegúrate de que tenga estos roles:
   - ✅ `Kubernetes Engine Developer`
   - ✅ `Storage Admin` o `Storage Object Viewer`
   - ✅ `Service Account User`
   - ✅ `Container Registry Service Agent`
5. Click en "Save"

### Error 4: "Error: cluster not found"

**Causa:** El cluster no existe o el nombre es incorrecto.

**Verificación:**
```bash
# En tu máquina local, lista los clusters disponibles:
gcloud container clusters list --project=multik8s-480817

# Debes ver algo como:
# NAME                       LOCATION      MASTER_VERSION  ...
# multi-container-cluster    us-central1   1.27.8-gke.1067 ...
```

**Si el cluster no existe:**
```bash
# Crear el cluster (ajusta según tus necesidades):
gcloud container clusters create multi-container-cluster \
  --zone us-central1 \
  --num-nodes 3 \
  --machine-type n1-standard-1 \
  --project multik8s-480817
```

### Error 5: "unauthorized: authentication required" (Docker Hub)

**Causa:** Credenciales de Docker Hub incorrectas.

**Solución:**
1. Verifica tu username en https://hub.docker.com/
2. Debe ser exactamente: `elpachanga1`
3. Si usas contraseña, intenta con un Access Token en su lugar
4. Actualiza los secrets en GitHub

### Error 6: "docker build failed" o "no such file or directory"

**Causa:** Las rutas de los Dockerfiles son incorrectas.

**Verificación:**
Los Dockerfiles deben estar en:
- `./app/client/Dockerfile`
- `./app/server/Dockerfile`
- `./app/worker/Dockerfile`

**Si están en otra ubicación, actualiza el workflow:**
```yaml
# Edita .github/workflows/deploy.yml y cambia las rutas:
docker build -t ... -f ./RUTA/CORRECTA/Dockerfile ./RUTA/CORRECTA/
```

## 🔧 Debugging Avanzado

### Ver logs detallados del workflow

1. Ve a Actions → Click en el workflow fallido
2. Click en el job que falló (ej: `build-and-deploy`)
3. Expande cada step para ver los logs detallados
4. Busca la línea exacta donde falló

### Agregar debug logging al workflow

Agrega esto antes del step que falla:

```yaml
- name: Debug - Print environment
  run: |
    echo "GCP_PROJECT_ID: ${{ env.GCP_PROJECT_ID }}"
    echo "GCP_ZONE: ${{ env.GCP_ZONE }}"
    echo "GKE_CLUSTER: ${{ env.GKE_CLUSTER }}"
    echo "DOCKER_USERNAME: ${{ env.DOCKER_USERNAME }}"
    echo "Current directory: $(pwd)"
    echo "List files: $(ls -la)"
    
- name: Debug - Verify gcloud auth
  run: |
    gcloud auth list
    gcloud config list
```

### Probar localmente con Docker

```bash
# Prueba construir las imágenes localmente:
cd app/client
docker build -t test-client -f Dockerfile .

cd ../server
docker build -t test-server -f Dockerfile .

cd ../worker
docker build -t test-worker -f Dockerfile .
```

## 📊 Checklist de Verificación Completa

Antes de hacer push, verifica:

### Repositorio Local
- [ ] El archivo `multik8s-480817-178af3bdc5fd.json` NO está en staging (`git status`)
- [ ] El archivo está en `.gitignore`
- [ ] Los Dockerfiles existen en `./app/client/`, `./app/server/`, `./app/worker/`
- [ ] El archivo `.github/workflows/deploy.yml` existe

### GitHub Secrets
- [ ] `GCP_SERVICE_ACCOUNT_KEY` está configurado
- [ ] `DOCKER_USERNAME` = `elpachanga1`
- [ ] `DOCKER_PASSWORD` está configurado (preferiblemente Access Token)

### GCP Console
- [ ] El proyecto `multik8s-480817` existe
- [ ] El cluster `multi-container-cluster` existe en `us-central1`
- [ ] La service account tiene los permisos necesarios
- [ ] La service account NO está deshabilitada

### Docker Hub
- [ ] Tu cuenta existe y está activa
- [ ] Tienes permisos para push a `elpachanga1/*`
- [ ] Si usas Access Token, está activo y tiene permisos correctos

## 🆘 Última Opción: Re-run Workflow

A veces, un simple re-run soluciona problemas temporales:

1. Ve a Actions → Click en el workflow fallido
2. Click en "Re-run all jobs" (arriba a la derecha)
3. Espera a que termine

## 📞 ¿Aún no funciona?

Si después de verificar todo lo anterior el workflow sigue fallando:

1. Copia el error COMPLETO del log
2. Verifica en la sección "Troubleshooting" de `GITHUB_ACTIONS_SETUP.md`
3. Busca el error en Google: "github actions gcloud [tu error]"
4. Revisa la documentación oficial:
   - https://github.com/google-github-actions/auth
   - https://github.com/google-github-actions/setup-gcloud

## 💡 Tip Pro

Crea un workflow de prueba simple para verificar la autenticación:

```yaml
name: Test GCP Auth
on: workflow_dispatch

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT_KEY }}
      
      - uses: google-github-actions/setup-gcloud@v2
      
      - name: Test gcloud
        run: |
          gcloud auth list
          gcloud config list
          gcloud projects list
```

Ejecuta este workflow manualmente desde Actions → Test GCP Auth → Run workflow
