# 🔧 Ansible + Terraform — Detailed Documentation

> **Language / Idioma:** 🇬🇧 **English** (current) | [🇪🇸 Español](../es/ansible.md)
>
> ← [Back to main README](../../README.md) | [Folder README](../../ansible/README.md)

---

## 📖 Overview

This module teaches infrastructure automation using **two complementary tools**:

| Tool | Role | What it does |
|------|------|-------------|
| **Terraform** | Infrastructure provisioning | Creates Azure VMs, networks, security groups |
| **Ansible** | Configuration management | Installs software, manages files, runs tasks on those VMs |

The workflow is: **Terraform provisions → Ansible configures**.

---

## 🏗️ Architecture

```
WSL Ubuntu (Control Node)
    │
    │  SSH (port 22)
    ▼
Azure Cloud
  └── Resource Group: rg-ansible-lab
        └── Virtual Network: 10.0.0.0/16
              └── Subnet: 10.0.1.0/24
                    ├── client-1 (Ubuntu 22.04, public IP)
                    └── client-2 (Ubuntu 22.04, public IP)

Flow:
  1. terraform apply  →  provisions VMs + writes app/inventory.ini
  2. ansible-playbook →  SSHs into VMs and runs configuration tasks
```

---

## 🚀 Quick Start

### Prerequisites

```bash
# Install in WSL Ubuntu
sudo apt update
sudo apt install -y ansible python3-pip
pip3 install ansible-lint

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
```

### Step 1 — SSH Key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_ansible_key
# Copy the public key for terraform.tfvars
cat ~/.ssh/azure_ansible_key.pub
```

### Step 2 — Configure Terraform
```bash
cd /mnt/c/Users/<user>/Documents/GitHub/udemy-courses/ansible/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars:
#   admin_username = "azureuser"
#   ssh_public_key = "ssh-rsa AAAA..."
```

### Step 3 — Provision Infrastructure
```bash
terraform init
terraform plan
terraform apply   # Creates VMs + generates app/inventory.ini
```

### Step 4 — Verify & Run Playbooks
```bash
cd ../app
ansible all -m ping                                    # Test connectivity
ansible-playbook playbooks/remote/check-remote-clients.yml
```

---

## 📚 Ansible Concepts Covered

### Playbook Structure
```yaml
---
- name: My Playbook
  hosts: all          # targets from inventory
  become: true        # sudo
  vars:
    my_var: "value"
  tasks:
    - name: Install nginx
      ansible.builtin.apt:
        name: nginx
        state: present
      notify: Restart nginx   # triggers handler
  handlers:
    - name: Restart nginx
      ansible.builtin.service:
        name: nginx
        state: restarted
```

### Playbook Topics

#### Conditions (`with-conditions/`)
```yaml
- name: Install on Debian only
  apt:
    name: nginx
    state: present
  when: ansible_os_family == "Debian"
```

#### Loops (`with-loops/`)
```yaml
- name: Install multiple packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - git
    - curl
```

#### Handlers (`with-handlers/`)
```yaml
tasks:
  - name: Copy nginx config
    copy:
      src: nginx.conf
      dest: /etc/nginx/nginx.conf
    notify: Reload nginx

handlers:
  - name: Reload nginx
    service:
      name: nginx
      state: reloaded
```

#### Roles (`with-roles/`)
Roles organize playbooks into a standard folder structure:
```
roles/
└── webserver/
    ├── tasks/main.yml       ← main task list
    ├── handlers/main.yml    ← handlers
    ├── defaults/main.yml    ← default variables
    ├── files/               ← static files to copy
    ├── templates/           ← Jinja2 templates
    └── vars/main.yml        ← role variables
```

#### Tags (`with-tags/`)
```yaml
tasks:
  - name: Install packages
    apt:
      name: nginx
    tags: [install, packages]

  - name: Start service
    service:
      name: nginx
      state: started
    tags: [service, start]
```
```bash
# Run only install tasks
ansible-playbook site.yml --tags "install"
# Skip service tasks
ansible-playbook site.yml --skip-tags "service"
```

#### Variables (`with-variables/`)
Variable precedence (lowest → highest):
1. `defaults/main.yml` (role defaults)
2. `group_vars/all`
3. `group_vars/<group>`
4. `host_vars/<host>`
5. Playbook `vars:`
6. `--extra-vars` (CLI)

#### Ansible Vault (`with-vault/`)
```bash
# Create encrypted file
ansible-vault create secrets.yml

# Encrypt existing file
ansible-vault encrypt vars.yml

# Edit encrypted file
ansible-vault edit secrets.yml

# Run playbook with vault password
ansible-playbook site.yml --ask-vault-pass
# Or use a password file
ansible-playbook site.yml --vault-password-file .vault_pass
```

---

## 🔑 Commands Reference

```bash
# Inventory & connectivity
ansible-inventory --list                          # List all hosts
ansible all -i inventory.ini -m ping             # Ping all
ansible all -m setup                             # Gather facts

# Playbook execution
ansible-playbook playbook.yml                    # Run playbook
ansible-playbook playbook.yml --check            # Dry run
ansible-playbook playbook.yml --syntax-check     # Validate YAML
ansible-playbook playbook.yml -v / -vv / -vvv   # Verbosity levels
ansible-playbook playbook.yml --limit client-1   # Run on one host
ansible-playbook playbook.yml --tags "install"   # Run tagged tasks
ansible-playbook playbook.yml --start-at-task "Task name"

# Terraform
terraform init
terraform plan
terraform apply
terraform destroy
terraform show
terraform state list
terraform state rm <resource>   # Remove from state without destroying
```

---

## 🔒 Security Notes

- Never commit `terraform.tfvars`, `*.tfstate`, SSH private keys, or `inventory.ini`
- Use `ansible-vault` for all secrets in playbooks
- In production: replace `host_key_checking = False` with proper SSH known_hosts
- Restrict NSG rules to specific IPs, not the open internet

---

## 🔗 References

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Galaxy (community roles)](https://galaxy.ansible.com/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Docs](https://learn.microsoft.com/en-us/cli/azure/)
