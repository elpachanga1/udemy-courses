# Laboratorio de Ansible en Azure

Este proyecto de Terraform crea un entorno de laboratorio para practicar Ansible en Azure con 3 máquinas virtuales Linux (Ubuntu 22.04).

## Máquinas Virtuales

- **control-node**: Nodo de control de Ansible
- **client-1**: Cliente administrado 1
- **client-2**: Cliente administrado 2

## Arquitectura

- Todas las VMs están en la misma Virtual Network (10.0.0.0/16)
- Todas las VMs están en la misma Subnet (10.0.1.0/24)
- Cada VM tiene una IP pública para acceso SSH
- Network Security Group configurado para permitir SSH y comunicación interna

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

### En el control-node:

1. Conectarse al control-node:
   ```bash
   ssh azureuser@<IP_PUBLICA_CONTROL_NODE>
   ```

2. Instalar Ansible:
   ```bash
   sudo apt update
   sudo apt install -y ansible
   ```

3. Crear un archivo de inventario de Ansible:
   ```bash
   mkdir ~/ansible
   cat > ~/ansible/inventory << EOF
   [managed_nodes]
   client-1 ansible_host=10.0.1.X
   client-2 ansible_host=10.0.1.Y
   
   [all:vars]
   ansible_user=azureuser
   ansible_ssh_pass=TuContraseña
   EOF
   ```

4. Probar la conexión:
   ```bash
   ansible all -i ~/ansible/inventory -m ping
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
