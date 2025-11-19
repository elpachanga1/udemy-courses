# Terraform - AWS Elastic Beanstalk para Docker React App

Este proyecto de Terraform despliega la aplicación React Dockerizada en AWS Elastic Beanstalk.

## Requisitos Previos

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado con credenciales
- Cuenta de AWS con permisos para crear recursos de Elastic Beanstalk, IAM, EC2, etc.

## Estructura del Proyecto

```
terraform/
├── main.tf                  # Configuración principal de recursos
├── variables.tf             # Variables del proyecto
├── outputs.tf              # Outputs del despliegue
├── terraform.tfvars.example # Ejemplo de variables personalizadas
├── .gitignore              # Archivos a ignorar en git
└── README.md               # Este archivo
```

## Configuración

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

Copia el archivo de ejemplo y personalízalo:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores preferidos.

## Uso

### Inicializar Terraform

```bash
terraform init
```

### Planificar el despliegue

```bash
terraform plan
```

### Aplicar la infraestructura

```bash
terraform apply
```

Revisa los cambios y escribe `yes` para confirmar.

### Ver outputs

```bash
terraform output
```

### Destruir la infraestructura

```bash
terraform destroy
```

## Recursos Creados

1. **IAM Roles y Policies**
   - Role para instancias EC2 de Elastic Beanstalk
   - Role para el servicio de Elastic Beanstalk
   - Instance Profile para EC2

2. **Elastic Beanstalk Application**
   - Aplicación contenedora para ambientes

3. **Elastic Beanstalk Environment**
   - Ambiente con Docker
   - Auto Scaling Group (1-4 instancias)
   - Load Balancer
   - CloudWatch Logs habilitados
   - Health Reporting mejorado

## Variables Configurables

| Variable | Descripción | Default |
|----------|-------------|---------|
| `aws_region` | Región de AWS | `us-east-1` |
| `app_name` | Nombre de la aplicación | `docker-react-app` |
| `environment` | Nombre del ambiente | `production` |
| `solution_stack_name` | Stack de Elastic Beanstalk | `64bit Amazon Linux 2023 v4.3.3 running Docker` |
| `instance_type` | Tipo de instancia EC2 | `t3.micro` |
| `min_instance_count` | Mínimo de instancias | `1` |
| `max_instance_count` | Máximo de instancias | `4` |
| `environment_type` | Tipo de ambiente | `LoadBalanced` |

## Despliegue de la Aplicación

Después de crear la infraestructura, puedes desplegar tu aplicación Docker:

1. Construye tu imagen Docker
2. Sube la imagen a Docker Hub o ECR
3. Crea un archivo `Dockerrun.aws.json` para Elastic Beanstalk
4. Despliega usando AWS CLI o la consola de Elastic Beanstalk

### Ejemplo de Dockerrun.aws.json

```json
{
  "AWSEBDockerrunVersion": "1",
  "Image": {
    "Name": "elpachanga1/docker-react",
    "Update": "true"
  },
  "Ports": [
    {
      "ContainerPort": 80,
      "HostPort": 80
    }
  ]
}
```

## Costos Estimados

Con la configuración por defecto (t3.micro con Load Balancer):
- **EC2 Instances**: ~$7-10/mes por instancia
- **Load Balancer**: ~$16/mes
- **Data Transfer**: Variable según tráfico
- **CloudWatch Logs**: Mínimo

**Estimado mensual**: $25-50 USD (con 1-2 instancias activas)

## Solución de Problemas

### Error: "InvalidParameterValue: No Solution Stack named..."

Actualiza el valor de `solution_stack_name` en tu `terraform.tfvars`. Lista los stacks disponibles:

```bash
aws elasticbeanstalk list-available-solution-stacks --region us-east-1 | grep Docker
```

### Permisos insuficientes

Asegúrate de que tu usuario IAM tenga las políticas:
- `AWSElasticBeanstalkFullAccess`
- `IAMFullAccess` (o permisos específicos para crear roles)

## Referencias

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [Docker on Elastic Beanstalk](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.html)
