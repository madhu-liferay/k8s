# DAY - 09

---

* ServiceAccount
* SecurityContext
* TLS Certificates Basic
* Certificates API
* Kubeconfig
* NetworkPolicy


---

* Using hostPath volume type in Pod



* Creating PersistentVolume and PersistentVolumeClaims in Kubernetes



* Using PersistentVolumeClaim in Pod



* Kubernetes Security Primitives



* Understanding API Primitives



* Using Role and RoleBinding



* Using ClusterRole and ClusterRoleBinding



* Using ImagePullSecrets



---

### ServiceAccount

---

1. To view the list of service account in the namespace use the command -

```bash
kubectl get serviceaccount 
# OR
kubectl get sa
```

2. To describe the service account listed use the command -

```bash
kubectl describe sa default
```

**NOTE**: Mountable secrets `<YOUR-MOUNTABLE-SECRET>`

3. Get the secrets in the default namespace

```bash
kubectl get secrets 
```

**NOTE**: Is it the same as mountable secrets?

4. Describe the secrets using the command

```bash
kubectl describe secret <YOUR-SECRET>
```

**NOTE**: The different data keys? 

5. Create a pod in the default namespace

```bash
kubectl run nginx-pod --image=nginx:alpine --restart=Never
```

6. Observe the mounts of the pod

```bash
kubectl describe pod nginx-pod | grep -i mounts -A 5
```

**NOTE**: The path  

7. Observe the volumes of the pod

```bash
kubectl describe pod nginx-pod | grep -i volumes -A 5
```

8. You can exec into this pod now

```bash
kubectl exec -it nginx-pod -- sh
```

9. Check out the directory content of path copied earlier and move to that directory

```bash
ls /var/run/secrets/kubernetes.io/serviceaccount
cd /var/run/secrets/kubernetes.io/serviceaccount
```

10.  Do a curl using the files in this directory

```bash
curl -k https://kubernetes.default.svc.cluster.local/version --cacert ca.crt --header "Authorization: Bearer $(cat token)" 

curl -k https://kubernetes.default.svc.cluster.local/api/v1/namespaces/default/pods --cacert ca.crt --header "Authorization: Bearer $(cat token)" 
```

**NOTE**: The default service account has no privilege

11. As a small assignment, create a new namespace say `monitoring` and check for the service accounts in this namespace, secret associated with this service account. Is it same as in the default namespace?   

12. Our goal here is to create a new service account with privilege to list the pods in all namespaces.

i. To create a service account use the command

```bash
kubectl create serviceaccount pod-list-sa -n monitoring 
```

ii. List the service account in the monitoring namespace

```bash
kubectl get serviceaccount -n monitoring 
```

iii. Create a new cluster role to list the pods in all namespaces 

```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-lister
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

iv. Create a new ClusterRoleBinding and attach it with `pod-lister` cluster role


```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: list-pods
subjects:
- kind: ServiceAccount
  name: pod-list-sa
  namespace: monitoring
roleRef:
  kind: ClusterRole 
  name: pod-lister # this must match the name of the ClusterRole you created
  apiGroup: rbac.authorization.k8s.io
```

v. Create a new pod in the monitoring namespace using

```bash
kubectl run nginx-pod --image=nginx:alpine --restart=Never --namespace monitoring
```

vi. Exec into this pod using

```bash
kubectl exec -it nginx-pod --namespace monitoring -- sh
```

vii. Move to the secrets directory using

```bash
cd /var/run/secrets/kubernetes.io/serviceaccount
```

viii. Do a curl using the files in this directory

```bash
curl -k https://kubernetes.default.svc.cluster.local/version --cacert ca.crt --header "Authorization: Bearer $(cat token)" 

curl -k https://kubernetes.default.svc.cluster.local/api/v1/namespaces/default/pods --cacert ca.crt --header "Authorization: Bearer $(cat token)" 
```

**NOTE**: This pod uses the default service account for which access is denied. 

ix. `exit` from the pod and then delete it using -

```bash
exit
kubectl delete pod nginx-pod --namespace monitoring
```

1.  Create a new nginx-pod this time using the service account

```bash
kubectl run nginx-pod --image=nginx:alpine --restart=Never --namespace monitoring --serviceaccount=pod-list-sa
```

14. Exec into this pod using

```bash
kubectl exec -it nginx-pod --namespace monitoring -- sh
```

15. Move to the secrets directory using

```bash
cd /var/run/secrets/kubernetes.io/serviceaccount
```

16. Do a curl using the files in this directory

```bash
curl -k https://kubernetes.default.svc.cluster.local/version --cacert ca.crt --header "Authorization: Bearer $(cat token)" 

curl -k https://kubernetes.default.svc.cluster.local/api/v1/namespaces/default/pods --cacert ca.crt --header "Authorization: Bearer $(cat token)" 
```

**NOTE**: This pod uses the pod-list-sa service account for which ClusterRoleBinding is already created. Hence, it displays the list of pod using the service account token. 

---

#### ServiceAccount Declaratively

---

1. Create a new pod using the below yaml configuration -

```yml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: my-alpine-pod
  name: my-alpine-pod
spec:
  containers:
  - image: khozemanullwala/kzn-alpine:ct
    imagePullPolicy: Always
    name: alpine-container
    command:
    - sleep
    - "3600"
```

2. Create a service account declaratively

```yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-docker-registry-sa
automountServiceAccountToken: false
imagePullSecrets:
- name: myregistrykey
```

```bash
kubectl explain pod.spec | grep -i automount -A 3
```

3. Modify the pod yaml configuration to use the service account for pulling images from a private source
   
```yml
...
spec:
  serviceAccount: my-docker-registry-sa
...
```

---

### SecurityContext

---



---

### TLS Certificates Basic

---



---

### Certificates API

---



---

### Kubeconfig

---



---

### NetworkPolicy

---



---
