# DAY - 10

---

* NetworkPolicy
* Networking in Linux
* CoreDNS
* Docker Networking
* CNI
* Ingress Controllers

---

## RECAP

---

* ServiceAccount

Apps, third-party, bots etc... (non-humans)

namespace

ClusterRole, ClusterRoleBinding

```yml
spec:
  serviceAccount: <your-service-account-name>
```

* SecurityContext

```yml
spec:
  securityContext:

  containers:
  - image: 
    name:
    securityContext:
      capabilities:
        add:
        - 
        drop
        -
      privileged: false (default)
      readOnlyRootFilesystem:
```

* TLS Certificates Basic

trust between two parties during a transaction

Symmetric Encryption
Asymmetric Encryption

1. Root certificates ---> Root Server (Certificate Authority --> master)
2. Server Certificates --> apiserver, etcd, kubelet
3. Client Certificates --> apiserver, kubelet, kubeproxy, controller, scheduler

* Certificates API

```txt
CertificateSigningRequest

request: 

```

**NOTE**: base64 encoded format

.crt

```bash
kubectl certificate approve <csr-name>
```

* Kubeconfig

1. Clusters --> server, name, certificate-authority details
2. Contexts --> tie up your user with the cluster
3. Users --> client-key, client-certificate, name

```bash
kubectl config set-context --current --namespace=development
kubectl config set-context --current --namespace=default
```

---

### NetworkPolicy

---

```yml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

```yml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: bb2-bb1
  namespace: default
spec:
  podSelector: {}
  ingress:
  - from:
    - podSelector:
        matchLabels:
          test: out # label set on bb2
  egress:
  - to:
    - podSelector:
        matchLabels:
          test: in # label set on bb1
  policyTypes:
  - Ingress
  - Egress
```

```bash
kubectl label pod busybox1 test=in
kubectl label pod busybox2 test=out
```

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: bb1-to-bb2
  namespace: default
spec:
  podSelector: {}
  ingress:
  - from:
    - podSelector:
        matchLabels:
          test: in
  egress:
  - to:
    - podSelector:
        matchLabels:
          test: out
  policyTypes:
  - Ingress
  - Egress
```

---

### Networking in Linux

---



---

### CoreDNS

---

kube-dns ---> 10.96.0.10

CoreDNS

192.168.141.37, 
192.168.141.38, 

kubernetes --> 10.96.0.1

```bash
kubectl run busybox-pod --image=busybox:1.28.4
```

Services IPTables

```bash
sudo iptables-save | grep KUBE | grep nginx-svc
```

---

### Docker Networking

---
8 --->

172.17.0.1/16

 veth31176b0@if16

 eth0@if17 ---> 172.17.0.2/16


1. Create Network Namespace

2. Create Bridge Network/Interface

3. Create vEth Pairs (Pipe, Virtual Cable)

4. Attach vEth to Namespace

5. Attach Other vEth to Bridge

6. Assign IP Address

7. Bring the interfaces up

8. Enable NAT -IP Masquerade

---

### CNI

---

* Container Runtime must create network namespace
* Identify network the container must attach to
* Container Runtime to invoke network plugin (bridge) when container is added / deleted
* JSON format of the Network Configuration

* Must Support command line arguments add/del/check
* Must support parameters container id, network ns etc
* Must Manage IP address assignments to PODs
* Must Return results in a specific format

```bash
ps -aux | grep kubelet
sudo ls -al /opt/cni/bin
sudo ls /etc/cni/net.d/ 
```

---

### Ingress Controllers

---

1. Apply the below configuration as mentioned in the documentation

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/baremetal/deploy.yaml
```

2. To check if the ingress controller pods have started, run the following command:

```bash
kubectl get pods -n ingress-nginx \
  -l app.kubernetes.io/name=ingress-nginx --watch
```

3. Create some pods that is served by service

```yml
kind: Pod
apiVersion: v1
metadata:
  name: simbaa-app
  labels:
    app: simbaa
spec:
  containers:
    - name: simbaa-app
      image: hashicorp/http-echo
      args:
        - "-text=simbaa"
---
kind: Service
apiVersion: v1
metadata:
  name: simbaa-service
spec:
  selector:
    app: simbaa
  ports:
    - port: 5678
```

4. Check if you are able to access it through the service

5. Similarly, create other pods that is served by service

```yml
kind: Pod
apiVersion: v1
metadata:
  name: timon-app
  labels:
    app: timon
spec:
  containers:
    - name: timon-app
      image: hashicorp/http-echo
      args:
        - "-text=timon"
---
kind: Pod
apiVersion: v1
metadata:
  name: pumbaa-app
  labels:
    app: pumbaa
spec:
  containers:
    - name: pumbaa-app
      image: hashicorp/http-echo
      args:
        - "-text=pumbaa"
---
kind: Service
apiVersion: v1
metadata:
  name: timon-service
spec:
  selector:
    app: timon
  ports:
    - port: 5678
---
kind: Service
apiVersion: v1
metadata:
  name: pumbaa-service
spec:
  selector:
    app: pumbaa
  ports:
    - port: 5678
```

6. Create the Ingress object 

```yml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: lion-king-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /simbaa
        backend:
          serviceName: simbaa-service
          servicePort: 5678
      - path: /timon
        backend:
          serviceName: timon-service
          servicePort: 5678
      - path: /pumbaa
        backend:
          serviceName: pumbaa-service
          servicePort: 5678
```
rules--> http --> paths --> path


```txt
What you want is?
http://ingress-service:ingress-service-port/simbaa ---> http://simbaa-service:service-port
http://ingress-service:ingress-service-port/timon  -->  http://timon-service:service-port
http://ingress-service:ingress-service-port/pumbaa -->  http://pumbaa-service:service-port

Withour re-write target

http://ingress-service:ingress-service-port/simbaa ---> http://simbaa-service:service-port/simbaa
http://ingress-service:ingress-service-port/timon  -->  http://timon-service:service-port/timon
http://ingress-service:ingress-service-port/pumbaa -->  http://pumbaa-service:service-port/pumbaa
```

[Reference Link](https://github.com/kubernetes/ingress-nginx)

[Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/#provider-specific-steps)

[Rewrite Example](https://kubernetes.github.io/ingress-nginx/examples/rewrite/)

[Examples](https://kubernetes.github.io/ingress-nginx/examples/)

---

Create a namespace called 'mynamespace' and a pod with image nginx called nginx on this namespace

kubectl create ns mynamespace
kubectl run nginx --image=nginx --namespace=mynamespace