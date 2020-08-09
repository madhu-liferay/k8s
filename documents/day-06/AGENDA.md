# DAY 06

## AGENDA

---

* Simple Demo of SideCar and Adapter
* InitContainers
* Exec into a Pod container
* ConfigMap and Secret
* Scaling of Deployment
* Understanding RollingUpdate Strategy
* Using Rollout Command
* Metric Server and Use of top `command`
* Pod Autoscaling using hpa

---

### Simple Demo of SideCar and Adapter

---

```yml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-sidecar
spec:
  # Define the volume here with its type

  containers:
  - name: app-container
    image: alpine # alpine is a simple Linux OS image
    # Simple application: write the current date
    # to the log file every five seconds

    # Mount the pod's shared log file into the app 
    # container. The app writes logs here.

    # Sidecar container
  - name: sidecar-container
    # Simple sidecar: display log files using nginx.
    # In reality, this sidecar would be a custom image
    # that uploads logs to a third-party or storage service.
    image: nginx:alpine
    ports:
      - containerPort: 80

    # Mount the pod's shared log file into the sidecar
    # container. In this case, nginx will serve the files
    # in this directory.

```

```yml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  #Define your volume here

  containers:
  - name: app
    image: alpine
    command: ["/bin/sh", "-c"]
    # output legacy formatted metrics every 5 seconds
    args:

    # mount the volume

  - name: adapter
    image: alpine
    command: ["/bin/sh", "-c"]
    # output format as monitoring solutions need
    args:

    # mount the volume

```

---

### InitContainers

---

[Reference Link](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)

```yml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  containers:
  - name: web
    image: nginx:alpine
    ports:
    - containerPort: 80
```

---

### Exec into a Pod container

---

```bash
kubectl exec <pod-name> -c <container-name> -- task to execute
```

---

### ConfigMap and Secrets

---


Two approach to create a ConfigMap as well as Secret: 

1. Declarative
2. Imperative

```bash
# To create the configmap using declarative way use -
kubectl create configmap app-config --from-literal=<key>=<value> --from-literal=<key>=<value> ...
kubectl create configmap app-config --from-env-file=<app-config.properties>

kubectl get configmaps
# OR
k get cm
kubectl decribe configmap <config-map-name>

kubectl explain pod.spec.containers.env --recursive
kubectl explain pod.spec.containers.envFrom --recursive
```

```yml
---
  env:
  - name : 
    valueFrom: 
      configMapKeyRef:
        name: 
        key:
  env:
  - name : 
    valueFrom: 
      secretKeyRef:
        name: 
        key:
---
  envFrom:
  - configMapRef:
      name:
---
  envFrom:
  - secretRef:
      name:
---

```

---

### Scaling of Deployment

---



---

### Understanding RollingUpdate Strategy

---



---

### Using Rollout Command

---



---

### Metric Server and Use of top `command`

---

**Steps For INSTALLING METRIC SERVER ON A CLUSTER SET UP USING KUBEADM**

1. Visit the below url, refer the Deployment section and copy the command given to deploy the metrics server components.

```bash
https://github.com/kubernetes-sigs/metrics-server
```

2. Once deployed edit the deployment by using the command -

```bash
kubectl edit -n kube-system deploy/metrics-server
```

3. In the spec section of pod template, add a command specification as shown below -

```yml
  command:
  - /metrics-server
  - --kubelet-insecure-tls=true
  - --kubelet-preferred-address-types=InternalIP
```

4. Wait for the deployment to be updated.

```bash
kubectl top pod
kubectl top pod --namespace=<namespace_name>
kubectl top pod <pod_name> --containers
kubectl top node
kubectl top node <node_name> # Gets individual node CPU and Memory usage
```

---

### Pod Autoscaling using hpa

---

[Reference Link](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)

---

### Next Week

---

[Upgrading from v1.15 to v1.16](https://v1-16.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)