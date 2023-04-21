
kubeadm是官方社区推出的一个用于快速部署kubernetes集群的工具。

这个工具能通过两条指令完成一个kubernetes集群的部署：

```
# 创建一个 Master 节点
$ kubeadm init

# 将一个 Node 节点加入到当前集群中
$ kubeadm join <Master节点的IP和端口 >
```

## 1. 安装要求

在开始之前，部署Kubernetes集群机器需要满足以下几个条件：

- 一台或多台机器，操作系统 CentOS7/8.x-86_x64
- 硬件配置：2GB或更多RAM，2个CPU或更多CPU，硬盘30GB或更多
- 可以访问外网，需要拉取镜像，如果服务器不能上网，需要提前下载镜像并导入节点
- 禁止swap分区

## 2. 准备环境（all）
```
| nodes  | IP             |
| ------ | ---------------|
| master | 192.168.88.80 |
| node1  | 192.168.88.81 |
| node2  | 192.168.88.82 |
```
```
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭selinux
sed -i 's/enforcing/disabled/' /etc/selinux/config  # 永久
setenforce 0  # 临时

# 关闭swap
swapoff -a  # 临时
sed -ri 's/.*swap.*/#&/' /etc/fstab    # 永久

# 根据规划设置主机名
hostnamectl set-hostname <hostname>

# 在master添加hosts
cat >> /etc/hosts << EOF
192.168.88.80 master
192.168.88.81 node1
192.168.88.82 node2
EOF
cat /etc/hosts

# 将桥接的IPv4流量传递到iptables的链
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system  # 生效

# 时间同步
yum install ntpdate -y
ntpdate time.windows.com
crontab -e
* */1 * * * ntpdate ntp.aliyun.com >/dev/null
crontab -l
# 时区设置
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

## 3. 所有节点安装Docker/kubeadm/kubelet（all）
```
Kubernetes默认CRI（容器运行时）为Docker，因此先安装Docker。
CentOS7.x系统自带的3.10.x内核存在一些Bug，Docker运行不稳定，建议升级内核

#下载内核源
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
# 安装最新版本内核
yum --enablerepo=elrepo-kernel install -y kernel-lt
# 查看可用内核
cat /boot/grub2/grub.cfg |grep menuentry
# 设置开机从新内核启动
grub2-set-default "CentOS Linux (5.4.142-1.el7.elrepo.x86_64) 7 (Core)"
# 查看内核启动项
grub2-editenv list
# 重启系统使内核生效
reboot
# 查看内核版本是否生效
uname -r
```

### 3.1 安装Docker（all）

```
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
yum -y install docker-ce-18.06.1.ce-3.el7
systemctl enable docker && systemctl start docker &&systemctl status docker
docker --version
Docker version 18.06.1-ce, build e68fc7a
```

```
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": ["https://kzjowymh.mirror.aliyuncs.com"],
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```
```
systemctl daemon-reload
systemctl restart docker &&systemctl status docker
```

```
- 报错：The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get "http://localhost:10248/healthz": dial tcp [::1]:10248: connect: connection refused
在/etc/docker/daemon.json添加
"exec-opts": ["native.cgroupdriver=systemd"]
```
### 3.2 添加阿里云YUM软件源（all）

```
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

### 3.3 安装kubeadm，kubelet和kubectl（all）

由于版本更新频繁，这里指定版本号部署：

```
$ yum install -y kubelet-1.23.8 kubeadm-1.23.8 kubectl-1.23.8
  yum install -y kubelet kubeadm kubectl
$ systemctl enable kubelet
```

## 4. 部署Kubernetes Master

在192.168.88.80（Master）执行。

```
$ kubeadm init \
  --apiserver-advertise-address=192.168.88.11 \
  --image-repository registry.aliyuncs.com/google_containers \
  --service-cidr=10.96.0.0/12
  --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=all \
  --kubernetes-version v1.23.8
```

由于默认拉取镜像地址k8s.gcr.io国内无法访问，这里指定阿里云镜像仓库地址。

配置环境变量使用kubectl工具：

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
$ kubectl get nodes
```
配置别名.
```
alias ka="kubectl apply "
alias kc="kubectl create "
alias kd="kubectl delete "
alias ke="kubectl exec -it "
alias kg="kubectl get "
alias kr="kubectl replace -f "
alias kl="kubectl logs "

alias di="docker images "
alias dri="docker rmi "
alias drm="docker rm "
alias dst="docker start "
alias dsd="docker stop "
```
给node节点复制一份：
```
scp -r .kube/ 192.168.88.81:~
scp -r .kube/ 192.168.88.82:~

```
##k8s 节点调度
```
1 查看节点调度情况
kubectl describe node|grep -E "Name:|Taints:"
Name:               master1
Taints:             node-role.kubernetes.io/master:NoSchedule
Name:               master2
Taints:             node-role.kubernetes.io/master:NoSchedule
Name:               master3
Taints:             node-role.kubernetes.io/master:NoSchedule

2 指定节点允许调度
kubectl taint node master1 master2 master3 node-role.kubernetes.io/master-

3 设置所有节点都可调度（去除所有节点不可调度的标签）：
kubectl taint nodes --all node-role.kubernetes.io/master-
4 设置指定节点不可调度：

kubectl taint node master1 node-role.kubernetes.io/master=:NoSchedule

````
## 5. 加入Kubernetes Node

在192.168.88.181/182（Node）执行。

向集群添加新节点，执行在kubeadm init输出的kubeadm join命令：


```
$ kubeadm join 192.168.88.180:6443 --token i0g3rj.kbblpr5fjznome9b \
    --discovery-token-ca-cert-hash sha256:cc09d0cb2e03935d574340a7b51bffaffb0ed3c9b57867dd70aa6743667947b4
```

默认token有效期为24小时，当过期之后，该token就不可用了。这时就需要重新创建token，操作如下：

```
kubeadm token create --print-join-command
```
```
当你的token忘了或者过期，解决办法如下：

1.先获取token

#如果过期可先执行此命令
kubeadm token create #重新生成token
#列出token
kubeadm token list | awk -F" " '{print $1}' |tail -n 1
2.获取CA公钥的哈希值

openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^ .* //'
3.从节点加入集群

kubeadm join 192.168.88.180:6443 --token token填这里 --discovery-token-ca-cert-hash sha256:哈希值填这里


```

## 6. 部署CNI网络插件（Master）

```
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

默认镜像地址无法访问，sed命令修改为docker hub镜像仓库。

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
手动下载文件并导入(迅雷下载)：
```
https://github.com/flannel-io/flannel/releases/flanneld-v0.14.0-amd64.docker
https://github.com/caoran/kube-flannel.yml/blob/master/kube-flannel.yml
```
```
docker load < flanneld-v0.14.0-amd64.docker

kubectl apply -f kube-flannel.yml

kubectl get pods -n kube-system
NAME                          READY   STATUS    RESTARTS   AGE
kube-flannel-ds-amd64-2pc95   1/1     Running   0          72s
```

## 7. 测试kubernetes集群（Master）

在Kubernetes集群中创建一个pod，验证是否正常运行：

```
$ kubectl create deployment nginx --image=nginx
$ kubectl expose deployment nginx --port=80 --type=NodePort
$ kubectl get pod,svc
```

访问地址：http://NodeIP:Port  



## 8. 安装Dashboard
配置hosts
``` 
192.30.253.112 github.com 
192.30.253.119 gist.github.com 
151.101.100.133 assets-cdn.github.com 
151.101.100.133 raw.githubusercontent.com 
151.101.100.133 gist.githubusercontent.com 
151.101.100.133 cloud.githubusercontent.com 
151.101.100.133 camo.githubusercontent.com 
151.101.100.133 avatars0.githubusercontent.com 
151.101.100.133 avatars1.githubusercontent.com 
151.101.100.133 avatars2.githubusercontent.com 
151.101.100.133 avatars3.githubusercontent.com 
151.101.100.133 avatars4.githubusercontent.com 
151.101.100.133 avatars5.githubusercontent.com 
151.101.100.133 avatars6.githubusercontent.com 
151.101.100.133 avatars7.githubusercontent.com 
151.101.100.133 avatars8.githubusercontent.com 
```
### 1.下载recommended.yaml
https://kubernetes.io/zh-cn/docs/tasks/access-application-cluster/web-ui-dashboard/
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
```
### 2.修改recommended.yaml
将命名空间改为默认的kube-system (可以不做)
```
sed -i '/namespace/ s/kubernetes-dashboard/kube-system/g' recommended.yaml
```
vim recommended.yaml
添加40行和44行的内容
```
type: NodePort
nodePort: 30001
```
如：
```
 39 spec:
 40   type: NodePort
 41   ports:
 42     - port: 443
 43       targetPort: 8443
 44       nodePort: 30001
 45   selector:
 46     k8s-app: kubernetes-dashboard
 47 

 ---
```

### 3.启动kubernetes-dashboard
```
kubectl apply -f recommended.yaml
kubectl get pods,svc -n kube-system
NAME                                              READY   STATUS    RESTARTS   AGE
pod/coredns-7ff77c879f-6fwch                      1/1     Running   1          20h
pod/coredns-7ff77c879f-z6fj5                      1/1     Running   1          20h
pod/etcd-k8s-master                               1/1     Running   1          20h
pod/kube-apiserver-k8s-master                     1/1     Running   1          20h
pod/kube-controller-manager-k8s-master            1/1     Running   2          20h
pod/kube-flannel-ds-amd64-5fzqt                   1/1     Running   1          20h
pod/kube-flannel-ds-amd64-m9c2x                   1/1     Running   1          20h
pod/kube-flannel-ds-amd64-sdgfw                   1/1     Running   1          20h
pod/kube-proxy-2pzdr                              1/1     Running   1          20h
pod/kube-proxy-5pbrv                              1/1     Running   1          20h
pod/kube-proxy-jq9fs                              1/1     Running   1          20h
pod/kube-scheduler-k8s-master                     1/1     Running   2          20h
pod/kubernetes-dashboard-556cdb78cd-r5rhq         1/1     Running   0          2m39s
pod/kubernetes-metrics-scraper-86f6785867-r4q5k   1/1     Running   0          2m39s

NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
service/dashboard-metrics-scraper   ClusterIP   10.111.238.77    <none>        8000/TCP                 2m39s
service/kube-dns                    ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   20h
service/kubernetes-dashboard        NodePort    10.106.244.109   <none>        443:30001/TCP            2m40s


```

### 4.使用token访问，创建SA并绑定默认cluster-admin管理员集群角色
创建管理员用户
```
kubectl create serviceaccount dashboard-admin -n kube-system
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
```
获取token值

kubectl get secret -n kube-system |grep dashboard-admin		#查找管理员用户的token名字
```
# kubectl get secret -n kube-system |grep dashboard-admin
dashboard-admin-token-g5ktl                      kubernetes.io/service-account-token   3      26s
```
查看token内容

```
#kubectl describe secret $(kubectl get secret -n kube-system |grep dashboard-admin|awk '{print$1}') -n kube-system
Name:         dashboard-admin-token-g5ktl
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: dashboard-admin
              kubernetes.io/service-account.uid: 5ce623cd-4785-429e-9780-e6fb1ad8e001

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IjVsNTBVbzBzUDVjRVhXTVVqWm41RmZEczlYTmdSdU1JWGFEZnl5NjBVVnMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkYXNoYm9hcmQtYWRtaW4tdG9rZW4tZzVrdGwiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGFzaGJvYXJkLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNWNlNjIzY2QtNDc4NS00MjllLTk3ODAtZTZmYjFhZDhlMDAxIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmRhc2hib2FyZC1hZG1pbiJ9.qIAsYtarO2mV6c4zR2IMinWuw2gT20ipLi9pGBVrU7euLV8zkE014g-H0FC3zxqs6Uirj7WJ_pbNr4FIrqiTrgdl-pprQ5LaAp16m1I19QI0CTWbz1MhaJmg761JTqLvU8uo1EfyWtv8VQOndej3FTqLxCiSSRkI2qGVFOUp8SRiC3vn5aVb-aoC94F_1SoO0qH5RZPn9Jx0cm5waxucZnOK5W4bqfwpuTSASUlqYjW2aVR-TAnhk622P5iKiYPEjv8aywxFABeCu9SgkQferpqr9nQ63cXrPvrvkmQbJehQRUVwtU8qtISa50bjfPzoP8YNlUsR6ak4rn0AlyOQvQ
[root@k8s-master yaml]# 
```
### 5.访问kubernetes-dashboard
https://192.168.88.180:30001

选择token 输入刚才获取的token值