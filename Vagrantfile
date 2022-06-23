# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  # Plugins
  config.vagrant.plugins = ["vagrant-disksize", "vagrant-vbguest"]

  # Ubuntu 20.04 LTS (Focal Fossa)
  config.vm.box = "ubuntu/focal64"

  # Disksize
  config.disksize.size = "20GB"
  
  config.vm.hostname = "kupl"
  config.vm.define "dd-klee"
  config.vm.provider "virtualbox" do |vb|
    vb.name = "dd-klee"
    vb.memory = "8192"
    vb.cpus = "2"
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end
  
  config.vm.provision "bootstrap", type: "shell",
      privileged: false, run: "always" do |bs|
    bs.path = "vagrant.sh"
  end
end
