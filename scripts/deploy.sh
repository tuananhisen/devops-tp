#!/bin/bash
# deploy.sh — Déploiement idempotent sur k3s

set -e

echo "==> Déploiement des manifests Kubernetes..."

# Apply tous les manifests dans l'ordre
sudo kubectl apply -f k8s/mysql-pvc.yml
sudo kubectl apply -f k8s/mysql-deployment.yml
sudo kubectl apply -f k8s/mysql-service.yml
sudo kubectl apply -f k8s/api-deployment.yml
sudo kubectl apply -f k8s/api-service.yml
sudo kubectl apply -f k8s/api-hpa.yml

echo "==> Attente que MySQL soit prêt..."
sudo kubectl rollout status deployment/mysql --timeout=120s

echo "==> Attente que l'API soit prête..."
sudo kubectl rollout status deployment/node-api --timeout=120s

echo "==> Vérification des pods..."
sudo kubectl get pods

echo "==> Vérification des services..."
sudo kubectl get services

echo "==> Déploiement terminé avec succès !"
