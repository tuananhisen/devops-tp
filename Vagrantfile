Vagrant.configure("2") do |config|

  # VM 1 — k3s (existante)
  config.vm.define "devops-vm" do |k3s|
    k3s.vm.box = "debian/bookworm64"
    k3s.vm.hostname = "devops-vm"
    k3s.vm.network "private_network", ip: "192.168.56.10"

    k3s.vm.provider "virtualbox" do |vb|
      vb.name   = "devops-debian"
      vb.memory = "2048"
      vb.cpus   = 2
    end

    k3s.vm.provision "shell", path: "scripts/install_k3s.sh"
    k3s.vm.provision "shell", path: "scripts/install_node_exporter.sh"
  end

  # VM 2 — Monitoring (Grafana + Prometheus)
  config.vm.define "monitoring-vm" do |mon|
    mon.vm.box = "debian/bookworm64"
    mon.vm.hostname = "monitoring-vm"
    mon.vm.network "private_network", ip: "192.168.56.20"

    mon.vm.provider "virtualbox" do |vb|
      vb.name   = "monitoring-vm"
      vb.memory = "2048"
      vb.cpus   = 2
    end

    mon.vm.provision "shell", path: "scripts/install_node_exporter.sh"
    mon.vm.provision "shell", path: "monitoring/install_monitoring.sh"
  end

end
