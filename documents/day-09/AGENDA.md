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

```yml
volumes:
  hostPath:
    path:
---
volumes:
  emptyDir: {}
```

* Creating PersistentVolume and PersistentVolumeClaims in Kubernetes

persistencevolume (for the entire cluster)

```txt
storageClassName
capacity
  storage
volumeMode: FileSystem | Block
accessModes:
- RWO
- RWX
- ROX
persistentVolumeReclaimPolicy: Retain | Recycle | Delete 
```

developer - persistentvolumeclaim (namespaced resource)

* Using PersistentVolumeClaim in Pod

```yml
volumes:
  persistentVolumeClaim:
    claimName: 
```

* Kubernetes Security Primitives

Who can access? Authentication

username and password through static file and token
servicaccount
certificates

What they can do? Authorization

RBAC

* Understanding API Primitives

Core Group --> api/v1

resources

pod, serviceaccount, configmap, secrets, service

actions/ verbs

Named Group -->

apps

deployment, replicasets

rbac.authorization.k8s.io

Role


* Using Role and RoleBinding



* Using ClusterRole and ClusterRoleBinding



* Using ImagePullSecrets



---

### ServiceAccount

---

a user account (used by - humans )

a service account (used by apps, machines, bots etc)


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

**NOTE**: Mountable secrets `default-token-xdvvk`

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

**NOTE**: The path  `/var/run/secrets/kubernetes.io/serviceaccount`

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

<service-name>.<namespace>.svc.cluster.local

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


1. creating a namespace --> you get a default serviceaccount
2. You can create your own serviceaccount
3. While creating your pod you specified which serviceaccount to use
4. You created a clusterrole (you gave certain actions that can be performed on your entire cluster), clusterrolebinding to link serviceaccount with that clusterrole
5. Secrets related to the serviceaccount gets mounted on a specific path 

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

**NOTE**: Capabilities works in securityContext only at the container level

---

### TLS Certificates Basic

---

What are certificates used for?

It established trust between two parties during a transaction.

Symmetric Encryption?


Public Key
*.pem 
*.crt

Private
*-key.pem
*.key

---

### Certificates API

---

1. A user first creates the key

```bash
openssl genrsa -out another-admin.key 2048
```

2. Generate a certificate signing request

```bash
openssl req -new -key another-admin.key -subj "/CN=abc-admin" -out another-admin.csr

cat another-admin.csr | base64 | tr -d "\n"
```

3. The administrator takes the content in base64 format and creates a certificate signing request object

```yml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: abc-admin
spec:
  groups:
  - system:authenticated
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1dUQ0NBVUVDQVFBd0ZERVNNQkFHQTFVRUF3d0pZV0pqTFdGa2JXbHVNSUlCSWpBTkJna3Foa2lHOXcwQgpBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF0RUdFMjJycy9pZENRS2Zrc3cycDl0dnI4dzgrYWJBMURmUll3aHpMClh1NDJBU05EUWhSUTlRTG1iL0Yxc1owRUxjTUxtWjVPRWhKVENseGRHb0lsSkUzVjhRNmNuYi81OFB0a092eCsKWG5ySFQranpzQWcxeEVtWmo0NmxlK0xpQlM2MVoxMGxmME53VWZTZGRlMWlsQWlkSjhNam4xUnU5c3lnVGF6ZQpnZzg0RkdwNU9jbU9GRDB6c21NUkRPeEFrNThWcVcwaG9UUDM1QXZMbjRUZXJidkcxSHRaTUtLc29tOCtTcFczCllQSzNpZWRvZE53ZUk1bFlFem9XcnIySXJVYU5ZZnZVRU9CcGoyQ3ZFWktNbDBMcElqMHRqTEJsOFVxVy9iT24KQml2dE1LY2RXdE5TbzdLWTY1ZHIySXRTTFpxU2ZnTlZDY1owcSsremR1OEUwd0lEQVFBQm9BQXdEUVlKS29aSQpodmNOQVFFTEJRQURnZ0VCQURMZUtNOTVrZCtiZmhjMkRsWFF2dGNrYUswVmFiR2s5azVnVGdWVDJNSStZM3JWClRjYnR6RC9LVlZzQUhBLy9EWXg0cDNIRTBDd1Z0N1NzWHF3Wmc2YjhVdks2WTg4dS83YUNIdHFtRGcycEwrZEMKS2VJeG5hKzYwRE9xVy9MWjdBQnBYV1R3TlcwQmMzY3ZUNDZ0dDZCWFBWeTQ5czhuZE1kbnk5UXNkQjlhN0dMOQpJWHF5ZHc3OGlIREhVR1d0L0d0NC9iZzMwYnU3NFNXcnRGTzlyUWl0ejBCNEo0NnFJeTZ6bUJiOHkrSWgwMU55ClMzaHlRRG9JVWNnNG95ZmJ5Qis4ZVk3dThQeVBqa3JORy9Nb1BRVGdrMmkzb2VoUEgwbXR4VElyaWFpeEkvVE0KUU9YT1RCbnRCOUh0U1FBSVkvL3ExbTZsVVpYVW5TS0kyNjcyd21NPQotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K
  usages:
  - client auth
```

---

### Kubeconfig

---



---

### NetworkPolicy

---



---
