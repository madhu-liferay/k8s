#!/bin/bash

# Join worker nodes to the Kubernetes cluster
echo "EXECUTING STEP 5 --> JOINING THE CLUSTER"
apt-get install -y -qq sshpass >/dev/null 2>&1
sshpass -p "k8sadmin" scp -o StrictHostKeyChecking=no k8smaster.example.com:/joincluster.sh /joincluster.sh >/dev/null 2>&1
bash /joincluster.sh >/dev/null 2>&1