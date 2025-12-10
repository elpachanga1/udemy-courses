# Terraform GKE Cluster - Multi Container Application

Este proyecto de Terraform crea un cluster de Kubernetes en Google Kubernetes Engine (GKE) para desplegar la aplicación multi-container.

## Prerrequisitos

1. **Google Cloud SDK**: Instala y configura gcloud CLI
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Terraform**: Instala Terraform (versión >= 1.0)
   - Descarga desde: https://www.terraform.io/downloads

3. **APIs de GCP habilitadas**:
   ```bash
   gcloud services enable container.googleapis.com
   gcloud services enable compute.googleapis.com
   ```

4. **Credenciales de GCP**:
   ```bash
   gcloud auth application-default login
   ```

## Configuración

1. **Copia el archivo de ejemplo de variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edita `terraform.tfvars`** con tus valores:
   ```hcl
   project_id   = "tu-proyecto-gcp"
   region       = "us-central1"
   cluster_name = "multi-container-cluster"
   ```

## Uso

### Inicializar Terraform
```bash
terraform init
```

### Validar la configuración
```bash
terraform validate
```

### Ver el plan de ejecución
```bash
terraform plan
```

### Aplicar la configuración (crear el cluster)
```bash
terraform apply
```

### Configurar kubectl para usar el cluster
Después de crear el cluster, ejecuta el comando que se muestra en el output:
```bash
gcloud container clusters get-credentials multi-container-cluster --region us-central1 --project tu-proyecto-gcp
```

O usa el comando del output:
```bash
terraform output -raw kubectl_config_command | bash
```

### Verificar la conexión
```bash
kubectl get nodes
kubectl cluster-info
```

## Estructura del Proyecto

```
terraform/
├── main.tf                      # Configuración principal del cluster GKE
├── variables.tf                 # Definición de variables
├── outputs.tf                   # Outputs del cluster
├── terraform.tfvars.example     # Plantilla de variables
└── README.md                    # Este archivo
```

## Recursos Creados

El proyecto crea los siguientes recursos en GCP:

- **GKE Cluster**: Cluster de Kubernetes con configuración de alta disponibilidad
- **Node Pool**: Pool de nodos con autoscaling configurado
- **Workload Identity**: Habilitado para integración segura con servicios de GCP
- **Network Policy**: Configuración de políticas de red
- **Monitoring & Logging**: Integración con Google Cloud Monitoring y Logging

## Características del Cluster

- **Autoscaling**: Configurado para escalar entre 1 y 3 nodos por defecto
- **Auto-repair**: Los nodos se reparan automáticamente si fallan
- **Auto-upgrade**: Actualizaciones automáticas de Kubernetes
- **Workload Identity**: Autenticación segura con servicios de GCP
- **Shielded Nodes**: Seguridad mejorada en los nodos
- **Release Channel**: Actualizaciones controladas mediante canal REGULAR

## Variables Principales

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `project_id` | ID del proyecto GCP | (requerido) |
| `region` | Región de GCP | `us-central1` |
| `cluster_name` | Nombre del cluster | `multi-container-cluster` |
| `machine_type` | Tipo de máquina | `e2-medium` |
| `min_node_count` | Nodos mínimos | `1` |
| `max_node_count` | Nodos máximos | `3` |
| `preemptible` | Usar nodos preemptible | `false` |

## Costos

- **Cluster GKE**: ~$0.10/hora por el control plane
- **Nodos e2-medium**: ~$0.03/hora por nodo (varía según región)
- **Disco pd-standard**: ~$0.04/GB/mes

Para reducir costos en desarrollo:
- Usa `preemptible = true` (nodos pueden ser terminados en cualquier momento)
- Reduce `max_node_count`
- Usa máquinas más pequeñas como `e2-small`

## Despliegue de la Aplicación

Una vez creado el cluster, puedes desplegar la aplicación multi-container:

```bash
# Navega a la carpeta k8s
cd ../k8s

# Aplica todos los manifiestos
kubectl apply -f .

# Verifica los deployments
kubectl get deployments
kubectl get services
kubectl get ingress
```

## Limpieza

Para destruir todos los recursos creados:

```bash
terraform destroy
```

**⚠️ ADVERTENCIA**: Esto eliminará permanentemente el cluster y todos los datos asociados.

## Troubleshooting

### Error: "API not enabled"
```bash
gcloud services enable container.googleapis.com compute.googleapis.com
```

### Error: "Insufficient permissions"
Asegúrate de que tu cuenta tenga los roles necesarios:
- Kubernetes Engine Admin
- Compute Admin
- Service Account User

### Verificar estado del cluster
```bash
gcloud container clusters list
gcloud container clusters describe multi-container-cluster --region us-central1
```

### Ver logs
```bash
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

## Mejoras Futuras

- [ ] Implementar VPC personalizada con subredes
- [ ] Configurar Google Cloud Armor para protección DDoS
- [ ] Agregar Cloud NAT para nodos privados
- [ ] Implementar Pod Security Policies
- [ ] Configurar Backup automático con Velero
- [ ] Agregar monitoring con Prometheus/Grafana

## Referencias

- [Documentación de GKE](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)

## Soporte

Para problemas o preguntas, consulta:
- [GKE Troubleshooting](https://cloud.google.com/kubernetes-engine/docs/troubleshooting)
- [Terraform GCP Examples](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine)
