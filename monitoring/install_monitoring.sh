#!/bin/bash
# install_monitoring.sh — Installation idempotente de Prometheus et Grafana

set -e

PROMETHEUS_VERSION="2.51.0"

echo "==> Installation des dépendances..."
apt-get update -y
apt-get install -y curl wget apt-transport-https software-properties-common

# ─── PROMETHEUS ───────────────────────────────────────────────
echo "==> Vérification de Prometheus..."

if systemctl is-active --quiet prometheus; then
  echo "==> Prometheus est déjà actif."
else
  echo "==> Installation de Prometheus v${PROMETHEUS_VERSION}..."

  cd /tmp
  wget -q https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
  tar xzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

  useradd --no-create-home --shell /bin/false prometheus 2>/dev/null || true
  mkdir -p /etc/prometheus /var/lib/prometheus

  cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/
  cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/
  cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /etc/prometheus/
  cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /etc/prometheus/
  rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64*

  chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

  # Copier la config
  cp /vagrant/monitoring/prometheus.yml /etc/prometheus/prometheus.yml
  chown prometheus:prometheus /etc/prometheus/prometheus.yml

  # Service systemd
  cat > /etc/systemd/system/prometheus.service << 'SERVICE'
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address=0.0.0.0:9090
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

  systemctl daemon-reload
  systemctl enable prometheus
  systemctl start prometheus
  echo "==> Prometheus installé sur le port 9090 !"
fi

# ─── GRAFANA ──────────────────────────────────────────────────
echo "==> Vérification de Grafana..."

if systemctl is-active --quiet grafana-server; then
  echo "==> Grafana est déjà actif."
else
  echo "==> Installation de Grafana..."

  wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
  echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list
  apt-get update -y
  apt-get install -y grafana

  systemctl daemon-reload
  systemctl enable grafana-server
  systemctl start grafana-server
  echo "==> Grafana installé sur le port 3000 !"
fi

echo ""
echo "==> Monitoring installé avec succès !"
echo "==> Prometheus : http://192.168.56.20:9090"
echo "==> Grafana    : http://192.168.56.20:3000 (admin/admin)"
