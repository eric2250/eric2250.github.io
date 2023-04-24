# nfs安装
```
yum install -y nfs-utils

mkdir -p /data/nfs
chmod 777 /data/nfs
vi /etc/exports
/data/nfs *(rw,sync,no_root_squash)

systemctl restart rpcbind &&systemctl restart nfs
systemctl enable rpcbind &&systemctl enable nfs
```