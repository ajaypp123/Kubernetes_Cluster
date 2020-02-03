#!/bin/bash

######################### Both Node ##################################

#### Step 1


# Install Docker CE
## Set up the repository
### Install required packages.
yum install -y yum-utils device-mapper-persistent-data lvm2

### Add Docker repository.
yum-config-manager --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

## Install Docker CE.
yum update -y && yum install -y \
  containerd.io-1.2.10 \
  docker-ce-19.03.4 \
  docker-ce-cli-19.03.4

## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
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

mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

swapoff -a
exit
############################ Master ####################################################

##### Step 2

kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm join 192.168.0.114:6443 --token hk7rpz.5n1gpacrb4l8x0ho \
    --discovery-token-ca-cert-hash sha256:2b4cbfd8f2ed122d12219541bf5c34c27647611a12ec09f6f68c85325ac01e30


####### Step 3
kubeadm token list
kubeadm token create --description "Demo token" --ttl 1h
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
#5a2329a9ac4ceb8f0cab74e129191c88ed6ffba794702b403e4fe0476542867c


################################## Worker ############################################

############ Step 4
kubeadm join 10.0.2.15:6443 --token qafv4u.x20jjpvkwbxyrf8u --discovery-token-ca-cert-hash sha256:5a2329a9ac4ceb8f0cab74e129191c88ed6ffba794702b403e4fe0476542867c



