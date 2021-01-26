#!/bin/bash

# Install Docker CE
yum install -y yum-utils device-mapper-persistent-data lvm2

[ -f /etc/yum.repos.d/docker-ce.repo ] || {
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
}

## Install Docker CE.
rpm -q containerd.io || yum install -y containerd.io-1.2.10
rpm -q docker-ce || yum install -y docker-ce-19.03.4
rpm -q docker-ce-cli || yum install -y docker-ce-cli-19.03.4


## Create /etc/docker directory.
mkdir -p /etc/docker

# Setup daemon.
[ -f /etc/docker/daemon.json ] || {

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

}

mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

# Setup Kubernetes
[ -f /etc/yum.repos.d/kubernetes.repo ] || {
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
}

# Set SELinux in permissive mode (effectively disabling it)
#setenforce 0
#sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install Kubernetes
rpm -q kubelet || yum install -y kubelet #--disableexcludes=kubernetes
rpm -q kubeadm || yum install -y kubeadm #--disableexcludes=kubernetes
rpm -q kubectl || yum install -y kubectl #--disableexcludes=kubernetes
systemctl enable --now kubelet

[ -f /etc/sysctl.d/k8s.conf ] || {
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
}

swapoff -a
#sed -i '/swap/d' /etc/fstab # remove swap line

# Init kubeadm
#kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.10.10.11
mkdir -p /etc/systemd/system/kubelet.service.d/

[ -f /etc/systemd/system/kubelet.service.d/20-allow-swap.conf ] || {
cat <<EOF > /etc/systemd/system/kubelet.service.d/20-allow-swap.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"
EOF
}

sudo systemctl daemon-reload

kubeadm init --ignore-preflight-errors=Swap --apiserver-advertise-address=10.230.250.72 --pod-network-cidr=172.16.0.0/16
#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Connect funnal network
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

