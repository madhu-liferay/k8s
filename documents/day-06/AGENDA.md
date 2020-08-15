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

### RECAP

---

DaemonSet - Pods on every node... kube-proxy, networking-solutions, monitoring agent, logging agent, Kube-api server DaemonSet Controller, nodeName

Static Pods - do not have control plane components, you let kubelet manage pod for you.. (Mirror Pod), Kubelet

Kube-scheduler is not involved

To schedule a pod using a specific scheduler use the `schedulerName`


commands -----> ENTRYPOINT

args ---------> CMD

1. SideCar   ---- helps the main app
2. Adapter   ---- format or adapt itself
3. Ambassador --- proxy (localhost)



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
  volumes:
  - name: my-vol
    emptyDir: {}
  containers:
  - name: app-container
    image: alpine # alpine is a simple Linux OS image
    # Simple application: write the current date
    # to the log file every five seconds
    command: ["/bin/sh", "-c"]
    args:
    - while true; do
        date > /var/log/index.html;
        sleep 5;
      done
    # Mount the pod's shared log file into the app 
    # container. The app writes logs here.
    volumeMounts:
    - name: my-vol
      mountPath: /var/log
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
    volumeMounts:
    - name: my-vol
      mountPath: /usr/share/nginx/html

```

```yml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  #Define your volume here
  volumes:
  - name: metrics
    emptyDir: {}
  containers:
  - name: app
    image: alpine
    command: ["/bin/sh", "-c"]
    # output legacy formatted metrics every 5 seconds
    args:
    - mkdir /metrics;
      while true; do
        date > /metrics/raw.txt;
        sleep 5;
      done
    # mount the volume
    volumeMounts:
    - name: metrics
      mountPath: /metrics

  - name: adapter
    image: alpine
    command: ["/bin/sh", "-c"]
    # output format as monitoring solutions need
    args:
    - while true; do
        date=$(head -1 /metrics/raw.txt);
        echo "{\"date\":\"$date\"}" > /metrics/adapted.json;
        sleep 5;
      done
    # mount the volume
    volumeMounts:
    - name: metrics
      mountPath: /metrics
```

```bash
kubectl exec app -c adapter -it -- /bin/sh

kubectl exec app -c adapter -- cat /metrics/adapted.json


kubectl run test-pod --image=busybox:1.28 --restart=Never -it --rm -- /bin/sh
kubectl run test-pod --image=ubuntu --restart=Never -it --rm -- /bin/bash

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
  initContainers:
  - name: busy
    image: busybox:1.28
    command: ["/bin/sh", "-c"]
    args: ["sleep 120;"]
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

NAME  --> greeting the person (Anonymous)

COLOR --> background of the home page (red)

```bash
docker container run --detach --rm --name default-app --publish 8888:80 khozemanullwala/python-flask-color

docker container stop default-app

docker container run --detach --rm --name my-app --publish 9999:80 \
--env NAME="Khozema Nullwala" \
--env COLOR=blue \
 khozemanullwala/python-flask-color
```

```bash
kubectl explain pod.spec.env
kubectl explain pod.spec.env --recursive
```

```yml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    role: frontend
  name: python-color-pod
spec:
  containers:
  - image: khozemanullwala/python-flask-color
    name: python-color-container
    env:
    - name: COLOR
      value: orange
    - name: NAME 
      value: Simplilearn
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}


```

```bash
kubectl port-forward --address localhost,172.31.28.113 python-color-pod 10001:80
```


Two approach to create a ConfigMap as well as Secret: 

1. Declarative
2. Imperative

```bash
# To create the configmap using declarative way use -
kubectl create configmap app-config --from-literal=<key>=<value> --from-literal=<key>=<value> ...

kubectl create configmap app-config --from-literal=NAME=Jonty --from-literal=COLOR=green

kubectl get configmaps
# OR
k get cm

kubectl describe configmap app-config
# OR
k describe cm app-config



kubectl create configmap app-config --from-env-file=<app-config.properties>

kubectl get configmaps
# OR
k get cm
kubectl decribe configmap <config-map-name>

kubectl explain pod.spec.containers.env --recursive
kubectl explain pod.spec.containers.envFrom --recursive
```

Create a properties file `app-env.properties`

```txt
NAME=Rahul
COLOR=pink
````

```bash
kubectl create configmap another-app-config --from-env-file=app-env.properties
```
```bash
kubectl get configmaps
# OR
k get cm

kubectl describe configmap another-app-config
# OR
k describe cm another-app-config
```

```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: declarative-cm
data:
  COLOR: orange
  NAME: 
```

 name <string>
   value        <string>
   valueFrom    <Object>
      configMapKeyRef   <Object>
         key    <string>
         name   <string>
         optional       <boolean>
      fieldRef  <Object>
         apiVersion     <string>
         fieldPath      <string>
      resourceFieldRef  <Object>
         containerName  <string>
         divisor        <string>
         resource       <string>
      secretKeyRef      <Object>
         key    <string>
         name   <string>
         optional       <boolean>

```yml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: python-pod
  name: python-pod
spec:
  containers:
  - image: khozemanullwala/python-flask-color
    name: python-pod
    env:
    - name: NAME
      valueFrom:
        configMapKeyRef:
          name: 
          key: NAME
    - name: COLOR
      valueFrom:
        configMapKeyRef:
          name: 
          key: COLOR
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
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

```bash
kubectl create secret generic app-secret --from-literal=NAME=khozema --from-literal=COLOR=cyan
```

brown
Sachin

```yml
apiVersion: v1
kind: Secret
metadata:
  name: declarative-secret
data:
  COLOR: YnJvd24= 
  NAME: U2FjaGlu
```



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