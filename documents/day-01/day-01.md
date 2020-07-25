## **Working with YAML**

```bash
set nu
set expandtab
set tabstop=2
set shiftwidth=2
```

---

## **Setting up a Kubernetes Cluster using kubeadm**

---

1. Install Container Runtime (Docker) on all the nodes

```bash
sudo apt update
sudo apt install -y docker.io 
sudo systemctl enable docker.service
```

2. Install Kubernetes on all the nodes

```bash
sudo apt install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl
```

3. On the controller VM, execute:

```bash
sudo kubeadm init --pod-network-cidr 192.168.0.0/16
```

4. On the controller VM, to set up kubectl for the ubuntu user, run:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

5. On the other nodes execute the `kubeadm join` command, found at the end of the output of `kubeadm init` command.

6. On the controller, verify that all nodes have joined

```bash
kubectl get nodes
```

7. On the controller, install Calico from the manifest:

```bash
curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl apply -f calico.yaml
```

8. On the controller, verify that all nodes are ready

```bash
kubectl get nodes
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

---

## **Working with etcd**

---

1. Download the etcd by using the below command -

```bash
ETCD_VERSION=3.4.10
wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
```
2. Unzip the compressed binaries
 
```bash
tar xvf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
```

3. Move the files into the `/usr/local/bin` using command -

```bash
sudo mv etcd-v${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin
```

4. View the page for etcdctl help using command -

```bash
ETCDCTL_API=3 etcdctl --help
```

5. To view all the keys from the etcd distributed data store use the command -

```bash
sudo ETCDCTL_API=3 etcdctl get / --prefix --keys-only \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

6. To add a new key to the etcd distributed data store use the command -

```bash
sudo ETCDCTL_API=3 etcdctl put firstname khozema \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

7. To get a value of key from the etcd distributed data store use the command -

```bash
sudo ETCDCTL_API=3 etcdctl get firstname \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

8. To delete the key from the etcd distributed data store use the command -

```bash
sudo ETCDCTL_API=3 etcdctl del firstname \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

9. To back up the entire etcd datastore use the command -

```bash
sudo ETCDCTL_API=3 etcdctl snapshot save snapshot.db \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

10. As per the documentation you can also save `member/snap/db` file from the etcd data directory which is `/var/lib/etcd` for default installation of kubeadm.

```bash
sudo cat /etc/kubernetes/manifests/etcd.yaml | grep data-dir
sudo cp /var/lib/etcd/member/snap/db another-snapshot.db
```

11. To verify the status of snapshot use the command -

```bash
sudo ETCDCTL_API=3 etcdctl snapshot status snapshot.db -w=table
```

12. Zip up the content of the `etcd` directory for restoring the datastore from back up in case of server failure 

```bash
sudo tar -zcvf etcd.tar.gz /etc/kubernetes/pki/etcd
```
