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

* SecurityContext

* TLS Certificates Basic

* Certificates API

* Kubeconfig



---

### NetworkPolicy

---



---

### Networking in Linux

---



---

### CoreDNS

---



---

### Docker Networking

---

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

```

[Reference Link](https://github.com/kubernetes/ingress-nginx)

[Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/#provider-specific-steps)

[Rewrite Example](https://kubernetes.github.io/ingress-nginx/examples/rewrite/)

[Examples](https://kubernetes.github.io/ingress-nginx/examples/)

---

