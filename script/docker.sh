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

