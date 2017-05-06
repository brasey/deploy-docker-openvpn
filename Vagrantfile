# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/25/CloudImages/x86_64/images/Fedora-Cloud-Base-Vagrant-25-1.3.x86_64.vagrant-virtualbox.box"
  config.vm.box = "fedora"
  config.vm.network "forwarded_port", guest:1194, host:1194, protocol:"udp"
  config.vm.hostname = "vpn"

  [
    'hiera.yaml',
    'vpn.yaml',
    'firewall.yaml',
    'Puppetfile',
    'site.pp',
    'quickstart.sh.erb',
    'docker-openvpn@data.service'
  ].each do |file|
    src = "files_to_provision/#{file}"
    dest = "/tmp/#{file}"
    config.vm.provision "file", source: src, destination: dest
  end

  config.vm.provision "file", source: "scripts/configure_node.sh", destination: "/tmp/configure_node.sh"
  config.vm.provision "shell", inline: "/tmp/configure_node.sh"

end
