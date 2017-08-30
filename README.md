# Puppet group creator

### Description
This project is at its heart a Vagrantfile to create one "controller" VM and multiple "worker" VMs.  This can be used to test load balancing, clustered software such as JBoss domain mode, server-client software, or many other multi-VM scenarios.

It also includes configuration code using Puppet to set up some basic helper tools such as a shared host-only network connecting the VMs, VM:/etc/hosts with all hostnames added, and a shared SSH public key for each hosts' root users.

### Requirements

#### Vagrant
Requires the following vagrant plugins:
* vagrant-puppet-install
* vagrant-vbguest
* vagrant-hosts

install them with **"vagrant plugin install PLUGINNAME"**

#### Linux
On Fedora, the "vagrant-puppet-install" plugin required libffi-devel and redhat-rpm-config.

#### Windows
Install both Vagrant and VirtualBox to their own directories without spaces in the names.  For example, c:\VirtualBox and c:\Vagrant.  As of Vagrant 1.9.8 and VirtualBox 5.1.26 this Vagrantfile works on Windows 10.

### Overview
This Vagrantfile relies on the vagrant-vbguest plugin to install the virtualbox guest additions, which unfortunately take a while to install.  First run or a full rebuild will take a few minutes.

The VMs created by this file are "linked clones" of a master image.  This means that they are essentially running from disk snapshots.  Once built, they should be very fast to start and use hardly any disk space.

These VMs are CentOS 7 based.  A standard CentOS mirror is used, and I have not looked into using a manually-set local mirror.  This means that your VMs should be able to access the internet over http and https.

### Networks
This Vagrantfile creates hosts with 2 networks.  The standard NAT network is linked to eth0.  Linked to the eth1 network adapter is a host-only network that can be used for inter-VM communication and direct SSH access.

#### WARNING!!

Please ensure that you have only one host-only network, that DHCP is disabled on that network, and that its address is 10.0.3.0/24.  If you can't change your setup to match that, then edit the code to modify the static IPs that are given to the VMs.  VirtualBox "should" do the right thing and create the network first time, but of course YMMV.

### Number of worker VMs
You can control the number of worker VMs by setting the environment variable "NUM_WORKERS" before running "vagrant up".  Set the number of desired clients as an integer.  Numbers above 9 have not been tested!

### SSH Keys

In the ./puppet/environments/vagrant/modules/basics/files/ directory, there is a private and public ssh key pair.  These will be copied to every root user in the vagrant-created VMs and added to its authorized_keys file to allow easier ssh access between hosts.

You can copy these keys to your own ~/.ssh/ directory and use this code snippet in your ~/.ssh/config file to access the VMs:
```
# replace test with whatever you named your local test domain
Host 10.0.3.* *.test.local
  User root
  IdentityFile ~/.ssh/vagrantgroup_rsa
  Compression no
  ControlMaster auto
  ControlPath ~/.ssh/sockets/%r@%h-%p
  ControlPersist 600
```

Remember that ssh config files use the first value matched.  The "ControlMaster" attributes require a linux or mac to work, and will fail if the ~/.ssh/sockets/ directory does not exist.

The files were created using this command:
```
$ ssh-keygen -t rsa -b 2048 -C "vagrant@vagrantgroup" -f vagrantgroup_rsa
The key fingerprint is:
SHA256:bWJFKS08YLG35RwEc8ZKmqgEPhbTlMF4FA8SoRY8mS4 vagrant@vagrantgroup
The key's randomart image is:
+---[RSA 2048]----+
|.=@*+ ++o+=.     |
|oOo=o. .**+      |
|+o=  o.+.=+      |
|E=. . o..B .     |
|o...    S =      |
|  .    . o       |
|                 |
|                 |
|                 |
+----[SHA256]-----+
```

### Puppet
This project relies on Puppet to do the post-boot VM configuration.

The bootstrap file that is read first is ./puppet/environments/vagrant/manifests/site.pp and currently just calls the "basics" class.




#### Hiera
Hiera will work, and a basic version 5 compatible hiera.yaml is provided at ./puppet/environments/vagrant/hiera.yaml.

### Misc directory
The ./misc/ directory will be copied to each VM using rsync.  This can be useful for distributing files.
