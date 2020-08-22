# DAY 08

## AGENDA

---

* Using hostPath volume type in Pod
* Creating PersistentVolume and PersistentVolumeClaims in Kubernetes
* Using PersistentVolumeClaim in Pod
* Kubernetes Security Primitives
* Understanding API Primitives
* Using Role and RoleBinding
* Using ClusterRole and ClusterRoleBinding
* Understanding and Using ServiceAccounts
* Using ImagePullSecrets


---

### RECAP

---

Disadvantage of Metric Server -

top pods
    nodes

autoscale --cpu-percent --min=number --max=number

hpa

--pod-eviction-timeout


kube-apiserver X
controller and scheduler - X, X-1
kubelet, kube-proxy - X-2, X-1, X
kubectl X+1, X , X-1

drain ---> cordon (makes your nodes unschedulable) (evict)
kubectl drain --help
--ignore-daemonsets

uncordon --> (makes your node again schedulable)

----------------------------------------

Storage Driver (manage the layered architecture

Volume Plug-ins (manage the storage solution (volumes))

--------------------------------

Bind Mounting (path based)
Volume Mounting (docker manage storage area)


Administrator ----> PersistentVolume
S, M, L
storageClassName --- local (user-defined)
capacity
	storage: 5Gi
volumeMode - FileSystem | Block
accessModes

ReadWriteOnce (RWO) ---> with only one node
ReadWriteMany (RWX) ---> can be attach with many nodes
ReadOnlyMany  (ROX) ---> read only by many nodes


Developer -----> PersistentVolumeClaim

storageClassName: local
resources:
	requests:
		storage: 3Gi


SuperSecret!

---

### Understanding Storage

---

[Container Storage Interface](https://github.com/container-storage-interface/spec)

---

### Using hostPath volume type in Pod

---

```yml
apiVersion: v1
kind: Pod
metadata:
  name: number-generator-pod
spec:
  nodeName: kslave1
  restartPolicy: Never
  containers:
  - image: alpine
    name: number-generator-container
    command: ["/bin/sh", "-c"]
    args: ["shuf -i 0-100 -n 1 >> /opt/num.txt"]
    volumeMounts:
    - mountPath: /opt
      name: my-vol
  volumes:
  - name: my-vol
    hostPath:
      path: /k8s/data
```

---

### Creating PersistentVolume and PersistentVolumeClaims in Kubernetes

---

Creating PersistentVolume object

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 8Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local
  hostPath:
    path: /mnt/db-data
```

Creating PersistentVolumeClaim object

```yml
apiVersion: v1
kind: Namespace
metadata:
  name: db
---
apiVersion: v1

kind: PersistentVolumeClaim

metadata:

  name: mysql-pvc
  namespace: db

spec:
  
  accessModes:

  - ReadWriteOnce


  storageClassName: local

  resources:
    requests:
      storage: 6Gi
```


---

### Using PersistentVolumeClaim in Pod

---

```yml

```

Complete code to deploy a MySQL server with persistent volumes and claims

```yml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: db
data:
  pass: U3VwZXJTZWNyZXQh
---
apiVersion: v1
kind: Pod
metadata:
  name: mysql-pod
  namespace: db
spec:
  nodeName: kslave2
  containers:
  - image: mysql
    name: mysql-container
    env:
    - name: MYSQL_ROOT_PASSWORD
      valueFrom:
        secretKeyRef: 
          key: pass
          name: mysql-secret
    volumeMounts:
    - mountPath: /var/lib/mysql
      name: db-vol
  volumes:
  - name: db-vol
    persistentVolumeClaim: 
      claimName: mysql-pvc
```

```bash
kubectl exec mysql-pod -n db -it -- bash

# connect to mysql server

mysql -u root -p


create database simplilearn;

use simplilearn;

create table faculty (id int, fullname varchar(50));

insert into faculty values (1, 'Khozema');
select * from faculty;


exit

exit
```

```bash
kubectl get pvc mysql-pvc -n db -o yaml > QX.yml
```


---

### Kubernetes Security Primitives

---

Nodes are secure

disable root access
disable password
ssh keys to gain access


Authentication - Who can access the cluster?

Authorization - What they can do?

Authentication

1. Authentication User ids and password, token (humans)
2. certificates
3. third party like ldap
4. service account (other apps/system/bot)


kubectl create user user1 (static )

kubectl create serviceaccount default

Authorization

RBAC (Role Based Access Control)
ABAC 
Node Authorizers
Webhooks

---

### Authentication - different ways with example

1. Try to access the version of kubernetes apiserver by using curl

```bash
curl -k -v https://localhost:6443/version
```

2. Try to get the list of pods by using curl

```bash
curl -k -v https://localhost:6443/api/v1/pods
```

3. You can try by opening up a proxy and run the above command once again this time using the port number `8001`

```bash
kubectl proxy

curl http://localhost:8001/api/v1/pods

# Similary we can see the different resources of respective apis
curl http://localhost:8001/api/v1 | grep -i '"name":'
curl http://localhost:8001/apis | grep '"name":'
curl http://localhost:8001/apis
```

[Reference Link](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/)

4. Create a new directory say `/k8s/auth` using

```bash
sudo su -
mkdir -p /k8s/auth
```

5. Add a new csv file to this directory say `auth.csv`

```bash
echo -n "secret123,user1,u01" > /k8s/auth/auth.csv
```

6. Open the `/etc/kubernetes/manifests/kube-apiserver.yaml`

```bash
vim /etc/kubernetes/manifests/kube-apiserver.yaml
```

```yml
  command:
  - --basic-auth-file=/auth/auth.csv

  volumeMounts:
  ...
  - mountPath: /auth
    name: basic-auth
    readOnly: true
...
volumes:
...
- hostPath: 
    path: /k8s/auth
  name: basic-auth

```

7. Try using the curl and you get 401 error

```bash
curl -k -v -u "user1:secret123" https://localhost:6443/api/v1/pods
```

8. For listing the pods we will create a new role say `pod-viewer` in a `pod-viewer-role.yml` file

```bash
vim pod-viewer-role.yml
```

```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-viewer-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```


9. Apply the role created using

```bash
kubectl apply -f pod-viewer-role.yml
```

10. To view the existing roles in the namespace use

```bash
kuebctl get roles
```

11. To describe a specific role use

```bash
kubectl describe role pod-viewer-role
```

12. The next step is to link this role with a user, in our case it is the `user1`. For this create a new `pod-viewer-rolebinding.yml` file

```bash
vim pod-viewer-rolebinding.yml
```

```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-viewer-rolebinding
  namespace: default
subjects:
- kind: User
  name: user1
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-viewer-role
  apiGroup: rbac.authorization.k8s.io
```

13. Apply the role-binding created using

```bash
kubectl apply -f pod-viewer-rolebinding.yml
```

14. To view the existing roles in the namespace use

```bash
kubectl get rolebindings
```

15. To describe a specific role use

```bash
kubectl describe rolebinding pod-viewer-rolebinding
``` 

16. Try to curl and get the list of pod by using the 

```bash
curl -k -v -u "user1:secret123" https://localhost:6443/api/v1/pods
```

17. Do another curl this time specifying the namespace 

```bash
curl -k -v -u "user1:secret123" https://localhost:6443/api/v1/namespaces/default/pods
```

18. To check the actions the user can perform on the cluster you can use the `auth can-i` command now

```bash
kubectl auth can-i get pods --as user1
kubectl auth can-i list pods --as user1
kubectl auth can-i list pods --as user1 --namespace kube-system
kubectl auth can-i list pods --as user1 --namespace kube-system
kubectl auth can-i create pods --as user1
```

---

### Understanding API Primitives

---



---

### Using Role and RoleBinding

---

```yml

```

```yml

```

---

### Using ClusterRole and ClusterRoleBinding

---

```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pv-role
rules:
- apiGroups: [""]
  resources: ["persistentvolumes"]
  verbs: ["create", "list", "delete"]
```

```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pv-clusterrolebinding
subjects:
- kind: User
  name: user1
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pv-clusterrole
  apiGroup: rbac.authorization.k8s.io
```

```txt
--header "Authorization: Bearer <TOKEN>"
```

---

### Understanding and Using ServiceAccounts

---

```bash

```

```yml

```

[Reference Link](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

---

### Using ImagePullSecrets

---

```bash
kubectl run alpine-demo --image=khozemanullwala/kzn-alpine:ct --dry-run --restart=Never -o yaml > alpine-pod.yml
```


```bash
kubectl create secret docker-registry myregistrykey --docker-server=DUMMY_SERVER \
        --docker-username=DUMMY_USERNAME --docker-password=DUMMY_DOCKER_PASSWORD \
        --docker-email=DUMMY_DOCKER_EMAIL
```

```yml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: alpine-demo
  name: alpine-demo
spec:
  imagePullSecrets:
  - name: myregistrykey
  containers:
  - image: khozemanullwala/kzn-alpine:ct
    name: alpine-demo
    command:
    - sleep
    - "3600"
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```


