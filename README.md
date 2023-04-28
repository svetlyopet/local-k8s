# Provision a local kubernetes cluster with Vagrant

Repo for deploying and setting up a local k8s cluster for testing purposes. </br>
The cluster uses a [Calico](https://docs.projectcalico.org/) network and containerd as the container runtime. </br>
Everything placed in the ./shared directory of this repo will be available in all the nodes at /mnt/shared .

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

Connect to the master node and start testing
```
vagrant ssh master
```
