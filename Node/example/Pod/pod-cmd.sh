kubectl create -f pod/nginx-pod.yaml
kubectl get pods
kubectl describe pod nginx-pod
kubectl get pod nginx-pod -o wide
kubectl exec nginx-pod  -i -t -- bash
kubectl get pods --show-labels
kubectl get pods --selector app=nginx
kubectl get pods -l 'tier in (dev, pro)'
kubectl delete -f pod/nginx-pod.yaml
