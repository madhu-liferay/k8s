# DAY 05

## AGENDA

---

* DaemonSets
* Static Pods
* Multiple Scheduler
* Commands and Arguments
* Multi-containers Pod
* Sharing volumes among containers
* Different Patterns for Multi-containers Pod
  * SideCar
  * Adapter
  * Ambassador 
* Get Logs of a Pod container

---

### RECAP

---

https://github.com/rustyamigo/k8s/blob/master/documents/day-03-04/AGENDA.md
https://github.com/rustyamigo/k8s/blob/master/documents/day-05/AGENDA.md

Manual Scheduling a Pod

nodeName: kmaster

Pending

kubectl proxy


requests
	cpu
	memory
limits
	cpu
	memory

QoS
Guaranteed -->
Burstable  -->
BestEffort --> 

nodeSelector
	key: value

nodeAffinity
	requiredDuringSchedulingIgnoredDuringExecution

Taints and Tolerations

NoSchedule - No Pods can be scheduled, existing pod will still be running
PreferNoSchedule - does not guarantee, pod might get schedule
NoExecute - No pods can be scheduled, they would be evicted

---

### DaemonSets

---

[Reference Link](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

```bash
kubectl create namespace ds-demo
#OR
kubectl create ns ds-demo
# OR
k create ns ds-demo
```

**NOTE**: All the resources will also be terminated of that respective namespace

```bash
k delete ns ds-demo
```


```yml
---
apiVersion: v1
kind: Namespace
metadata:
  name: ds-demo
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-ds
  namespace: ds-demo
  labels:
    app: ds-app
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
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
      containers:
      - image: nginx:alpine
        name: nginx-container
        resources:
          requests:
            memory: 100Mi
          limits:
            memory: 200Mi
```

```yml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: httpd-ds
  namespace: ds-demo
  labels:
    app: ds-app
spec:
  selector:
    matchLabels:
      name: httpd
  template:
    metadata:
      labels:
        name: httpd
    spec:
      containers:
      - image: httpd:alpine
        name: httpd-container
        resources:
          requests:
            memory: 100Mi
          limits:
            memory: 200Mi
```

---

### Static Pods

---

```bash
sudo systemctl status kubelet.service
```

```txt
/var/lib/kubelet/config.yaml
```

[Reference Link](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/#static-pod-creation)

Difference

Who creates the pod?
Static Pods --> kubelet
Daemonset  ---> kube-api server (Daemon Set Controller)

What are the use cases?

Static Pods --> Deployed the control-plane components
DaemonSet   --> Monitoring or a logging agent, kube-proxy, networking solution

Ignored by Kube-scheduler

nodeName


---

### Multiple Scheduler

---

```bash
docker image ls | grep -i scheduler
```

```txt
k8s.gcr.io/kube-scheduler:v1.15.12
```


```yml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-scheduler
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: my-scheduler-as-kube-scheduler
subjects:
- kind: ServiceAccount
  name: my-scheduler
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: system:kube-scheduler
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: my-scheduler-as-volume-scheduler
subjects:
- kind: ServiceAccount
  name: my-scheduler
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: system:volume-scheduler
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    component: scheduler
    tier: control-plane
  name: my-scheduler
  namespace: kube-system
spec:
  selector:
    matchLabels:
      component: scheduler
      tier: control-plane
  replicas: 1
  template:
    metadata:
      labels:
        component: scheduler
        tier: control-plane
        version: second
    spec:
      serviceAccountName: my-scheduler
      containers:
      - command:
        - /usr/local/bin/kube-scheduler
        - --address=0.0.0.0
        - --leader-elect=false
        - --scheduler-name=my-scheduler
        image: k8s.gcr.io/kube-scheduler:v1.15.12
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10251
          initialDelaySeconds: 15
        name: kube-second-scheduler
        readinessProbe:
          httpGet:
            path: /healthz
            port: 10251
        resources:
          requests:
            cpu: '0.1'
        securityContext:
          privileged: false
        volumeMounts: []
      hostNetwork: false
      hostPID: false
      volumes: []
```

[Reference Link](https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/)

---

### Commands and Arguments

---

docker container run --entrypoint

ENTRYPOINT ------------> command

CMD        ------------> args


[Reference Link](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#define-a-command-and-arguments-when-you-create-a-pod)

```yml


```

---

### Multi-containers Pod

---


```yml
apiVersion: v1
kind: Pod
metadata:
  name: side-car-pod
spec:
  volumes:
  - name: shared-vol
    emptyDir: {}
  containers:
  - name: container-1
    image: alpine
    volumeMounts:
    - name: shared-vol
      mountPath: /tmp

  - name: container-2
    image: nginx:alpine
    volumeMounts:
    - name: shared-vol
      mountPath: /var/log
```

```bash
kubectl logs pod-name -c container-name
```

---

### Different Patterns for Multi-containers Pod

---

#### SideCar

---

#### Adapter

---

#### Ambassador

---