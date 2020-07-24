#! /bin/bash

# ---------------------------------------------------
# UPDATING HOST FILE
# ---------------------------------------------------
echo "================HOST AND CONTAINER RUNTIME SET UP STARTS================"
echo "EXECUTING STEP 1 --> /etc/hosts FILE UPDATION"
cat >>/etc/hosts<<EOF
172.16.1.100 k8smaster.example.com k8smaster
172.16.1.101 k8sminion1.example.com k8sminion1
172.16.1.102 k8sminion2.example.com k8sminion2
EOF

# ---------------------------------------------------
# ADDING PACKAGES, REPOSITORY TO INSTALL DOCKER
# ---------------------------------------------------
echo "EXECUTING STEP 2 --> DOCKER INSTALLATION (WAIT FOR FEW MINUTES)"

# UPDATE THE PACKAGE MANAGER AND INSTALL NECESSARY PACKAGES
apt-get update -y -qq && apt-get install -y -qq apt-transport-https ca-certificates curl software-properties-common >/dev/null 2>&1

# ADD DOCKER'S OFFICIAL GPG KEYS
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# ADD DOCKER REPOSITORY
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# INSTALL DOCKER CE
apt-get update -y -qq && apt-get install -y -qq containerd.io docker-ce docker-ce-cli >/dev/null 2>&1 

# DAEMON SETUP
cat >>/etc/docker/daemon.json<<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# RESTART DOCKER
systemctl daemon-reload >/dev/null 2>&1
systemctl enable docker >/dev/null 2>&1
systemctl restart docker >/dev/null 2>&1

# RUNNING DOCKER WITHOUT SUDO
usermod -aG docker vagrant >/dev/null 2>&1

# ---------------------------------------------------
# LETTING IPTABLES SEE BRIDGED TRAFFIC
# ---------------------------------------------------
echo "EXECUTING STEP 3 --> ADDING SYSCTL SETTINGS"
cat >>/etc/sysctl.d/k8s.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1
echo "================HOST AND CONTAINER RUNTIME SET UP COMPLETES================"

# ---------------------------------------------------
# INSTALLING KUBERNETES PACKAGES
# ---------------------------------------------------
echo "================KUBERNETES INSTALLATION STARTS================"
echo "EXECUTING STEP 4 --> INSTALLING KUBERNETES (WAIT FOR FEW MINUTES)"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat >>/etc/apt/sources.list.d/kubernetes.list<<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update -y -qq && apt-get install -y -qq kubelet kubeadm kubectl >/dev/null 2>&1
echo "================KUBERNETES INSTALLATION COMPLETES================"
