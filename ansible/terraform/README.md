# Laboratorio de Ansible en Azure

Este proyecto de Terraform crea un entorno de laboratorio para practicar Ansible en Azure con 2 máquinas virtuales Linux (Ubuntu 22.04). El control node de Ansible se ejecuta desde tu WSL local.

## Arquitectura

- **Control Node**: Tu WSL Ubuntu local (sin costo)
- **client-1**: VM en Azure (cliente administrado 1)
- **client-2**: VM en Azure (cliente administrado 2)

## Infraestructura en Azure

- 2 VMs Ubuntu 22.04 LTS en Azure
- Todas las VMs están en la misma Virtual Network (10.0.0.0/16)
- Todas las VMs están en la misma Subnet (10.0.1.0/24)
- Cada VM tiene una IP pública para acceso SSH desde tu WSL
- Network Security Group configurado para permitir SSH desde Internet
- El control node de Ansible corre en tu WSL local (sin necesidad de VM adicional)

## Requisitos Previos

1. [Terraform](https://www.terraform.io/downloads) instalado (versión >= 1.0)
2. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) instalado
3. Una suscripción activa de Azure

## Configuración

1. Autenticarse en Azure:
   ```bash
   az login
   ```

2. Copiar el archivo de variables de ejemplo:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Editar `terraform.tfvars` y configurar tus valores, especialmente la contraseña:
   ```hcl
   admin_username = "azureuser"
   admin_password = "TuContraseñaSegura123!"
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

### Revisar el plan de ejecución
```bash
terraform plan
```

### Aplicar la configuración
```bash
terraform apply
```

### Conectarse a las VMs
Después de aplicar la configuración, Terraform mostrará los comandos SSH:
```bash
terraform output ssh_commands
```

### Destruir los recursos
```bash
terraform destroy
```

## Outputs

El proyecto proporciona varios outputs útiles:
- IPs públicas de cada VM
- IPs privadas de cada VM
- Comandos SSH para conectarse

Para ver los outputs:
```bash
terraform output
```

## Configuración Post-Despliegue para Ansible

### En tu WSL (Control Node Local):

1. Instalar Ansible en WSL:
   ```bash
   sudo apt update
   sudo apt install -y ansible sshpass
   ```

2. Obtener las IPs públicas de las VMs:
   ```bash
   terraform output
   ```

3. Crear un directorio para tu proyecto Ansible:
   ```bash
   mkdir -p ~/ansible-lab
   cd ~/ansible-lab
   ```

4. Crear un archivo de inventario de Ansible:
   ```bash
   cat > inventory.ini << EOF
   [azure_vms]
   client-1 ansible_host=<IP_PUBLICA_CLIENT_1>
   client-2 ansible_host=<IP_PUBLICA_CLIENT_2>
   
   [azure_vms:vars]
   ansible_user=azureuser
   ansible_ssh_pass=TuContraseña
   ansible_ssh_common_args='-o StrictHostKeyChecking=no'
   EOF
   ```

5. Probar la conexión desde tu WSL:
   ```bash
   ansible all -i inventory.ini -m ping
   ```

6. Ejecutar un comando ad-hoc de prueba:
   ```bash
   ansible all -i inventory.ini -m shell -a "hostname"
   ```

## Notas de Seguridad

⚠️ **IMPORTANTE**: Este laboratorio usa autenticación por contraseña para simplificar. En producción:
- Usa SSH keys en lugar de contraseñas
- Restringe el acceso SSH a IPs específicas
- Usa Azure Bastion o VPN para acceso remoto
- No expongas las VMs directamente a Internet

## Costos

Las VMs usan el tamaño `Standard_B2s` que es económico para laboratorios. Recuerda destruir los recursos cuando no los uses para evitar cargos innecesarios:

```bash
terraform destroy
```

## Personalización

Puedes ajustar los siguientes parámetros en `variables.tf` o `terraform.tfvars`:
- `location`: Región de Azure
- `vm_size`: Tamaño de las VMs
- `vm_names`: Nombres de las VMs
- `vnet_address_space`: Espacio de direcciones de la red virtual
- `subnet_address_prefix`: Prefijo de la subnet
