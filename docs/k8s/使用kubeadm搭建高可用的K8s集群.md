
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

- 一台或多台机器，操作系统 CentOS7.x-86_x64
- 硬件配置：2GB或更多RAM，2个CPU或更多CPU，硬盘30GB或更多
- 可以访问外网，需要拉取镜像，如果服务器不能上网，需要提前下载镜像并导入节点
- 禁止swap分区

## 2. 准备环境
```

| role          | IP             |
| ------------- | -------------- |
| master1       | 192.168.88.180 |
| master2       | 192.168.88.183 |
| node1         | 192.168.88.181 |
| node2         | 192.168.88.182 |
| VIP           | 192.168.88.188 |
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
sed -i '/88/d' /etc/hosts
cat >> /etc/hosts << EOF
192.168.88.188    master.k8s.io   k8s-vip
192.168.88.180    master01.k8s.io k8s-master1
192.168.88.181    master02.k8s.io k8s-master2
192.168.88.182    node01.k8s.io   k8s-node1
192.168.88.183    node01.k8s.io   k8s-node2
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
yum install net-tools wget  -y
ntpdate time.windows.com
```



## 3. 所有master节点部署keepalived

### 3.1 安装相关包和keepalived

```
yum install -y conntrack-tools libseccomp libtool-ltdl keepalived

yum install -y keepalived
```

### 3.2配置master节点

master1节点配置

```
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.old
cat > /etc/keepalived/keepalived.conf <<EOF 
! Configuration File for keepalived

global_defs {
   router_id k8s
}

vrrp_script check_haproxy {
    script "killall -0 haproxy"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state MASTER 
    interface eth0 
    virtual_router_id 51
    priority 250
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass ceb1b3ec013d66163d6ab
    }
    virtual_ipaddress {
        192.168.88.188
    }
    track_script {
        check_haproxy
    }

}
EOF
```

master2节点配置

```
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.old
cat > /etc/keepalived/keepalived.conf <<EOF 
! Configuration File for keepalived

global_defs {
   router_id k8s
}

vrrp_script check_haproxy {
    script "killall -0 haproxy"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state BACKUP 
    interface eth0 
    virtual_router_id 51
    priority 200
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass ceb1b3ec013d66163d6ab
    }
    virtual_ipaddress {
        192.168.88.188
    }
    track_script {
        check_haproxy
    }

}
EOF
```

### 3.3 启动和检查

在两台master节点都执行

```
# 启动keepalived
$ systemctl start keepalived.service
设置开机启动
$ systemctl enable keepalived.service
# 查看启动状态
$ systemctl status keepalived.service
```

启动后查看master1的网卡信息

```
ip a s eth0
```



## 4. 部署haproxy

### 4.1 安装

```
yum install -y haproxy
```

### 4.2 配置

两台master节点的配置均相同，配置中声明了后端代理的两个master节点服务器，指定了haproxy运行的端口为16443等，因此16443端口为集群的入口

```
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.old
cat > /etc/haproxy/haproxy.cfg << EOF
`
       #---------------------------------------------------------------------
 # Global settings
       #---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2
    
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon 
       
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------  
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
#---------------------------------------------------------------------
# kubernetes apiserver frontend which proxys to the backends
#--------------------------------------------------------------------- 
frontend kubernetes-apiserver
    mode                 tcp
    bind                 *:16443
    option               tcplog
    default_backend      kubernetes-apiserver    
#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend kubernetes-apiserver
    mode        tcp
    balance     roundrobin
    server      master01.k8s.io   192.168.88.180:6443 check
    server      master02.k8s.io   192.168.88.181:6443 check
#---------------------------------------------------------------------
# collection haproxy statistics message
#---------------------------------------------------------------------
listen stats
    bind                 *:1080
    stats auth           admin:awesomePassword
    stats refresh        5s
    stats realm          HAProxy\ Statistics
    stats uri            /admin?stats
EOF`

```

### 4.3 启动和检查

两台master都启动

```
# 设置开机启动
$ systemctl enable haproxy
# 开启haproxy
$ systemctl start haproxy
# 查看启动状态
$ systemctl status haproxy
```

检查端口

```
netstat -lntup|grep haproxy

```



## 5. 所有节点安装Docker/kubeadm/kubelet

Kubernetes默认CRI（容器运行时）为Docker，因此先安装Docker。

### 5.1 安装Docker

```
$ wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
$ yum -y install docker-ce-18.06.1.ce-3.el7
$ systemctl enable docker && systemctl start docker
$ docker --version
Docker version 18.06.1-ce, build e68fc7a
```

```
$ cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://b9pmyelo.mirror.aliyuncs.com"]
}
EOF

---

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "registry-mirrors": ["https://0gbs116j.mirror.aliyuncs.com","https://registry.docker-cn.com","https://mirror.ccs.tencentyun.com","https://docker.mirrors.ustc.edu.cn"],
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

```

### 5.2 添加阿里云YUM软件源

```
$ cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

### 5.3 安装kubeadm，kubelet和kubectl

由于版本更新频繁，这里指定版本号部署：

```
$ yum install -y kubelet-1.16.3 kubeadm-1.16.3 kubectl-1.16.3
$ yum install -y kubelet-1.18.0 kubeadm-1.18.0 kubectl-1.18.0
```
#不加版本部署最新版本
```
yum install -y kubelet kubeadm  kubectl docker
systemctl enable docker && systemctl start docker
$ systemctl enable kubelet
```



## 6. 部署Kubernetes Master

在具有vip的master上操作，这里为master1
#### 方法1： ####
配置kubeadm-config.yaml

	通过如下指令创建默认的kubeadm-config.yaml文件：
	```
	kubeadm config print init-defaults  > kubeadm-config.yaml
	```
	kubeadm-config.yaml组成部署说明：
	
	    InitConfiguration： 用于定义一些初始化配置，如初始化使用的token以及apiserver地址等
	    ClusterConfiguration：用于定义apiserver、etcd、network、scheduler、controller-manager等master组件相关配置项
	    KubeletConfiguration：用于定义kubelet组件相关的配置项
	    KubeProxyConfiguration：用于定义kube-proxy组件相关的配置项
	```
	可以看到，在默认的kubeadm-config.yaml文件中只有InitConfiguration、ClusterConfiguration 两部分。我们可以通过如下操作生成另外两部分的示例文件：
	
	# 生成KubeletConfiguration示例文件 
	```
	kubeadm config print init-defaults --component-configs KubeletConfiguration
	```
	# 生成KubeProxyConfiguration示例文件 
	```
	kubeadm config print init-defaults --component-configs KubeProxyConfiguration
执行命令初始化	```
```
$ kubeadm init --config kubeadm-config.yaml
```

```
$ mkdir /usr/local/kubernetes/manifests -p

$ cd /usr/local/kubernetes/manifests/

$ vi kubeadm-config.yaml

apiServer:
  certSANs:
    - master1
    - master2
    - master.k8s.io
    - 192.168.88.188
    - 192.168.88.180
    - 192.168.88.183
    - 127.0.0.1
  extraArgs:
    authorization-mode: Node,RBAC
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta1
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controlPlaneEndpoint: "master.k8s.io:16443"
controllerManager: {}
dns: 
  type: CoreDNS
etcd:
  local:    
    dataDir: /var/lib/etcd
imageRepository: registry.aliyuncs.com/google_containers
kind: ClusterConfiguration
kubernetesVersion: v1.18.0
networking: 
  dnsDomain: cluster.local  
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.1.0.0/16
scheduler: {}
```
#### 方法2 ####
```
kubeadm init  --control-plane-endpoint "k8s-vip:16443" \
--image-repository registry.aliyuncs.com/google_containers \
--service-cidr=10.1.0.0/16 --pod-network-cidr=10.244.0.0/16 \
--upload-certs | tee kubeadm-init.log

```
执行完成功后以下信息：
```
Your Kubernetes control-plane has initialized successfully!

mater 本地执行

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

加入mater节点执行

  kubeadm join k8s-vip:16443 --token plygwh.be3juzhv59egs7gt \
	--discovery-token-ca-cert-hash sha256:63ae4252558629c082686ecd715d76eafad4ddd9cc4c0d65dec85fa79099b5a0 \
	--control-plane --certificate-key 464b2c5bf6ac548cbaf157d6e771d935b8a707e685f122607d83e45c2af15a2e

加入node执行

kubeadm join k8s-vip:16443 --token plygwh.be3juzhv59egs7gt \
	--discovery-token-ca-cert-hash sha256:63ae4252558629c082686ecd715d76eafad4ddd9cc4c0d65dec85fa79099b5a0 

```
如果token，重新生成token
```
kubeadm token create --print-join-command
```
报错解决：
```
failed to pull image registry.aliyuncs.com/google_containers/coredns:v1.8.4

docker pull coredns/coredns:1.8.4
docker tag coredns/coredns:1.8.4 registry.aliyuncs.com/google_containers/coredns:v1.8.4
```

查看集群状态

```bash
kubectl get cs

kubectl get pods -n kube-system
```



## 7.安装集群网络

从官方地址获取到flannel的yaml，在master1上执行

```bash
mkdir flannel
cd flannel
wget -c https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```



安装flannel网络

```bash
kubectl apply -f kube-flannel.yml 
```

检查

```bash
kubectl get pods -n kube-system
```



## 8、master2节点加入集群

### 8.1 复制密钥及相关文件

从master1复制密钥及相关文件到master2

```bash
# ssh root@192.168.88.181 mkdir -p /etc/kubernetes/pki/etcd

# scp /etc/kubernetes/admin.conf root@192.168.88.181:/etc/kubernetes
   
# scp /etc/kubernetes/pki/{ca.*,sa.*,front-proxy-ca.*} root@192.168.88.181:/etc/kubernetes/pki
   
# scp /etc/kubernetes/pki/etcd/ca.* root@192.168.88.181:/etc/kubernetes/pki/etcd
```

### 8.2 master2加入集群

执行在master1上init后输出的join命令,需要带上参数`--control-plane`表示把master控制节点加入集群

```
kubeadm join master.k8s.io:16443 --token ckf7bs.30576l0okocepg8b     --discovery-token-ca-cert-hash sha256:19afac8b11182f61073e254fb57b9f19ab4d798b70501036fc69ebef46094aba --control-plane
```

检查状态

```
kubectl get node

kubectl get pods --all-namespaces
```

## 

## 5. 加入Kubernetes Node

在node1上执行

向集群添加新节点，执行在kubeadm init输出的kubeadm join命令：

```
kubeadm join master.k8s.io:16443 --token ckf7bs.30576l0okocepg8b     --discovery-token-ca-cert-hash sha256:19afac8b11182f61073e254fb57b9f19ab4d798b70501036fc69ebef46094aba
```

**集群网络重新安装，因为添加了新的node节点**

检查状态

```
kubectl get node

kubectl get pods --all-namespaces
```

## 

## 7. 测试kubernetes集群

在Kubernetes集群中创建一个pod，验证是否正常运行：

```
$ kubectl create deployment nginx --image=nginx
$ kubectl expose deployment nginx --port=80 --type=NodePort
$ kubectl get pod,svc
```

访问地址：http://NodeIP:Port  




