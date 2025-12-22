variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "rg-ansible-lab"
}

variable "location" {
  description = "Ubicación de Azure"
  type        = string
  default     = "East US"
}

variable "vnet_address_space" {
  description = "Espacio de direcciones de la red virtual"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Prefijo de direcciones de la subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vm_size" {
  description = "Tamaño de las máquinas virtuales"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Usuario administrador para las VMs"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Contraseña del usuario administrador"
  type        = string
  sensitive   = true
}

variable "vm_names" {
  description = "Nombres de las máquinas virtuales"
  type        = list(string)
  default     = ["client-1", "client-2"]
}
