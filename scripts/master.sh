#!/bin/bash

WORK_USER=vagrant
HOME_DIR=/home/$WORK_USER
NETWORK_CONF=$HOME_DIR/calico.yaml
CLUSTER_CONFIG=$HOME_DIR/ClusterConfiguration.yaml
CONTAINERD_SOCK=/run/containerd/containerd.sock
IP_ADDR=10.0.0.10

step=1
step() {
    echo "Step $step $1"
    step=$((step+1))
}

boostrap_cluster() {
    step "===== Boostrap config files and network settings ====="
    wget https://docs.projectcalico.org/manifests/calico.yaml -O $NETWORK_CONF
    kubeadm config print init-defaults 2>/dev/null > $CLUSTER_CONFIG
    sed -i "s/  advertiseAddress: 1.2.3.4/  advertiseAddress: $IP_ADDR/" $CLUSTER_CONFIG
    sed -i 's/  criSocket: \/var\/run\/dockershim.sock/  criSocket: \/run\/containerd\/containerd\.sock/' $CLUSTER_CONFIG
    sed -i 's/  name: node/  name: master/' $CLUSTER_CONFIG

cat <<EOF | cat >> $CLUSTER_CONFIG
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF
}

start_cluster() {
    step "===== Run kubeadm init ====="
    sudo kubeadm init --config=$CLUSTER_CONFIG
    mkdir -p $HOME_DIR/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME_DIR/.kube/config
    sudo chown -R $WORK_USER:$WORK_USER $HOME_DIR
    su $WORK_USER -c "kubectl apply -f $NETWORK_CONF"
}

install_helm3() {
    step "===== Install Helm3 ====="
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
}

main() {
    boostrap_cluster
    start_cluster
    install_helm3
}

main
