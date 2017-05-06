#!/bin/bash

MV='sudo mv -v'

function fixperms {
  FILE=$1
  sudo chown -v root:root $FILE
  sudo chmod -v 664 $FILE
}

sudo dnf -y update
sudo dnf -y install puppet git rubygems python-pip unzip policycoreutils-python-utils

sudo pip install --upgrade pip
sudo pip install awscli
sudo gem install r10k --no-document

$MV /tmp/hiera.yaml /etc/puppet/hiera.yaml
fixperms /etc/hiera.yaml

$MV /tmp/vpn.yaml /var/lib/hiera/vpn.yaml
fixperms /var/lib/hiera/vpn.yaml

$MV /tmp/firewall.yaml /var/lib/hiera/firewall.yaml
fixperms /var/lib/hiera/firewall.yaml

$MV /tmp/Puppetfile /etc/puppet
fixperms /etc/puppet/Puppetfile

sudo mkdir -pv /etc/puppet/manifests

$MV /tmp/site.pp /etc/puppet/manifests/site.pp
fixperms /etc/puppet/manifests/site.pp

$MV /tmp/docker-openvpn@data.service /etc/systemd/system/docker-openvpn@data.service
fixperms /etc/systemd/system/docker-openvpn@data.service
sudo semanage fcontext -a -t systemd_unit_file_t /usr/lib/systemd/system/docker-openvpn@data.service
sudo restorecon -v /etc/systemd/system/docker-openvpn@data.service

cd /etc/puppet
sudo /usr/local/bin/r10k puppetfile install -v

sudo puppet apply --modulepath=/etc/puppet/modules \
  /etc/puppet/manifests/site.pp

$MV /tmp/quickstart.sh /opt/docker-openvpn/quickstart.sh
sudo chown -v root:root /opt/docker-openvpn/quickstart.sh
sudo chmod -v 0700 /opt/docker-openvpn/quickstart.sh
