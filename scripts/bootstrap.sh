#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export VERSION=1.23.3-00

step=1
step() {
    echo "Step $step $1"
    step=$((step+1))
}

disable_swap() {
    step "===== Disable swap ====="
    sudo swapoff -a
    sudo sed -i '/UUID=.* swap / s/./#&/' /etc/fstab
}

install_containerd() {
    step "===== Install containerd ====="
    sudo modprobe overlay
    sudo modprobe br_netfilter
    
sudo bash -c 'cat <<EOF > /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF'
   
sudo bash -c 'cat <<EOF > /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables    = 1
net.bridge.bridge-nf-call-ip6tables   = 1
net.ipv4.ip_forward                   = 1
EOF'

    sudo sysctl --system

    sudo apt-get update
    sudo apt-get install -y containerd

    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = true/SystemdCgroup = false/g' /etc/containerd/config.toml
    sudo systemctl restart containerd
}

install_k8s() {
    step "===== Install kubelet kubeadm kubectl ====="
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - > /dev/null

sudo bash -c 'cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF'

    sudo apt-get update
    echo $VERSION > /tmp/kubenetes_version
    sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
    sudo apt-mark hold kubelet kubeadm kubectl containerd
    sudo systemctl enable kubelet
    sudo systemctl enable containerd
    sudo systemctl restart kubelet
}

main() {
    disable_swap
    install_containerd
    install_k8s
}

main
