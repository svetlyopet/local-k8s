NUM_WORKER_NODES=2
IP_NW='10.0.0.'
IP_START=10
VAGRANTFILE_API_VERSION = "2"
JOIN_COMMAND=""

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provision:shell, inline: <<-SHELL
        sudo timedatectl set-timezone Europe/Sofia
        sudo echo "10.0.0.1$((IP_START)) master" >> /etc/hosts
        for i in {1..#{NUM_WORKER_NODES}}
        do
            sudo echo "10.0.0.1$((IP_START+i)) node0${i}" >> /etc/hosts
        done
        sudo rm /etc/resolv.conf
        sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
    SHELL

    config.vm.box = "generic/ubuntu2004"
    config.vm.box_download_insecure = true
    config.vm.box_version = "3.1.16"
    config.vm.synced_folder "./shared", "/mnt/shared",
        owner: "vagrant", group: "vagrant"

    config.vm.define "master" do |master|
        master.vm.hostname = "master"
        master.vm.network "private_network", ip: IP_NW + "#{IP_START}", netmask:"255.0.0.0"
        master.vm.network "forwarded_port", guest: 80, host: 8080,
            auto_correct: true
        master.vm.provider "virtualbox" do |vb|
            vb.memory = 4096
            vb.cpus = 2
            vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        end
        master.vm.provision "shell", path: "scripts/bootstrap.sh"
        master.vm.provision "shell", path: "scripts/master.sh"
        master.vm.provision "shell", inline: "kubeadm token create --print-join-command" do |s|
            s.inline = "kubeadm token create --print-join-command > /mnt/shared/kubernetes_join_command"
        end
    end

    (1..NUM_WORKER_NODES).each do |i|
        config.vm.define "node0#{i}" do |node|
            node.vm.hostname = "node0#{i}"
            node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}", netmask:"255.0.0.0"
            node.vm.provider "virtualbox" do |vb|
                vb.memory = 2048
                vb.cpus = 2
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
            end
            node.vm.provision "shell", path: "scripts/bootstrap.sh"
            node.vm.provision "shell", inline: "sudo $JOIN_COMMAND" do |s|
                s.inline = "JOIN_COMMAND=$(cat /mnt/shared/kubernetes_join_command) && sudo $JOIN_COMMAND"
            end
        end
    end  
end
