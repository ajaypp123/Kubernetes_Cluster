# Replication Controller
kubectl create -f Replica/replication-controller.yaml
kubectl get pods
kubectl get rc
kubectl scale rc nginx --replicas=5
kubectl scale rc nginx --replicas=2
kubectl delete -f Replica/replication-controller.yaml

# Replica Set
kubectl create -f Replica/replication-set.yaml
kubectl get pods
kubectl get rs
kubectl scale rs nginx --replicas=5
kubectl scale rs nginx --replicas=2
kubectl delete -f Replica/replication-set.yaml
