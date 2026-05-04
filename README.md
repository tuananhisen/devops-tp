# DevOps TP Finale — Lacets Connectés API

## Contexte
Mise en place d'une infrastructure complète pour déployer automatiquement une API REST Node.js/MySQL de gestion de lacets connectés.

---

## Arborescence du projet

```
devops-tp/
├── Vagrantfile                          # Création automatique des VMs
├── README.md                            # Documentation
├── app/                                 # Code source de l'API
│   ├── Dockerfile                       # Image Docker optimisée (multi-stage)
│   ├── docker-compose.yml               # Compose API + MySQL
│   ├── .dockerignore                    # Exclusions Docker
│   ├── src/                             # Code Node.js
│   ├── config/                          # Configuration
│   └── sql/                             # Scripts SQL
├── scripts/
│   ├── install_k3s.sh                   # Installation k3s (idempotent)
│   ├── install_node_exporter.sh         # Installation node_exporter (idempotent)
│   ├── get_ip.sh                        # Récupération IP + génération inventaire
│   └── deploy.sh                        # Déploiement Kubernetes (idempotent)
├── ansible/
│   ├── inventory.ini                    # Inventaire Ansible (auto-généré)
│   └── playbook.yml                     # Playbook de configuration
├── k8s/
│   ├── mysql-pvc.yml                    # PersistentVolumeClaim MySQL
│   ├── mysql-deployment.yml             # Déploiement MySQL
│   ├── mysql-service.yml                # Service MySQL (ClusterIP)
│   ├── api-deployment.yml               # Déploiement API
│   ├── api-service.yml                  # Service API (ClusterIP)
│   └── api-hpa.yml                      # HorizontalPodAutoscaler (1-3 pods)
├── monitoring/
│   ├── prometheus.yml                   # Configuration Prometheus
│   └── install_monitoring.sh            # Installation Grafana + Prometheus
└── .github/
    └── workflows/
        └── deploy.yml                   # Pipeline CI/CD GitHub Actions
```

---

## Prérequis

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
- [Git](https://git-scm.com/)
- Compte [Docker Hub](https://hub.docker.com/)

---

## Partie 1 — Préparation de l'infrastructure

### Description
Déploiement automatisé d'une VM Debian avec k3s (Kubernetes léger).

### Utilisation

```bash
# Démarrer la VM k3s
vagrant up

# Récupérer l'IP et générer l'inventaire Ansible
bash scripts/get_ip.sh

# Vérifier que k3s fonctionne
vagrant ssh
sudo k3s kubectl get nodes
```

### Résultat attendu
```
NAME        STATUS   ROLES           AGE   VERSION
devops-vm   Ready    control-plane   10s   v1.35.4+k3s1
```

### Inventaire Ansible généré automatiquement
```ini
[k3s_servers]
devops-vm ansible_host=192.168.56.10 ansible_user=vagrant ...
```

---

## Partie 2 — Conteneurisation de l'application

### Description
Construction d'une image Docker optimisée avec multi-stage build et push sur Docker Hub.

### Optimisations
- Image de base : `node:20-alpine` (légère)
- Multi-stage build (séparation build/runtime)
- `.dockerignore` pour exclure les fichiers inutiles
- Dépendances de production uniquement (`npm ci --only=production`)

### Utilisation

```bash
cd app

# Build de l'image
docker build -t tuananhisen/node-api:latest .

# Push sur Docker Hub
docker push tuananhisen/node-api:latest

# Lancer avec docker-compose (API + MySQL)
docker-compose up -d
```

### Image Docker Hub
```
tuananhisen/node-api:latest
```

---

## Partie 3 — Déploiement sur Kubernetes

### Description
Déploiement de l'API et de MySQL sur k3s avec persistance des données et autoscaling.

### Architecture
```
[k3s cluster]
├── MySQL Pod  ←── PersistentVolumeClaim (données persistantes)
│      ↑
│   ClusterIP Service (interne au cluster uniquement)
│      ↑
└── API Pod (1 → 3 pods selon la charge)
       ↑
    ClusterIP Service (interne au cluster uniquement)
    HorizontalPodAutoscaler (min:1, max:3)
```

### Utilisation

```bash
# SSH dans la VM
vagrant ssh

# Déploiement complet
cd /vagrant
bash scripts/deploy.sh

# Vérification
sudo kubectl get pods
sudo kubectl get services
sudo kubectl get hpa
```

### Résultat attendu
```
NAME                     READY   STATUS    RESTARTS
mysql-xxx                1/1     Running   0
node-api-xxx             1/1     Running   0

NAME       TYPE        CLUSTER-IP     PORT(S)
mysql      ClusterIP   10.43.x.x      3306/TCP
node-api   ClusterIP   10.43.x.x      3000/TCP

NAME           MINPODS   MAXPODS   REPLICAS
node-api-hpa   1         3         1
```

---

## Partie 4 — CI/CD Pipeline

### Description
Pipeline GitHub Actions avec self-hosted runner sur la VM k3s.

### Fonctionnement
À chaque push sur la branche `main` :
1. Checkout du code
2. Login Docker Hub
3. Build de l'image Docker
4. Push sur Docker Hub
5. Déploiement sur k3s
6. Vérification des pods

### Installation du self-hosted runner

```bash
# Sur la VM
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.334.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.334.0/actions-runner-linux-x64-2.334.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.334.0.tar.gz
./config.sh --url https://github.com/tuananhisen/devops-tp --token <TOKEN>
sudo ./svc.sh install
sudo ./svc.sh start
```

### Secrets GitHub requis
| Secret | Valeur |
|--------|--------|
| `DOCKER_USERNAME` | `tuananhisen` |
| `DOCKER_PASSWORD` | Token Docker Hub |

---

## Partie 5 — Monitoring et observabilité

### Description
Monitoring des deux VMs avec Prometheus et Grafana (dashboard Node Exporter Full ID: 1860).

### Architecture
```
VM 1 (devops-vm — 192.168.56.10)
    └── node_exporter :9100

VM 2 (monitoring-vm — 192.168.56.20)
    ├── node_exporter :9100
    ├── Prometheus :9090  ←── scrape les 2 VMs
    └── Grafana :3000     ←── dashboard ID 1860
```

### Démarrage de la VM monitoring

```bash
vagrant up monitoring-vm
```

### Installation manuelle (si nécessaire)

```bash
# node_exporter sur devops-vm
bash scripts/install_node_exporter.sh

# Prometheus + Grafana sur monitoring-vm
bash monitoring/install_monitoring.sh
```

### Accès aux interfaces

| Service | URL | Credentials |
|---------|-----|-------------|
| Prometheus | http://192.168.56.20:9090 | — |
| Grafana | http://192.168.56.20:3000 | admin / admin |

### Dashboard Grafana
1. Connexions → Data sources → Add → Prometheus → URL: `http://192.168.56.20:9090`
2. Dashboards → Import → ID: `1860` → Import

---

## Notes techniques

- Tous les scripts sont **idempotents** (peuvent être relancés sans effets de bord)
- Tous les scripts sont compatibles **Linux/bash** uniquement
- L'API est accessible uniquement depuis l'intérieur du cluster (ClusterIP)
- Les données MySQL sont persistantes via PersistentVolumeClaim
- Le HPA scale automatiquement entre 1 et 3 pods selon CPU/mémoire
