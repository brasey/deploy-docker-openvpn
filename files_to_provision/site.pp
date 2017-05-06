Package {
  allow_virtual => true,
}

node default {

  $vpn_url = hiera('vpn_url')
  $clients = hiera_array('clients')

  package { 'docker':
    ensure => latest,
  }

  service { 'docker':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[ 'docker' ],
  }

  vcsrepo { '/opt/docker-openvpn':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/kylemanna/docker-openvpn.git',
  }

  file { '/tmp/quickstart.sh':
    ensure  => file,
    content => template('/tmp/quickstart.sh.erb'),
  }

# Configure the firewall
# Put firewall rules in hiera:
# https://forge.puppet.com/crayfishx/firewalld

  class { 'firewalld':
    package        => 'firewalld',
    package_ensure => installed,
    service_enable => true,
    service_ensure => running,
  }

}
