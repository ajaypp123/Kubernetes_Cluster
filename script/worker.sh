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

# Install Kubernetes
rpm -q kubelet || yum install -y kubelet
rpm -q kubeadm || yum install -y kubeadm
rpm -q kubectl || yum install -y kubectl

[ -f /etc/sysctl.d/k8s.conf ] || {
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
}

