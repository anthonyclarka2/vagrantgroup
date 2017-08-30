# simple class to install some of the most basic stuff
# you'll need in a shared Vagrant-created Puppet environment
class basics {

  # In case you want to customize your environment further:
  case $::fqdn {
    /controller/:     { include basics::controller }
    /worker/:         { include basics::worker }
    default:          { } # do nothing
  }

  # Set SELinux to "permissive"
  file { '/etc/selinux/config':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/basics/selinux_config',
  }

  exec { 'selinux-off':
    command     => '/usr/sbin/setenforce Permissive',
    refreshonly => false,
  }

  # Set the default elevator to "noop"
  file { '/etc/default/grub':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/basics/grub-default',
  }

  exec { 'grub2-mkconfig-elevator':
    command     => '/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.conf',
    refreshonly => true,
    subscribe   => File['/etc/default/grub'],
  }

  # Create identity files for easy SSH access.
  # Every host will get these keys.  See the README.md for more details.
  file { '/root/.ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  file { '/root/.ssh/config':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    source  => 'puppet:///modules/basics/ssh-config',
    require => File['/root/.ssh'],
  }

  file { '/root/.ssh/id_rsa':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    source  => 'puppet:///modules/basics/vagrantgroup_rsa',
    require => File['/root/.ssh'],
  }

  file { '/root/.ssh/id_rsa.pub':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/basics/vagrantgroup_rsa.pub',
    require => File['/root/.ssh/id_rsa'],
  }

  ssh_authorized_key { 'vagrant@vagrantgroup':
    user    => 'root',
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCp4AEPM+hRrknxN8J33TA+d1Bv3jO7xvHcp5VU0o4Ugfq+Kvyzaa3anbg1347vPNksyPm70yxdqdXnwGAVF3TDIjAk56OVdqd8D/5BerE3YXyAAjWikxz+/d/TPgUgG6GSqIkiVpps6dtwV0kVg+kvWmf6ml7pwLLtNBC7FENrI9cwf6L3sWc7PfPW/txgimdG4n3GYr9OyDPIC3DUqtbuOF9CN6HMO7gG+MGDclRjTxLlOSAsYEMCFTKw6r/RtRcM6HCkC3yZEFlfRHCGtL+LpSc6cDYOwpFa0+ixObm1amV4yvKgBNn6AgxbxhKABJSDXZsY3f9lJnRlOwonKAAt',
    require => File['/root/.ssh/id_rsa.pub'],
  }

  yumrepo { 'epel':
    mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch',
    gpgkey     => 'https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7',
    descr      => 'EPEL Main Repo',
    enabled    => true,
    gpgcheck   => true,
  }

  # some useful applications
  package { [
    'bzip2',
    'deltarpm',
    'tree',
    'screen',
    'lsof',
    'nmap',
    'rsync',
    'vim-enhanced',
    'dstat',
    'git',
    'htop',
    'sysstat',
    'pv',
    'man-db',
    'dos2unix',
    'zip',
    'unzip',
    'p7zip',
    'sg3_utils',
    'strace',
    'iftop',
    'tcpdump',
    'bash-completion',
    'bash-completion-extras',
    'yum-utils',
    'haveged',
    'telnet',
    'tmux',
    'lsyncd',
    'wget',
    'bind-utils',
    'pssh',
    ]:
    ensure  => latest,
    require => Yumrepo['epel'],
  }

  # haveged is useful for maintaining /dev/random
  service { 'haveged':
    ensure  => running,
    enable  => true,
    require => Package['haveged'],
  }

  # Uncomment this to set your timezone to something other than UTC
  # Edit as needed
  # exec { 'timezone-cmd':
  #   command     => '/usr/bin/timedatectl set-timezone America/New_York',
  #   refreshonly => false,
  # }

}
