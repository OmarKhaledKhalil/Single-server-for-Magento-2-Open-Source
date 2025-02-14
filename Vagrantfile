Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true 
  config.hostmanager.manage_host = true

### Machine  ####
  config.vm.define "SingleServer" do |SingleServer|
    SingleServer.vm.box = "eurolinux-vagrant/centos-stream-9"
    SingleServer.vm.box_version = "9.0.43"
    SingleServer.vm.hostname = "SingleServer"
    SingleServer.vm.network "private_network", ip: "192.168.56.101"
    SingleServer.vm.provider "virtualbox" do |vb|
     vb.memory = "8192"
      vb.cpus = 4
   end

    # Add the shell provisioner
     SingleServer.vm.provision "shell", path: "Magento_Single_Server_Script.sh"
 end
end
