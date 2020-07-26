## **Working with YAML**

```bash
set nu
set expandtab
set tabstop=2
set shiftwidth=2
```

---

## **Basic Commands To Work With kubectl**

---

```bash
# to list the nodes of the kubernetes cluster
kubectl get nodes
# to list the pods of the kubernetes cluster
kubectl get pods
# to list the pods of the kube-system namespace
kubectl get pods --namespace kube-system
# OR
kubectl get po -n kube-system
# to list the deployments of the kubernetes cluster
kubectl get deployments
# OR
kubectl get deploy
```

Prior to version Kubernetes v18 the `kubectl run` command was used to create deployment.

```bash
# Prior to v18 it will create deployment with a deprecation warning
kubectl run nginx-d --image=nginx:alpine
# From v18 it started creating pods
kubectl run nginx-p --image=nginx:alpine
```
