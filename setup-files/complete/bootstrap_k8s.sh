# ---------------------------------------------------
# INITIALIZING A SINGLE CONTROL-PLANE CLUSTER
# ---------------------------------------------------
echo "EXECUTING STEP 5 --> INITIALIZING KUBERNETES CLUSTER"

# PULL THE IMAGES
kubeadm config images pull

# START THE CLUSTER >> /root/kubeinit.log 2>/dev/null
kubeadm init --apiserver-advertise-address=172.16.1.100 --pod-network-cidr=192.168.0.0/16 

# ---------------------------------------------------
# COPY THE KUBE ADMIN CONFIG TO USER DIRECTORY
# ---------------------------------------------------
echo "EXECUTING STEP 6 --> COPYING KUBE CONFIG TO USER DIRECTORY"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# ---------------------------------------------------
# DEPLOYING CNI
# ---------------------------------------------------
echo "EXECUTING STEP 7 --> DEPLOYING CALICO NETWORK"
su - vagrant -c "kubectl create -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml"

# ---------------------------------------------------
# GENERATING JOIN COMMAND
# ---------------------------------------------------
echo "EXECUTING STEP 8 --> GENERATE AND SAVE CLUSTER JOIN COMMAND"
kubeadm token create --print-join-command > /joincluster.sh

echo "================KUBERNETES CLUSTER INITIALIZATION COMPLETES================"

# ---------------------------------------------------
# ENABLING SSH PASSWORD AUTHENTICATION
# ---------------------------------------------------
echo "EXECUTING STEP 9 --> SETTING THE ROOT PASSWORD FOR SSH"
sed -i 's/^PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo -en "k8sadmin\nk8sadmin" | passwd root >/dev/null 2>&1

# Update vagrant user's bashrc file
echo "export TERM=xterm" >> /etc/bashrc