# Resource Group
resource "azurerm_resource_group" "ansible_lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Lab"
    Purpose     = "Ansible"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "ansible_vnet" {
  name                = "vnet-ansible-lab"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.ansible_lab.location
  resource_group_name = azurerm_resource_group.ansible_lab.name

  tags = {
    Environment = "Lab"
  }
}

# Subnet
resource "azurerm_subnet" "ansible_subnet" {
  name                 = "subnet-ansible"
  resource_group_name  = azurerm_resource_group.ansible_lab.name
  virtual_network_name = azurerm_virtual_network.ansible_vnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

# Network Security Group
resource "azurerm_network_security_group" "ansible_nsg" {
  name                = "nsg-ansible-lab"
  location            = azurerm_resource_group.ansible_lab.location
  resource_group_name = azurerm_resource_group.ansible_lab.name

  # Regla para permitir SSH
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regla para permitir comunicación interna
  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = {
    Environment = "Lab"
  }
}

# Public IPs
resource "azurerm_public_ip" "vm_public_ip" {
  count               = length(var.vm_names)
  name                = "pip-${var.vm_names[count.index]}"
  location            = azurerm_resource_group.ansible_lab.location
  resource_group_name = azurerm_resource_group.ansible_lab.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Lab"
    VMName      = var.vm_names[count.index]
  }
}

# Network Interfaces
resource "azurerm_network_interface" "vm_nic" {
  count               = length(var.vm_names)
  name                = "nic-${var.vm_names[count.index]}"
  location            = azurerm_resource_group.ansible_lab.location
  resource_group_name = azurerm_resource_group.ansible_lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ansible_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip[count.index].id
  }

  tags = {
    Environment = "Lab"
    VMName      = var.vm_names[count.index]
  }
}

# Asociar NSG a las NICs
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  count                     = length(var.vm_names)
  network_interface_id      = azurerm_network_interface.vm_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.ansible_nsg.id
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "ansible_vm" {
  count               = length(var.vm_names)
  name                = var.vm_names[count.index]
  location            = azurerm_resource_group.ansible_lab.location
  resource_group_name = azurerm_resource_group.ansible_lab.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.vm_nic[count.index].id
  ]

  # Configuración de autenticación
  disable_password_authentication = var.ssh_public_key != "" ? true : false
  admin_password                  = var.ssh_public_key == "" ? var.admin_password : null

  # SSH Key configuration
  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_key != "" ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  os_disk {
    name                 = "osdisk-${var.vm_names[count.index]}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Script de inicialización básico
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    # Actualizar el sistema
    apt-get update
    
    # Instalar Python (necesario para Ansible)
    apt-get install -y python3 python3-pip
    
    # Configurar hostname
    hostnamectl set-hostname ${var.vm_names[count.index]}
    EOF
  )

  tags = {
    Environment = "Lab"
    Purpose     = "Ansible"
    Role        = count.index == 0 ? "Control" : "Managed"
  }
}
