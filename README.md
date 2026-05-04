# DevOps TP Finale — Infrastructure

## Contexte
Mise en place automatisée d'une VM Debian avec k3s pour déployer une API de lacets connectés.

## Prérequis
- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
- [Ansible](https://www.ansible.com/) (optionnel, pour la suite)

## Arborescence
```
projet/
├── Vagrantfile               # Création automatique de la VM Debian
├── scripts/
│   ├── install_k3s.sh        # Installation de k3s (idempotent)
│   └── get_ip.sh             # Récupération IP + génération inventaire
├── ansible/
│   └── inventory.ini         # Inventaire Ansible (auto-généré)
└── README.md
```

## Utilisation

### 1. Démarrer la VM
```bash
vagrant up
```
> Cela crée la VM Debian (2Go RAM) et installe k3s automatiquement.

### 2. Récupérer l'IP et générer l'inventaire Ansible
```bash
bash scripts/get_ip.sh
```

### 3. Vérifier que k3s fonctionne
```bash
vagrant ssh
sudo k3s kubectl get nodes
```

### 4. Arrêter / Détruire la VM
```bash
vagrant halt      # Arrêter
vagrant destroy   # Supprimer complètement
```

## Notes
- Tous les scripts sont idempotents (peuvent être relancés sans effets de bord)
- Scripts compatibles Linux uniquement (bash)
