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
* InitContainers
* Get Logs of a Pod container
* Exec into a Pod container

---

### DaemonSets

---

[Reference Link](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

```yml

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

```bash
docker image ls | grep -i scheduler
```

[Reference Link](https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/)

---

### Commands and Arguments

---

[Reference Link](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#define-a-command-and-arguments-when-you-create-a-pod)

---

### Multi-containers Pod

---

### Different Patterns for Multi-containers Pod

---

#### SideCar

---

```yml

```

---

#### Adapter

---

```yml

```

---

### InitContainers

---

[Reference Link](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)



---

### Get Logs of a Pod container

---



---

### Exec into a Pod container

---
