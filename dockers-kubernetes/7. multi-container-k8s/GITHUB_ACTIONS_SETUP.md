# Configuración de GitHub Actions para Kubernetes Multi-Container

## 📋 Resumen
Este proyecto ahora usa GitHub Actions en lugar de Travis CI para CI/CD. El workflow automáticamente:
1. Ejecuta tests en el cliente
2. Construye imágenes Docker
3. Las sube a Docker Hub
4. Despliega a Google Kubernetes Engine (GKE)

## 🔐 Configuración de Secrets

Para que el workflow funcione, necesitas configurar los siguientes secrets en tu repositorio de GitHub:

### Paso 1: Ir a Settings de tu repositorio
1. Ve a tu repositorio en GitHub
2. Click en `Settings`
3. En el menú lateral, click en `Secrets and variables` → `Actions`
4. Click en `New repository secret`

### Paso 2: Agregar los siguientes secrets

#### 1. GCP_SERVICE_ACCOUNT_KEY
**Importante:** Este es el contenido completo del archivo JSON de credenciales de GCP.

```
Nombre: GCP_SERVICE_ACCOUNT_KEY
Valor: [Copiar todo el contenido del archivo multik8s-480817-178af3bdc5fd.json]
```

Para copiar el valor:
- Abre el archivo `multik8s-480817-178af3bdc5fd.json`
- Copia **TODO** el contenido (desde `{` hasta `}`)
- Pégalo en el campo de valor del secret
- **IMPORTANTE**: Debe ser JSON válido en una sola línea o con saltos de línea preservados
- El JSON debe comenzar con `{` y terminar con `}`

#### 2. DOCKER_USERNAME
```
Nombre: DOCKER_USERNAME
Valor: elpachanga1
```

#### 3. DOCKER_PASSWORD
```
Nombre: DOCKER_PASSWORD
Valor: [Tu contraseña de Docker Hub]
```

**Nota de seguridad:** Considera usar un Docker Hub Access Token en lugar de tu contraseña:
- Ve a https://hub.docker.com/settings/security
- Click en "New Access Token"
- Dale un nombre descriptivo (ej: "github-actions")
- Copia el token generado
- Usa ese token como valor de DOCKER_PASSWORD

#### 4. PGPASSWORD
```
Nombre: PGPASSWORD
Valor: [Tu contraseña para PostgreSQL, ejemplo: mypassword123]
```

**Importante:** Esta es la contraseña que usará PostgreSQL en tu cluster de Kubernetes. Elige una contraseña segura.
- Ejemplo: `MySecurePassword123!`
- No uses caracteres especiales complicados que puedan causar problemas
- Esta contraseña será usada por tu aplicación para conectarse a la base de datos

## ⚠️ IMPORTANTE: Seguridad de credenciales

### ❌ NO HACER:
- **NO** subas el archivo `multik8s-480817-178af3bdc5fd.json` a GitHub
- **NO** subas el archivo `client-secret.json.enc` (ya no es necesario)
- **NO** compartas las credenciales en texto plano

### ✅ HACER:
1. **Elimina el archivo JSON del repositorio si ya fue subido:**
   ```bash
   git rm multik8s-480817-178af3bdc5fd.json
   git commit -m "Remove GCP credentials file"
   git push
   ```

2. **Agrega el archivo al .gitignore:**
   El archivo ya debe estar listado en `.gitignore`, pero verifica:
   ```
   multik8s-480817-178af3bdc5fd.json
   client-secret.json
   client-secret.json.enc
   *.json
   ```

3. **Guarda las credenciales de forma segura:**
   - Mantén una copia del JSON en un gestor de contraseñas (LastPass, 1Password, etc.)
   - O guárdalo en un almacenamiento seguro de tu organización

## 🚀 Cómo funciona el workflow

### Trigger
El workflow se ejecuta automáticamente cuando haces push a la rama `main`.

### Jobs

#### 1. Test
- Construye la imagen de desarrollo del cliente
- Ejecuta los tests con coverage

#### 2. Build and Deploy (solo si los tests pasan)
- Se autentica con GCP usando el service account
- Se autentica con Docker Hub
- Obtiene credenciales del cluster de Kubernetes
- Construye las 3 imágenes Docker (client, server, worker)
- Etiqueta cada imagen con `latest` y con el SHA del commit
- Sube todas las imágenes a Docker Hub
- Aplica las configuraciones de Kubernetes
- Actualiza los deployments con las nuevas imágenes

## 🔄 Diferencias con Travis CI

### Ventajas de GitHub Actions:
1. **No más archivos encriptados:** Los secrets se manejan de forma nativa en GitHub
2. **Mejor integración:** Está integrado directamente en GitHub
3. **Más rápido:** Generalmente más rápido en iniciar los workflows
4. **Gratuito:** Para repositorios públicos y 2000 minutos/mes para privados
5. **Mejor UI:** Interfaz más moderna y fácil de usar

### Cambios principales:
- ✅ Uso de GitHub Secrets en lugar de encriptación con OpenSSL
- ✅ Uso de acciones oficiales de Google Cloud
- ✅ Sintaxis YAML más moderna y legible
- ✅ Mejor manejo de credenciales

## 📝 Verificación

Una vez configurados los secrets:

1. Haz un commit y push a la rama `main`:
   ```bash
   git add .
   git commit -m "Add GitHub Actions workflow"
   git push origin main
   ```

2. Ve a la pestaña `Actions` en tu repositorio de GitHub

3. Verás el workflow ejecutándose

4. Si algo falla:
   - Click en el workflow fallido
   - Revisa los logs de cada step
   - Verifica que todos los secrets estén configurados correctamente

## 🆘 Troubleshooting

### Error: "bad decrypt" o "invalid key"
- Este error ya no debería ocurrir con GitHub Actions
- Las credenciales se manejan directamente como secrets

### Error: "You do not currently have an active account selected"
- **Causa:** El secret `GCP_SERVICE_ACCOUNT_KEY` no está configurado o es inválido
- **Solución:** 
  1. Verifica que el secret exista en Settings → Secrets and variables → Actions
  2. Asegúrate de que el JSON sea válido y esté completo
  3. El JSON debe comenzar con `{` y terminar con `}`
  4. No debe tener espacios extra al inicio o final

### Error: "gcloud: command not found"
- El workflow usa la action oficial `google-github-actions/setup-gcloud@v2`
- No requiere instalación manual

### Error: "unauthorized: authentication required" (Docker)
- Verifica que DOCKER_USERNAME y DOCKER_PASSWORD estén correctos
- Asegúrate de usar un Access Token de Docker Hub
- El username debe ser exactamente: `elpachanga1`

### Error: "cluster not found"
- Verifica que el nombre del cluster sea correcto: `multi-container-cluster`
- Verifica que la zona sea correcta: `us-central1`
- Verifica que el proyecto sea correcto: `multik8s-480817`

### Error: "Invalid credentials" o "Permission denied"
- Verifica que la service account tenga los permisos necesarios en GCP:
  - `Kubernetes Engine Developer`
  - `Storage Object Viewer`
  - `Service Account User`

## 🔧 Personalización

Si necesitas cambiar configuraciones, edita el archivo `.github/workflows/deploy.yml`:

- **Zona de GCP:** Cambia `GCP_ZONE` en la sección `env`
- **Nombre del cluster:** Cambia `GKE_CLUSTER` en la sección `env`
- **Usuario de Docker:** Cambia `DOCKER_USERNAME` en la sección `env`
- **Rama de deploy:** Cambia `branches: [main]` en la sección `on`

## 📚 Recursos adicionales

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Google Cloud GitHub Actions](https://github.com/google-github-actions/setup-gcloud)
- [Docker Login Action](https://github.com/docker/login-action)
