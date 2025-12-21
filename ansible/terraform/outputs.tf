output "resource_group_name" {
  description = "Nombre del grupo de recursos creado"
  value       = azurerm_resource_group.ansible_lab.name
}

output "vnet_name" {
  description = "Nombre de la red virtual"
  value       = azurerm_virtual_network.ansible_vnet.name
}

output "subnet_id" {
  description = "ID de la subnet"
  value       = azurerm_subnet.ansible_subnet.id
}

output "vm_details" {
  description = "Detalles de las máquinas virtuales"
  value = {
    for idx, vm in azurerm_linux_virtual_machine.ansible_vm : vm.name => {
      private_ip = azurerm_network_interface.vm_nic[idx].private_ip_address
      public_ip  = azurerm_public_ip.vm_public_ip[idx].ip_address
      admin_user = vm.admin_username
    }
  }
}

output "control_node_public_ip" {
  description = "IP pública del control node"
  value       = azurerm_public_ip.vm_public_ip[0].ip_address
}

output "client_1_public_ip" {
  description = "IP pública del cliente 1"
  value       = azurerm_public_ip.vm_public_ip[1].ip_address
}

output "client_2_public_ip" {
  description = "IP pública del cliente 2"
  value       = azurerm_public_ip.vm_public_ip[2].ip_address
}

output "ssh_commands" {
  description = "Comandos SSH para conectarse a las VMs"
  value = {
    for idx, vm in azurerm_linux_virtual_machine.ansible_vm :
    vm.name => "ssh ${vm.admin_username}@${azurerm_public_ip.vm_public_ip[idx].ip_address}"
  }
}
