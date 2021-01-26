kubeadm reset --force
rm -rf /root/.kube

ipvsadm --clear
rm -rf /etc/cni/net.d

ip link delete flannel.1
ip link delete cni0

