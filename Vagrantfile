# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile to create a controller and 3 workers
# READ THE README.md file FIRST!!!!!
#
# anthonyclarka2 AT GMAIL 2017-08-30
#
# MIT License
#
Vagrant.configure('2') do |config|
  # start with basic latest CentOS 7.x
  config.vm.box = 'centos/7'

  # vagrant-vbguest does not require configuration unless you intend
  # to pull the guest additions ISO from a custom location.
  # https://github.com/dotless-de/vagrant-vbguest

  # Install latest version of puppet
  # https://github.com/petems/vagrant-puppet-install
  # This plugin does require internet access to grab the install script
  config.puppet_install.puppet_version = :latest

  # local domain name
  # edit this variable to change the domain name your
  # VMs use!
  ldn = 'test.local'

  # First create a Controller VM
  config.vm.define 'controller', primary: true do |controller|
    # local host name
    lhn                     = 'controller'
    controller.vm.hostname  = "#{lhn}.#{ldn}"

    controller.vm.network 'private_network', ip: '10.0.3.10'

    # vagrant-hosts custom usage is explained at
    # https://github.com/oscar-stack/vagrant-hosts
    controller.vm.provision :hosts, sync_hosts: true, add_localhost_hostnames: false

    # Control the number of vCPUs, the amount of memory in MB
    # Documentation at https://www.vagrantup.com/docs/virtualbox/configuration.html
    controller.vm.provider 'virtualbox' do |vb|
      vb.name         = 'Controller'
      vb.memory       = 2048
      vb.cpus         = 2
      vb.linked_clone = true
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end

    # This requires a Puppet environment at
    # vagrantgroup/puppet/environments/vagrant/
    controller.vm.provision :puppet, run: 'always' do |puppet|
      puppet.environment_path = './puppet/environments'
      puppet.environment      = 'vagrant'
    end # end of controller puppet config
  end # end of controller definition

  # To change the number of worker VMs built, create an environment variable:
  # export NUM_WORKERS=4
  num_workers = ENV['NUM_WORKERS'] || 3

  # Then create as many worker VMs as you need:
  # (edit the "3" on the line below to change the number of Puppet
  # nodes that get created)
  (1..num_workers).each do |j|
    # we like zero-padded numbers in our hostnames!
    i = format('%02d', j)

    config.vm.define "node#{i}" do |worker|
      lhn                = "node#{i}"
      worker.vm.hostname = "#{lhn}.#{ldn}"

      # network parameters
      worker.vm.network 'private_network', ip: "10.0.3.1#{i}"
      worker.vm.provision :hosts, sync_hosts: true, add_localhost_hostnames: false

      worker.vm.provider 'virtualbox' do |vb|
        vb.name         = "Worker #{i}"
        vb.memory       = 1024
        vb.cpus         = 1
        vb.linked_clone = true
        vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
      end

      worker.vm.provision :puppet, run: 'always' do |puppet|
        puppet.environment_path = './puppet/environments'
        puppet.environment      = 'vagrant'
      end # end of puppet config
    end # end of worker definition
  end # end of "each do" loop
end
