
# Kubernetes cluster for experiment

1. Clone git Repo
2. $ vagrant up
3. Go to client node and run join command

### Join new worker node to master

**Note: Step 1-3 on Master Node and Step 4 on worker node**

Step 1: Create Tocken
``` $ kubeadm token create --description "Demo token" --ttl 1h ```

Step 2: List tocken
``` $ kubeadm token list ```

Step 3: Create Certificate
``` $ openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' ```

Step 4: Join worker node
 - Take tocken from step 1 and hash from step 3
``` kubeadm join \
  --token cwf92w.i46lw7mk4cq8vy48 \
  --discovery-token-ca-cert-hash sha256:12920e76e48212ff292e45d716bba76da5d3230f1e1ef4055a586206b5e69138 \
  10.10.10.11:6443 ```

