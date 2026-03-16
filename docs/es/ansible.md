# 🔧 Ansible + Terraform — Documentación Detallada

> **Idioma / Language:** 🇪🇸 **Español** (actual) | [🇬🇧 English](../en/ansible.md)
>
> ← [Volver al README principal](../../README.md) | [README de la carpeta](../../ansible/README.md)

---

## 📖 Descripción General

Este módulo enseña automatización de infraestructura usando **dos herramientas complementarias**:

| Herramienta | Rol | Qué hace |
|-------------|-----|----------|
| **Terraform** | Aprovisionamiento de infraestructura | Crea VMs de Azure, redes, grupos de seguridad |
| **Ansible** | Gestión de configuraciones | Instala software, gestiona archivos, ejecuta tareas en esas VMs |

El flujo es: **Terraform aprovisiona → Ansible configura**.

---

## 🏗️ Arquitectura

```
WSL Ubuntu (Nodo de Control)
    │
    │  SSH (puerto 22)
    ▼
Azure Cloud
  └── Grupo de Recursos: rg-ansible-lab
        └── Red Virtual: 10.0.0.0/16
              └── Subred: 10.0.1.0/24
                    ├── client-1 (Ubuntu 22.04, IP pública)
                    └── client-2 (Ubuntu 22.04, IP pública)

Flujo:
  1. terraform apply  →  aprovisiona VMs + escribe app/inventory.ini
  2. ansible-playbook →  se conecta por SSH a las VMs y ejecuta tareas
```

---

## 🚀 Inicio Rápido

### Prerrequisitos

```bash
# Instalar en WSL Ubuntu
sudo apt update
sudo apt install -y ansible python3-pip
pip3 install ansible-lint

# Instalar Terraform
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Instalar Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
```

### Paso 1 — Clave SSH
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_ansible_key
# Copiar la clave pública para terraform.tfvars
cat ~/.ssh/azure_ansible_key.pub
```

### Paso 2 — Configurar Terraform
```bash
cd /mnt/c/Users/<usuario>/Documents/GitHub/udemy-courses/ansible/terraform
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars:
#   admin_username = "azureuser"
#   ssh_public_key = "ssh-rsa AAAA..."
```

### Paso 3 — Aprovisionar Infraestructura
```bash
terraform init
terraform plan
terraform apply   # Crea las VMs + genera app/inventory.ini
```

### Paso 4 — Verificar y Ejecutar Playbooks
```bash
cd ../app
ansible all -m ping                                    # Verificar conectividad
ansible-playbook playbooks/remote/check-remote-clients.yml
```

---

## 📚 Conceptos de Ansible Cubiertos

### Estructura de un Playbook
```yaml
---
- name: Mi Playbook
  hosts: all          # objetivos del inventario
  become: true        # sudo
  vars:
    mi_variable: "valor"
  tasks:
    - name: Instalar nginx
      ansible.builtin.apt:
        name: nginx
        state: present
      notify: Reiniciar nginx   # activa el handler
  handlers:
    - name: Reiniciar nginx
      ansible.builtin.service:
        name: nginx
        state: restarted
```

### Temas por Carpeta

#### Condiciones (`with-conditions/`)
```yaml
- name: Instalar solo en Debian
  apt:
    name: nginx
    state: present
  when: ansible_os_family == "Debian"
```

#### Loops (`with-loops/`)
```yaml
- name: Instalar múltiples paquetes
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - git
    - curl
```

#### Handlers (`with-handlers/`)
Los handlers solo se ejecutan **si la tarea que los notifica realiza algún cambio** (idempotencia).
```yaml
tasks:
  - name: Copiar configuración de nginx
    copy:
      src: nginx.conf
      dest: /etc/nginx/nginx.conf
    notify: Recargar nginx

handlers:
  - name: Recargar nginx
    service:
      name: nginx
      state: reloaded
```

#### Roles (`with-roles/`)
Los roles organizan los playbooks en una estructura estándar de carpetas:
```
roles/
└── webserver/
    ├── tasks/main.yml       ← lista principal de tareas
    ├── handlers/main.yml    ← handlers
    ├── defaults/main.yml    ← variables por defecto
    ├── files/               ← archivos estáticos a copiar
    ├── templates/           ← plantillas Jinja2
    └── vars/main.yml        ← variables del rol
```

#### Tags (`with-tags/`)
```yaml
tasks:
  - name: Instalar paquetes
    apt:
      name: nginx
    tags: [instalar, paquetes]

  - name: Iniciar servicio
    service:
      name: nginx
      state: started
    tags: [servicio, inicio]
```
```bash
# Ejecutar solo tareas de instalación
ansible-playbook site.yml --tags "instalar"
# Omitir tareas de servicio
ansible-playbook site.yml --skip-tags "servicio"
```

#### Variables (`with-variables/`)
Precedencia de variables (menor → mayor prioridad):
1. `defaults/main.yml` (defaults del rol)
2. `group_vars/all`
3. `group_vars/<grupo>`
4. `host_vars/<host>`
5. `vars:` en el playbook
6. `--extra-vars` (línea de comandos) ← máxima prioridad

#### Ansible Vault (`with-vault/`)
Permite **cifrar secretos** (contraseñas, tokens, claves) en los playbooks.
```bash
# Crear archivo cifrado nuevo
ansible-vault create secretos.yml

# Cifrar archivo existente
ansible-vault encrypt vars.yml

# Editar archivo cifrado
ansible-vault edit secretos.yml

# Ver contenido sin editar
ansible-vault view secretos.yml

# Ejecutar playbook con contraseña de vault
ansible-playbook site.yml --ask-vault-pass
# O usar un archivo con la contraseña
ansible-playbook site.yml --vault-password-file .vault_pass
```

---

## 🔑 Referencia de Comandos

```bash
# Inventario y conectividad
ansible-inventory --list                          # Listar todos los hosts
ansible all -i inventory.ini -m ping             # Ping a todos
ansible all -m setup                             # Recopilar facts del sistema

# Ejecución de playbooks
ansible-playbook playbook.yml                    # Ejecutar playbook
ansible-playbook playbook.yml --check            # Simulacro (sin cambios)
ansible-playbook playbook.yml --syntax-check     # Validar YAML
ansible-playbook playbook.yml -v / -vv / -vvv   # Niveles de verbosidad
ansible-playbook playbook.yml --limit client-1   # Solo en un host
ansible-playbook playbook.yml --tags "instalar"  # Solo tareas con tag
ansible-playbook playbook.yml --start-at-task "Nombre de tarea"

# Terraform
terraform init        # Inicializar providers y módulos
terraform plan        # Ver qué va a crear/modificar/eliminar
terraform apply       # Aplicar los cambios
terraform destroy     # Eliminar toda la infraestructura
terraform show        # Ver el estado actual
terraform state list  # Listar todos los recursos gestionados
terraform state rm <recurso>  # Quitar del estado sin destruir
```

---

## 🔒 Notas de Seguridad

- Nunca hacer commit de `terraform.tfvars`, `*.tfstate`, claves SSH privadas ni `inventory.ini`
- Usar `ansible-vault` para todos los secretos en los playbooks
- En producción: reemplazar `host_key_checking = False` con SSH known_hosts correctamente configurado
- Restringir las reglas de NSG a IPs específicas, no dejar abierto a internet

---

## 🔗 Referencias

- [Documentación de Ansible](https://docs.ansible.com/)
- [Ansible Galaxy (roles de la comunidad)](https://galaxy.ansible.com/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Documentación de Azure CLI](https://learn.microsoft.com/es-es/cli/azure/)
