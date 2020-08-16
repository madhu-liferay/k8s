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



---

### Understanding Storage

---

[Container Storage Interface](https://github.com/container-storage-interface/spec)

---

### Using hostPath volume type in Pod

---

```yml

```

---

### Creating PersistentVolume and PersistentVolumeClaims in Kubernetes

---

Creating PersistentVolume object

```yml


```

Creating PersistentVolumeClaim object

```yml

```


---

### Using PersistentVolumeClaim in Pod

---

```yml

```

Complete code to deploy a MySQL server with persistent volumes and claims

```yml

```

---

### Kubernetes Security Primitives

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

```

```yml

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
kubectl create secret docker-registry myregistrykey --docker-server=DUMMY_SERVER \
        --docker-username=DUMMY_USERNAME --docker-password=DUMMY_DOCKER_PASSWORD \
        --docker-email=DUMMY_DOCKER_EMAIL
```
