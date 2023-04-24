#1、kubeadm安装的k8s集群卸载方式

# 卸载服务
```
kubeadm reset
```
# 删除rpm包
```
rpm -qa|grep kube*|xargs rpm --nodeps -e
```
# 删除容器及镜像
```
docker images -qa|xargs docker rmi -f
```
#清理配置信息
```
rm -rf /etc/cni/net.d
rm -rf $HOME/.kube/config
rm -rf /etc/kubernetes/
rm -rf /var/lib/etcd
```

#2、二进制安装卸载方法

Kubernetes集群之清除集群
清除K8s集群的Etcd集群
操作服务器为：192.168.1.175／192.168.1.176／192.168.1.177，即etcd集群的三台服务器。以下以192.168.1.175为例子。

暂停相关服务

    sudo systemctl stop etcd
清除相关文件
# 删除 etcd 的工作目录和数据目录
    sudo rm -rf /var/lib/etcd
    
# 删除etcd.service文件

    sudo rm -rf /etc/systemd/system/etcd.service

# 删除程序文件

    sudo rm -rf /root/local/bin/etcd

# 删除TLS证书文件

    sudo rm -rf /etc/etcd/ssl/*
清除K8s集群的Master节点
操作服务器IP：192.168.1.171，即K8s-master

暂停相关服务

    sudo systemctl stop kube-apiserver kube-controller-manager kube-scheduler flanneld
清除相关文件
# 删除kube-apiserver工作目录
    sudo rm -rf /var/run/kubernetes

# 删除service文件

    sudo rm -rf /etc/systemd/system/{kube-apiserver,kube-controller-manager,kube-scheduler,flanneld}.service

# 删除程序文件

    sudo rm -rf /root/local/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,flanneld,mk-docker-opts.sh}

# 删除证书文件

    sudo rm -rf /etc/flanneld/ssl /etc/kubernetes/ssl

# 删除kubelet缓存

    sudo rm -rf ~/.kube/cache ~/.kube/schema
清除K8s集群的Node节点
操作服务器IP：192.168.1.173，即K8s-node

暂停相关服务
    sudo systemctl stop kubelet kube-proxy flanneld docker
清除相关文件
# umount kubelet 挂载的目录

    mount | grep '/var/lib/kubelet'| awk '{print $3}'|xargs sudo umount

# 删除kubelet工作目录

    sudo rm -rf /var/lib/kubelet

# 删除docker工作目录

    sudo rm -rf /var/lib/docker

# 删除flanneld写入的网络配置文件

    sudo rm -rf /var/run/flannel/

# 删除service文件
    sudo rm -rf /etc/systemd/system/{kubelet,docker,flanneld}.service
    
# 删除程序文件

    sudo rm -rf /root/local/bin/{kubelet,docker,flanneld,mk-docker-opts.sh}

# 删除证书文件

    sudo rm -rf /etc/flanneld/ssl /etc/kubernetes/ssl
清除Iptables

    sudo iptables -F && sudo iptables -X && sudo iptables -F -t nat && sudo iptables -X -t nat
清除网桥
    ip link del flannel.1
    
    ip link del docker0
