#!/bin/bash
# install_node_exporter.sh — Installation idempotente de node_exporter

set -e

NODE_EXPORTER_VERSION="1.7.0"

echo "==> Vérification de node_exporter..."

if systemctl is-active --quiet node_exporter; then
  echo "==> node_exporter est déjà installé et actif. Rien à faire."
  exit 0
fi

echo "==> Installation de node_exporter v${NODE_EXPORTER_VERSION}..."

apt-get update -y
apt-get install -y curl wget

cd /tmp
wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*

# Créer un utilisateur dédié
useradd --no-create-home --shell /bin/false node_exporter 2>/dev/null || true

# Créer le service systemd
cat > /etc/systemd/system/node_exporter.service << 'SERVICE'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "==> node_exporter installé et démarré sur le port 9100 !"
