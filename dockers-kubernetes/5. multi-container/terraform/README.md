# Terraform - AWS Multi-Container Application

Este proyecto de Terraform automatiza completamente la configuración de AWS para la aplicación multi-container con React, Express, Redis y PostgreSQL.

## 🏗️ Arquitectura

La infraestructura crea:

- **Elastic Beanstalk**: Ambiente para multi-container Docker
- **RDS PostgreSQL**: Base de datos para almacenar valores de Fibonacci
- **ElastiCache Redis**: Cache para trabajo asíncrono
- **Security Groups**: Configuración de red segura
- **IAM Roles**: Permisos necesarios para los servicios

## 📋 Requisitos Previos

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado con credenciales
- Cuenta de AWS con permisos de administrador
- Imágenes Docker publicadas en Docker Hub:
  - `elpachanga1/multi-client`
  - `elpachanga1/multi-server`
  - `elpachanga1/multi-worker`
  - `elpachanga1/multi-nginx`

## 📁 Estructura del Proyecto

```
terraform/
├── main.tf                  # Configuración principal de recursos
├── variables.tf             # Variables del proyecto
├── outputs.tf              # Outputs del despliegue
├── terraform.tfvars.example # Ejemplo de variables personalizadas
├── Dockerrun.aws.json      # Configuración multi-container para EB
├── .gitignore              # Archivos a ignorar en git
└── README.md               # Este archivo
```

## 🚀 Uso

### 1. Configurar AWS CLI

```bash
aws configure
```

Proporciona:
- AWS Access Key ID
- AWS Secret Access Key
- Región por defecto (ej: us-east-1)
- Formato de salida (ej: json)

### 2. Crear archivo de variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores. **IMPORTANTE**: Cambia el `db_password` por uno seguro.

### 3. Inicializar Terraform

```bash
terraform init
```

### 4. Revisar el plan

```bash
terraform plan
```

### 5. Aplicar la infraestructura

```bash
terraform apply
```

Revisa los cambios y escribe `yes` para confirmar. Este proceso tomará aproximadamente **10-15 minutos**.

### 6. Ver los outputs

```bash
terraform output
```

Guarda estos valores, especialmente:
- `environment_url`: URL de tu aplicación
- `s3_bucket_name`: Para deployment con GitHub Actions

## 📦 Recursos Creados

### 1. Networking
- **Security Group** (`multi-docker`): Permite tráfico entre servicios (PostgreSQL y Redis)

### 2. Base de Datos
- **RDS PostgreSQL** (`multi-docker-postgres`):
  - Engine: PostgreSQL 16.3
  - Instance: `db.t3.micro` (Free Tier)
  - Database: `fibvalues`
  - Storage: 20 GB

### 3. Cache
- **ElastiCache Redis** (`multi-docker-redis`):
  - Node type: `cache.t3.micro`
  - Single node (sin réplicas)
  - Transit encryption: Deshabilitado

### 4. IAM
- **EC2 Role**: Para instancias de Elastic Beanstalk
- **Service Role**: Para el servicio de Elastic Beanstalk
- **Instance Profile**: Vincula roles a instancias EC2

### 5. Elastic Beanstalk
- **Application**: `multi-docker`
- **Environment**: `multi-docker-env`
  - Platform: Multi-container Docker
  - Instance: `t3.small` (recomendado para multi-container)
  - Type: Single Instance (Free Tier)
  - Variables de entorno configuradas automáticamente

## 🔧 Variables Configurables

| Variable | Descripción | Default |
|----------|-------------|---------|
| `aws_region` | Región de AWS | `us-east-1` |
| `app_name` | Nombre de la aplicación | `multi-docker` |
| `environment` | Nombre del ambiente | `production` |
| `solution_stack_name` | Stack de Elastic Beanstalk | `64bit Amazon Linux 2023 v4.8.0 running Docker` |
| `instance_type` | Tipo de instancia EC2 | `t3.small` |
| `environment_type` | Tipo de ambiente | `SingleInstance` |
| `db_username` | Usuario de PostgreSQL | `postgres` |
| `db_password` | Contraseña de PostgreSQL | `postgrespassword` ⚠️ |

⚠️ **IMPORTANTE**: Cambia el `db_password` en producción.

## 🔐 Variables de Entorno

Terraform configura automáticamente estas variables en Elastic Beanstalk:

- `REDIS_HOST`: Endpoint de Redis
- `REDIS_PORT`: 6379
- `PGUSER`: Usuario de PostgreSQL
- `PGPASSWORD`: Contraseña de PostgreSQL
- `PGHOST`: Endpoint de RDS
- `PGDATABASE`: fibvalues
- `PGPORT`: 5432

## 📤 Deployment

### Opción 1: Manual con AWS CLI

Después de crear la infraestructura:

```bash
# Comprimir Dockerrun.aws.json
zip deployment.zip Dockerrun.aws.json

# Subir a S3 (usa el bucket_name del output)
aws s3 cp deployment.zip s3://elasticbeanstalk-REGION-ACCOUNT_ID/docker-multi/

# Crear versión de aplicación
aws elasticbeanstalk create-application-version \
  --application-name multi-docker \
  --version-label v1 \
  --source-bundle S3Bucket="elasticbeanstalk-REGION-ACCOUNT_ID",S3Key="docker-multi/deployment.zip"

# Actualizar ambiente
aws elasticbeanstalk update-environment \
  --environment-name multi-docker-env \
  --version-label v1
```

### Opción 2: Con GitHub Actions

El workflow `.github/workflows/multi-container.yml` ya está configurado. Solo necesitas:

1. Agregar secrets en GitHub:
   - `AWS_ACCESS_KEY`
   - `AWS_SECRET_KEY`
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`

2. Hacer push a `main`:
```bash
git add .
git commit -m "Deploy multi-container app"
git push origin main
```

## 💰 Costos Estimados (Free Tier)

Con la configuración por defecto:

| Servicio | Costo Mensual |
|----------|---------------|
| EC2 (t3.small, SingleInstance) | ~$15 |
| RDS (db.t3.micro) | Free Tier (1 año) |
| ElastiCache (cache.t3.micro) | ~$12 |
| Data Transfer | Variable |
| **Total Estimado** | **~$27/mes** |

💡 **Tip**: Usa `terraform destroy` cuando no estés usando la app para evitar costos.

## 🧹 Limpieza

Para destruir toda la infraestructura:

```bash
terraform destroy
```

⚠️ **Advertencia**: Esto eliminará permanentemente:
- Base de datos PostgreSQL (sin snapshot final)
- Cache Redis
- Ambiente de Elastic Beanstalk
- Todos los recursos creados

## 🐛 Solución de Problemas

### Error: "InvalidParameterValue: No Solution Stack named..."

Lista los stacks disponibles y actualiza `solution_stack_name`:

```bash
aws elasticbeanstalk list-available-solution-stacks --region us-east-1 | grep Docker
```

### Ambiente en estado "Severe"

1. Ve a la consola de Elastic Beanstalk
2. Revisa los logs en "Logs" → "Request Logs"
3. Verifica que las imágenes Docker existan en Docker Hub
4. Confirma que el `Dockerrun.aws.json` sea válido

### Conexión fallida a RDS o Redis

1. Verifica que el Security Group `multi-docker` esté aplicado
2. Revisa las variables de entorno en Elastic Beanstalk
3. Confirma que los endpoints sean correctos:

```bash
terraform output rds_endpoint
terraform output redis_endpoint
```

### "Health" no cambia a verde

Espera 5-10 minutos. Si persiste:
1. Revisa que todas las imágenes Docker estén disponibles
2. Verifica los logs de la aplicación
3. Confirma que el health check path `/` responda correctamente

## 📚 Referencias

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Elastic Beanstalk - Multi-container Docker](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_v2config.html)
- [RDS PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [ElastiCache Redis](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/WhatIs.html)

## 📝 Notas Importantes

1. **El archivo `Dockerrun.aws.json`** define la configuración multi-container para Elastic Beanstalk
2. **Transit encryption en Redis** está deshabilitado para simplificar la conexión (según las instrucciones)
3. **Security Groups** permiten comunicación interna entre PostgreSQL (5432) y Redis (6379)
4. **Las contraseñas** están en variables de Terraform - úsalas con cuidado
5. **SingleInstance** es más barato pero no tiene alta disponibilidad

## 🎯 Próximos Pasos

Después de aplicar Terraform:

1. ✅ Verifica que el ambiente esté verde en AWS Console
2. ✅ Accede a la URL del output `environment_cname`
3. ✅ Prueba la funcionalidad (ingresar índices de Fibonacci)
4. ✅ Configura GitHub Actions para deployment automático
5. ✅ Considera usar Load Balancer para producción
