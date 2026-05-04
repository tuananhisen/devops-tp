#!/bin/bash
# install_k3s.sh — Installation idempotente de k3s

set -e

echo "==> Mise à jour apt et installation de curl..."
apt-get update -y
apt-get install -y curl

echo "==> Vérification de k3s..."

# Idempotent : n'installe que si k3s n'est pas déjà présent
if command -v k3s &>/dev/null; then
  echo "==> k3s est déjà installé. Rien à faire."
  exit 0
fi

echo "==> Installation de k3s..."
curl -sfL https://get.k3s.io | sh -

echo "==> Attente que k3s soit prêt..."
sleep 10

# Vérification
k3s kubectl get nodes

echo "==> k3s installé avec succès !"
