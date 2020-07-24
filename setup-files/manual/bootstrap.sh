#! /bin/bash

# ---------------------------------------------------
# UPDATING HOST FILE
# ---------------------------------------------------
echo "================HOST AND CONTAINER RUNTIME SET UP STARTS================"
echo "EXECUTING STEP 1 --> /etc/hosts FILE UPDATION"
cat >>/etc/hosts<<EOF
172.16.1.200 kubemaster.example.com kubemaster
172.16.1.201 kubeminion1.example.com kubeminion1
172.16.1.202 kubeminion2.example.com kubeminion2
EOF