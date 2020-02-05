# -*- mode: ruby *-*
# vi: set ft=ruby

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.box_version = "1902.01"
  cluster = {
    "master-1" => { :ip => "10.10.10.11", :cpus => 2, :memory => 1548, :disk => "30G", :port => "2030" },
    "worker-1" => { :ip => "10.10.10.21", :cpus => 1, :memory => 1996, :disk => "50G", :port => "2031" },
    "worker-2" => { :ip => "10.10.10.22", :cpus => 1, :memory => 1996, :disk => "50G", :port => "2024" }
  }

  cluster.each do | hostname, specs |
    config.vm.define hostname do |node|
      node.vm.hostname = hostname
	  node.vm.network :private_network, ip: specs[:ip]
	  node.vm.provider "virtualbox" do |v|
	    v.memory = specs[:memory]
	    v.cpus = specs[:cpus]
	  end

	  node.vm.network "public_network", bridge: "en0: Wi-Fi (AirPort)"
	  node.vm.synced_folder "./Node", "/vagrant"
	  node.vm.provision :shell, :inline => "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config; sudo systemctl restart sshd;", run: "always"
	  node.vm.provision "shell", inline: <<-SHELL
	    host=$(hostname)
		if [ $host == "master-1" ]
		then
			# Master Node
			bash /vagrant/master/setup.sh
		else
			# Worker Node
			bash /vagrant/worker/setup.sh
		fi
	  SHELL
	end
	# TODO: Add disk custom size
	#config.disksize.size = specs[:disk]
  end
end