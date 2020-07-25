# DAY 01

## **Working with etcd**

---

1. Download the etcd by using the below command -

```bash
ETCD_VERSION=3.4.10
wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
```
2. Unzip the compressed binaries
 
```bash
tar xvf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
```

3. Move the files into the `/usr/local/bin` using command -

```bash
sudo mv etcd-v${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin
```

4. View the page for etcdctl help using command -

```bash
ETCDCTL_API=3 etcdctl --help
```

5. To view all the keys from the etcd distributed data store use the command -

```bash
sudo ETCDCTL_API=3 etcdctl get / --prefix --keys-only \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

6. To add a new key to the etcd distributed data store use the command -

```bash
sudo ETCDCTL_API=3 etcdctl put firstname khozema \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

7. To get a value of key from the etcd distributed data store use the command -

```bash
sudo ETCDCTL_API=3 etcdctl get firstname \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

8. To delete the key from the etcd distributed data store use the command -

```bash
sudo ETCDCTL_API=3 etcdctl del firstname \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

9. To back up the entire etcd datastore use the command -

```bash
sudo ETCDCTL_API=3 etcdctl snapshot save snapshot.db \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt
```

10. As per the documentation you can also save `member/snap/db` file from the etcd data directory which is `/var/lib/etcd` for default installation of kubeadm.

```bash
sudo cat /etc/kubernetes/manifests/etcd.yaml | grep data-dir
sudo cp /var/lib/etcd/member/snap/db another-snapshot.db
```

11. To verify the status of snapshot use the command -

```bash
sudo ETCDCTL_API=3 etcdctl snapshot status snapshot.db -w=table
```

12. Zip up the content of the `etcd` directory for restoring the datastore from back up in case of server failure 

```bash
sudo tar -zcvf etcd.tar.gz /etc/kubernetes/pki/etcd
```
