Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.hostname = "devops-vm"
 
  # Network — IP fixe pour éviter les conflits DHCP
  config.vm.network "private_network", ip: "192.168.56.10"
 
  # Ressources VirtualBox
  config.vm.provider "virtualbox" do |vb|
    vb.name   = "devops-debian"
    vb.memory = "2048"
    vb.cpus   = 2
  end
 
  # Provision : installation de k3s automatiquement au démarrage
  config.vm.provision "shell", path: "scripts/install_k3s.sh"
end