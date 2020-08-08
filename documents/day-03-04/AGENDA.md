# THIS WEEK

## AGENDA

---

* Creating ReplicationController and ReplicaSet
* Understanding the difference between ReplicationController and ReplicaSet
* Understanding Types of Services and use of it
* Tips and Tricks
  * How to add alias
  * How to add bash completion
* Setting up a self-managed Kubernetes Cluster on local machine using kubeadm 
* Setting up a self-managed Kubernetes Cluster on GCP from Project perspective
* Revision of every object deployed using yaml, command, and how to create yaml template quickly using `--dry-run`

* Manual Scheduling a POD
* Using Binding Concepts
* Resource Requirements and Limits
* DaemonSets
* Static Pods
* Multiple Scheduler

---

### Creating ReplicationController and ReplicaSet

---

#### ReplicationController

```yml
apiVersion: v1
kind: ReplicationController
metadata: 
  name: nginx-rc
  labels:
    app: nginx-rc
spec:
  replicas: 5
  selector:
    name: webserver
  template:
    metadata:
      labels:
        name: webserver
    spec:
      containers:
      - name: nginx-container
        image: nginx:alpine
        ports:
        - containerPort: 80
```

#### ReplicaSet

```bash
kubectl get pods --show-labels
kubectl explain replicationcontroller.spec --recursive | grep -i selector -A 7 -m 1
kubectl explain replicaset.spec --recursive | grep -i selector -A 7 -m 1
```


```yml
apiVersion: apps/v1
kind: ReplicaSet
metadata: 
  name: nginx-rs
  labels:
    app: nginx-rs
spec:
  replicas: 5
  selector:
    # matchLabels
    #   name: nginx
    matchExpressions:
    - key: name
      operator: In
      values: [nginx]
  template:
    metadata:
      labels:
        name: nginx
    spec:
      containers:
      - name: nginx-container
        image: nginx:alpine
        ports:
        - containerPort: 80
```



---

### Understanding the difference between ReplicationController and ReplicaSet

---


create --> imperative way of saying you are managing everything

apply --> declarative way of letting kubernetes manage the resources for you

---

### Understanding Types of Services and use of it

---

---

### Tips and Tricks For autocompletion and alias

---

```bash
vim ~/.bashrc
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
source ~/.bashrc
```

---

### Setting up a self-managed Kubernetes Cluster on local machine using kubeadm

---

[Install Container Runtime](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)

[Install kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) 

[Creating a single control-plane cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

[Installing a Pod network add-on](https://kubernetes.io/docs/concepts/cluster-administration/networking/#project-calico)

---

### Setting up a self-managed Kubernetes Cluster on GCP from Project perspective
---

[Reference Link - for GCP](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-public-cloud/gce)

[Reference Link - for AWS](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-public-cloud/aws)

[Reference Link - for Azure](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-public-cloud/azure)

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

### **Joining a node to the Kubernetes cluster using kubeadm**

---

1. To get the join token execute the **`kubeadm token`** commands given below on the master node - 

```bash
# to generate random token
sudo kubeadm token generate 

# to print join command that never expires
sudo kubeadm token create <GENERATED-TOKEN> --print-join-command --ttl=0

# Sample Output
kubeadm join <MASTER-NODE-IP>:6443 --token <GENERATED-TOKEN> --discovery-token-ca-cert-hash <DISCOVERY-TOKEN>

# to view the list of token use
sudo kubeadm token list
```

**NOTE**: Now, to join many nodes to this Kubernetes cluster, execute the **`kubeadm join`** command on the another node where the **`container runtime`**, **`kubeadm`**, **`kubelet`**, and **`kubectl`** are already installed.

2. To gain remote access of the virtual machine, which has docker as the container runtime pre-installed, use -

```cmd
vagrant ssh kubeminion2
```

Or you can use the putty client.

3. Execute the commands below one by one as specified in the Kubernetes documentation on the minion1 node -

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl
```

[Reference Link - Kubernetes Docs](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)

4. Execute the join token command copied from step1 on the `minion1` node - 

```bash
sudo kubeadm join 172.16.1.100:6443 --token <GENERATED-TOKEN> \
--discovery-token-ca-cert-hash <DISCOVERY-TOKEN-HASH>
```

5. To check the status of the node joining this Kubernetes cluster execute the command below on the `master` node -

```bash
kubectl get nodes
```

---

### Revision of every object deployed using yaml, command, and how to create yaml template quickly

---

#### POD

domain-name/repository/image:tag
docker.io/library/nginx:latest

```yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: webserver
spec:
  containers:
  - name: nginx-container
    image: nginx:alpine
    ports:
    - containerPort: 80
```

```bash
# kubectl command to run a pod on v1.15
# for creating pod before v1.18 use the flag --restart with the value `Never`
kubectl run nginx-pod --image=nginx:alpine --restart=Never

# kubectl command to run a pod on v1.18
kubectl run nginx-pod --image=nginx:alpine
```

```bash
# kubectl command to generate a pod template on v1.15
kubectl run nginx-pod --image=nginx:alpine --restart=Never --labels=app=webserver,role=frontend --dry-run -o yaml > pod-template.yml 
# kubectl command to generate a pod template on v1.18
kubectl run nginx-pod --image=nginx:alpine --labels=app=webserver,role=frontend --dry-run=client -o yaml > pod-template.yml
```

#### DEPLOYMENT

---

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
  labels:
    app: nginx-d
spec:
  replicas: 3
  selector:
    matchLabels: 
      app: webserver
  template:
    metadata:
      name: nginx-pod
      labels:
        app: webserver
    spec:
      containers:
      - name: nginx-container
        image: nginx:alpine
        ports:
        - containerPort: 80
```

```bash
# kubectl command to run a deployment on v1.15
kubectl run nginx-deploy --image=nginx:alpine
# kubectl command to run a deployment on v1.18
kubectl create deployment nginx-deploy --image=nginx:alpine
```

```bash
# kubectl command to generate a deployment template on v1.15
kubectl run nginx-deploy --image=nginx:alpine --replicas=3 --dry-run -o yaml > deploy-template.yml
# kubectl command to generate a deployment template on v1.18
kubectl create deployment nginx-deploy --image=nginx:alpine --dry-run=client -o yaml > deploy-template.yml
```

---

#### Service

```yml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  labels:
    app: webserver
spec:
  selector:
    app: webserver
  ports:
  - port: 80
```

```bash
kubectl get services
kubectl get endpoints
```

```bash
# kubectl command to expose a service
kubectl expose deploy nginx-deploy --name=nginx-svc --port=80 --type=NodePort

# template
kubectl expose deploy nginx-deploy --name=nginx-svc --port=80 --type=NodePort --dry-run -o yaml > nodeport-template.yml
```

---

### Manual Scheduling a POD

---

The default scheduler in Kubernetes attempts to find the best node for your pod by going through a series of steps. 

1. Check if the node has adequate hardware resources
2. Check if the node is running out of resources
3. Specified node by a name
4. Check if node has a labels and matches the node selector in the pods
5. Check if the port is available to which it is requesting to bind
6. Check if pod is request a certain type of volume
7. tolerates taints of the node (**NOTE**: master node is tainted with `NoSchedule`)
8. Check if pod specify any affinity rules

---

1. Create a pod template

```bash
# create a pod template using the command for our playground environment
kubectl run nginx-pod --image=nginx:alpine --restart=Never --dry-run -o yaml > nginx-pod-manual-scheduling.yaml

# create a pod template using the command  for v1.18
kubectl run nginx-pod --image=nginx:alpine --dry-run=client -o yaml > nginx-pod-manual-scheduling.yaml

```

2. Open the `nginx-pod-manual-scheduling.yaml` file and modify it contents -

```bash
vim nginx-pod-manual-scheduling.yaml
```

```yml
# add the below in the spec section of pod
spec:
  nodeName: <SPECIFY-NODE-NAME-HERE>
```

3. Deploy your configuration using the command -

```bash
kubectl apply -f nginx-pod-manual-scheduling.yaml
```

4. To check the pod has been deployed on specified node name use -

```bash
# check the node name where the above pod is deployed
kubectl get pods -o wide 
```

5. To delete the pod use -

```bash
kubectl delete -f nginx-pod-manual-scheduling.yaml
```

---

### Using Binding Concepts

---

1. To understand the binding concept, remove the scheduler file from the given path using -

```bash
sudo mv /etc/kubernetes/manifests/kube-scheduler.yaml ~/kube-scheduler.yaml
```

2. Check that now there is no scheduler in the `kube-system` namespace

```bash
kubectl get pods -n kube-system
```

3. Open the `nginx-pod-manual-scheduling.yaml` file once again and remove the `nodeName` field from it

4. Apply the configuration of `nginx-pod-manual-scheduling.yaml` once again

```bash
kubectl apply -f nginx-pod-manual-scheduling.yaml
```

4. Check the status of the pod now -

```bash
kubectl get pods -o wide
```

5. We can also see `nginx-pod` details using  `kubectl proxy` and sending a curl request.

```bash
# Start the kubeclt proxy server
kubectl proxy # different than kube-proxy
curl http://localhost:8001/version
curl http://localhost:8001/api/v1/namespaces/default/pods/nginx-pod
```

6. Need to create an explicit binding object passed as data via a POST request 

```yml
apiVersion: v1
kind: Binding
metadata: 
  name: nginx-pod
target:
  apiVersion: v1
  kind: Node
  name: <YOUR-NODE-NAME>
```

```bash
curl --header "Content-Type: application/json" --request POST --data '{ "apiVersion": "v1", "kind": "Binding", "metadata": { "name" : "nginx-pod"}, "target": { "apiVersion": "v1", "kind": "Node", "name": "<YOUR-NODE-NAME>"}}' http://localhost:8001/api/v1/namespaces/default/pods/nginx-pod/binding
```

**NOTE**: Do not forget to move back the `kube-scheduler.yaml` back to the same location

```bash
sudo mv ~/kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml 
```

---

### Taints and Tolerations

---

```bash
kubectl describe nodes kmaster | grep -i taints 
```

```yml
apiVersion: v1
kind: Pod
metadata:
  name: k8s-bootcamp-pod
  labels:
    app: k8s-bootcamp-app
spec:
  containers:
  - name: k8s-bootcamp-container
    image: gcr.io/google-samples/kubernetes-bootcamp:v1
    ports:
    - containerPort: 8080
  tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"
```

[Command Reference](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#taint)

[Property Reference](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#concepts)

---

### NodeSelector and Node Affinity

---

```bash
kubectl label nodes kmaster machine=control-plane
```

```yml
apiVersion: v1
kind: Pod
metadata:
  name: k8s-bootcamp-pod
  labels:
    app: k8s-bootcamp-app
spec:
  containers:
  - name: k8s-bootcamp-container
    image: gcr.io/google-samples/kubernetes-bootcamp:v1
    ports:
    - containerPort: 8080
  nodeSelector:
    machine: control-plane
```

```yml
apiVersion: v1
kind: Pod
metadata:
  name: k8s-bootcamp-pod
  labels:
    app: k8s-bootcamp-app
spec:
  containers:
  - name: k8s-bootcamp-container
    image: gcr.io/google-samples/kubernetes-bootcamp:v1
    ports:
    - containerPort: 8080
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: machine
            operator: In
            values:
            - control-plane
```

[Reference Link](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) 

---

### Taints & Tolerations, and Node Affinity

---

Refer the image for explanation, you can use both the concept to tie a pod to specific node.

---

### Resource Requirements and Limits

---

[Reference Link](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory)

[QoS Class](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/#qos-classes)

[Additional Reference](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/)

---

### DaemonSets

---

[Reference Link](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

```yml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-ds
  namespace: kube-system
  labels:
    k8s-app: nginx
spec:
  selector:
    matchLabels:
      name: nginx
  template:
    metadata:
      labels:
        name: nginx
    spec:
      tolerations:
      # this toleration is to have the daemonset runnable on master nodes
      # remove it if your masters can't run pods

      containers:
      - name: nginx
        image: nginx:alpine
        # request and limit memory to 200Mi
        # request cpu to 100m
```

---

### Static Pods

---

```txt
/var/lib/kubelet/config.yaml
```


[Reference Link](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/#static-pod-creation)

---

### Multiple Scheduler

---

[Reference Link](https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/)

```bash
docker image ls | grep -i scheduler
```
