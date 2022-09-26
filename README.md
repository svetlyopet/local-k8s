# Provision a local kubernetes cluster with Vagrant

Repo for deploying and setting up a local k8s cluster for testing purposes. </br>
The cluster uses a [Calico](https://docs.projectcalico.org/) network and containerd as the container runtime. </br>
Everything placed in the ./shared folder of this repo will be available in the master node at /mnt/shared .

## Minimal Hardware Requirements:

x86-64 CPU architecture </br>
6 CPU Cores </br>
8 GB Memory

## Software Requirements:

VirtualBox </br>
Vagrant

## Quick start:

Clone this repository </br>
Run:
```
vagrant up
```
Worker nodes are not automatically added to the cluster, so to connect them, login to the master node and get a join command with token:
```
vagrant ssh master
kubeadm token create --print-join-command
```

Then copy the output from the previous command and run it with sudo on the worker nodes.
