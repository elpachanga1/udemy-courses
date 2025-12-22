# Generar archivo de inventario de Ansible automáticamente
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    clients = [
      for idx, vm in azurerm_linux_virtual_machine.ansible_vm : {
        name       = vm.name
        public_ip  = azurerm_public_ip.vm_public_ip[idx].ip_address
        private_ip = azurerm_network_interface.vm_nic[idx].private_ip_address
      }
    ]
    admin_username = var.admin_username
  })
  filename        = "${path.module}/../app/inventory.ini"
  file_permission = "0644"
}
