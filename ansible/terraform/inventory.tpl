[azure_vms]
%{ for client in clients ~}
${client.name} ansible_host=${client.public_ip}
%{ endfor ~}

[azure_vms:vars]
ansible_user=${admin_username}
ansible_ssh_private_key_file=~/.ssh/azure_ansible_key
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3

[all:vars]
ansible_connection=ssh
