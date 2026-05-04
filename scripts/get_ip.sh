#!/bin/bash
# get_ip.sh — Récupère l'IP de la VM Vagrant et génère l'inventaire Ansible

set -e

echo "==> Récupération de l'IP de la VM..."

# Récupère l'IP via vagrant ssh
VM_IP=$(vagrant ssh -- "ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'" 2>/dev/null)

# Fallback sur eth0 si eth1 n'existe pas
if [ -z "$VM_IP" ]; then
  VM_IP=$(vagrant ssh -- "ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'" 2>/dev/null | grep -v "10.0.2")
fi

if [ -z "$VM_IP" ]; then
  echo "ERREUR : Impossible de récupérer l'IP de la VM."
  exit 1
fi

echo "==> IP trouvée : $VM_IP"

# Génère automatiquement l'inventaire Ansible
mkdir -p ansible

cat > ansible/inventory.ini << EOF
[k3s_servers]
devops-vm ansible_host=${VM_IP} ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/default/virtualbox/private_key ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo "==> Inventaire Ansible généré dans ansible/inventory.ini"
cat ansible/inventory.ini
