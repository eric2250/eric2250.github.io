# 1. 环境准备

**K8S集群组件规划：**

### 1.1.1 主机操作系统说明

| 序号 | 操作系统及版本 | 备注 |
| :--: | :------------: | :--: |
|  1   |   CentOS7u9    |      |



### 1.1.2 主机硬件配置说明

| 需求 | CPU  | 内存 | 硬盘   | 角色         | 主机名       |
| ---- | ---- | :--: | ------ | ------------ | ------------ |
| 值   | 8C   |  4G  | 1024GB | master1      | k8s-master01 |
| 值   | 8C   |  4G  | 1024GB | master2      | k8s-master02 |
| 值   | 8C   |  4G  | 1024GB | master3      | k8s-master03 |
| 值   | 8C   |  8G  | 1024GB | worker(node) | k8s-node01   |


### 1.1.3 主机配置

#### 1.1.3.1  主机名配置

由于本次使用3台主机完成kubernetes集群部署，其中1台为master节点,名称为k8s-master01;其中2台为worker节点，名称分别为：k8s-master02及k8s-master03

~~~powershell
master节点
# hostnamectl set-hostname k8s-master01
~~~



~~~powershell
worker节点
# hostnamectl set-hostname k8s-node01
~~~

#### 1.1.3.2 主机IP地址配置



~~~powershell
k8s-master节点IP地址为：172.100.3.116/24
# vim /etc/sysconfig/network-scripts/ifcfg-ens33
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
DEVICE="ens33"
ONBOOT="yes"
IPADDR="172.100.3.116"
PREFIX="24"
GATEWAY="172.100.3.254"
DNS1="114.114.114.114"
~~~



~~~powershell
k8s-node1节点IP地址为：172.100.3.117/24
# vim /etc/sysconfig/network-scripts/ifcfg-ens33
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
DEVICE="ens33"
ONBOOT="yes"
IPADDR="172.100.3.117"
PREFIX="24"
GATEWAY="172.100.3.254"
DNS1="114.114.114.114"
~~~



~~~powershell
k8s-worker2节点IP地址为：172.100.3.118/24
# vim /etc/sysconfig/network-scripts/ifcfg-ens33
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
DEVICE="ens33"
ONBOOT="yes"
IPADDR="172.100.3.118"
PREFIX="24"
GATEWAY="172.100.3.254"
DNS1="114.114.114.114"
~~~



#### 1.1.3.3 主机名与IP地址解析



> 所有集群主机均需要进行配置。



~~~powershell
# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.100.3.116 k8s-master01
172.100.3.117 k8s-master02
172.100.3.118 k8s-master03
172.100.3.120 k8s-node01
172.100.3.200 vip
~~~



#### 1.1.3.4  防火墙配置



> 所有主机均需要操作。



~~~powershell
关闭现有防火墙firewalld
# systemctl disable firewalld
# systemctl stop firewalld
# firewall-cmd --state
not running
~~~



#### 1.1.3.5 SELINUX配置



> 所有主机均需要操作。修改SELinux配置需要重启操作系统。



~~~powershell
# sed -ri 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
~~~



#### 1.1.3.6 时间同步配置



>所有主机均需要操作。最小化安装系统需要安装ntpdate软件。



~~~powershell
# crontab -l
0 */1 * * * /usr/sbin/ntpdate time1.aliyun.com
~~~



#### 1.1.3.7 升级操作系统内核

> 所有主机均需要操作。



~~~powershell
导入elrepo gpg key
# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
~~~



~~~powershell
安装elrepo YUM源仓库
# yum -y install https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
~~~



~~~powershell
安装kernel-ml版本，ml为长期稳定版本，lt为长期维护版本
# yum --enablerepo="elrepo-kernel" -y install kernel-lt.x86_64
~~~



~~~powershell
设置grub2默认引导为0
# grub2-set-default 0
~~~



~~~powershell
重新生成grub2引导文件
# grub2-mkconfig -o /boot/grub2/grub.cfg
~~~



~~~powershell
更新后，需要重启，使用升级的内核生效。
# reboot
~~~



~~~powershell
重启后，需要验证内核是否为更新对应的版本
# uname -r
~~~



#### 1.1.3.8  配置内核转发及网桥过滤

>所有主机均需要操作。



~~~powershell
添加网桥过滤及内核转发配置文件
# cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness = 0
EOF
~~~



~~~powershell
加载br_netfilter模块
# modprobe br_netfilter
~~~



~~~powershell
查看是否加载
# lsmod | grep br_netfilter
br_netfilter           22256  0
bridge                151336  1 br_netfilter
~~~



#### 1.1.3.9 安装ipset及ipvsadm

> 所有主机均需要操作。



~~~powershell
安装ipset及ipvsadm
# yum -y install ipset ipvsadm
~~~



~~~powershell
配置ipvsadm模块加载方式
添加需要加载的模块
# cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF
~~~



~~~powershell
授权、运行、检查是否加载
# chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack
~~~



#### 1.1.3.10 关闭SWAP分区



> 修改完成后需要重启操作系统，如不重启，可临时关闭，命令为swapoff -a



~~~powershell
永远关闭swap分区，需要重启操作系统
# cat /etc/fstab
......

# /dev/mapper/centos-swap swap                    swap    defaults        0 0

在上一行中行首添加#
~~~

## 2.安装ETCD服务

### 2.1 安装cfssl工具

cfssl版本：1.6.1
(1) cfssl/cfssl-json/cfssl-certinfo下载地址：

https://github.com/cloudflare/cfssl/releases

```
mv cfssl_linux-amd64 /usr/local/bin/cfssl
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
```

cfssl: 用于签发证书，输出json格式文本；
cfssl-json: 将cfssl签发生成的证书(json格式)变成文件承载式文件；
cfssl-certinfo: 验证查看证书信息。
(2) cfssl工具的子命令包括：

genkey: 生成一个key(私钥)和CSR(证书签名请求)
certinfo: 输出给定证书的证书信息
gencert: 生成新的key(密钥)和签名证书，该命令的参数如下：
-initca：初始化一个新ca，生成根CA时需要。
-ca：指明ca的证书（ca.pem）
-ca-key：指明ca的私钥文件（ca-key.pem）
-config：指明证书请求csr的json文件（ca-config.json）
-profile：与-config中的profile对应，是指根据config中的profile段来生成证书的相关信息
8.2 生成etcd证书
(1) 创建生成CA证书签名请求（CSR）的JSON配置文件，文件路径及内容：

```
cat > /data/etcd/cert/ca-csr.json << EOF
{
    "CA":{"expiry":"876000h"},
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
```

(2) 创建CA根证书策略文件

```
cat > /data/etcd/cert/ca-config.json << EOF
{
    "signing": {
        "default": {
            "expiry": "876000h"
        },
        "profiles": {
            "server": {
                "expiry": "876000h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry":"876000h",
                "usages": [
                    "signing",
                    "key enchiperment",
                    "client auth"
                ]
            },
            "kubernetes": {
                "expiry":"876000h",
                "usages": [
                    "signing",
                    "key enchiperment",
                    "server auth",
                    "client auth"
                ]
            },            
            "peer": {
                "expiry": "876000h",
                "usages": [
                    "signing",
                    "key enchiperment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
EOF
```

(3) 创建etcd证书，客户端访问与节点互相访问使用同一套证书

```
cat > /data/etcd/cert/etcd-csr.json << EOF
{
    "CN": "k8s-etcd",
    "hosts": [
        "172.100.3.116",
        "172.100.3.117",
        "172.100.3.118",
        "127.0.0.1"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "beijing",
            "L": "beijing",
            "O": "k8s",
            "OU": "system"
        }
    ]
}
EOF
```

(4) 生成etcd证书和私钥

```
#cd /data/etcd/cert/ && cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
#cfssl gencert -ca="ca.pem" -ca-key="ca-key.pem" -config="ca-config.json" -profile="kubernetes" etcd-csr.json | cfssljson -bare etcd

```

(5) 查询证书有效期

```
#openssl x509 -noout -text -in /data/etcd/cert/ca.pem | grep Not  //查询ca证书有效期
#openssl x509 -noout -text -in /data/etcd/cert/etcd.pem | grep Not  //查询etcd证书有效期
```

### 2.2 安装etcd集群

(1) etcd版本：v3.5.4 ，安装包下载地址：

```
https://github.com/etcd-io/etcd/releases/tag/v3.5.4
```

(2) 二进制安装第一台etcd

```
#tar -zxf etcd-v3.5.4-linux-amd64.tar.gz -C /data/
#mv /data/etcd-v3.5.4-linux-amd64 /data/etcd 
#mkdir -p /data/etcd/{cert,config,data,logs,service}
#cp /data/etcd/etcdctl  /usr/bin/
#vim /data/etcd/config/etcd.conf
#[Member]
ETCD_NAME="etcd01"
ETCD_DATA_DIR="/data/etcd/data"
ETCD_LISTEN_PEER_URLS="https://172.100.3.116:2380"
ETCD_LISTEN_CLIENT_URLS="https://172.100.3.116:2379,http://127.0.0.1:2379"
ETCD_QUOTA_BACKEND_BYTES="8000000000"
#[Clustering]
#ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://172.100.3.116:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://172.100.3.116:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://172.100.3.116:2380,etcd02=https://172.100.3.117:2380,etcd03=https://172.100.3.118:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_LOG_OUTPUT="stdout"
#vim /data/etcd/service/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=root
WorkingDirectory=/data/etcd/
EnvironmentFile=/data/etcd/config/etcd.conf
ExecStart=/data/etcd/etcd \
--cert-file=/data/etcd/cert/etcd.pem \
--key-file=/data/etcd/cert/etcd-key.pem \
--trusted-ca-file=/data/etcd/cert/ca.pem \
--peer-cert-file=/data/etcd/cert/etcd.pem \
--peer-key-file=/data/etcd/cert/etcd-key.pem \
--peer-trusted-ca-file=/data/etcd/cert/ca.pem \
--initial-cluster-state=new \
--peer-client-cert-auth \
--client-cert-auth
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

#chmod +x /data/etcd/service/etcd.service
#cp /data/etcd/service/etcd.service  /usr/lib/systemd/system/
#systemctl daemon-reload && systemctl enable etcd && systemctl restart etcd
#echo "#ETCDCTL Env" >> /etc/profile && echo "export ETCDCTL_API=3" >> /etc/profile
```

(3) 二进制安装其他etcd
**复制第一台etcd的目录/data/etcd 到其他2台服务器的/data 目录下，修改/data/etcd/config/etcd.conf配置文件的IP地址和etcd名称，删除/data/etcd/data/目录下的文件，然后执行：**

```
scp -r /data/etcd k8s-master2:/data/
scp -r /data/etcd k8s-master3:/data
```

- Master02：

```
# cp /data/etcd/service/etcd.service  /usr/lib/systemd/system/
# systemctl daemon-reload && systemctl enable etcd && systemctl restart etcd
# echo "#ETCDCTL Env" >> /etc/profile && echo "export ETCDCTL_API=3" >> /etc/profile
```

```
#[Member]
ETCD_NAME="etcd02"
ETCD_DATA_DIR="/data/etcd/data"
ETCD_LISTEN_PEER_URLS="https://172.100.3.117:2380"
ETCD_LISTEN_CLIENT_URLS="https://172.100.3.117:2379,http://127.0.0.1:2379"
ETCD_QUOTA_BACKEND_BYTES="8000000000"
#[Clustering]
#ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://172.100.3.117:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://172.100.3.117:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://172.100.3.116:2380,etcd02=https://172.100.3.117:2380,etcd03=https://172.100.3.118:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_LOG_OUTPUT="stdout"
```

- Master03：

```
# cp /data/etcd/service/etcd.service  /usr/lib/systemd/system/
# systemctl daemon-reload && systemctl enable etcd && systemctl restart etcd
# echo "#ETCDCTL Env" >> /etc/profile && echo "export ETCDCTL_API=3" >> /etc/profile
```

```
#[Member]
ETCD_NAME="etcd03"
ETCD_DATA_DIR="/data/etcd/data"
ETCD_LISTEN_PEER_URLS="https://172.100.3.118:2380"
ETCD_LISTEN_CLIENT_URLS="https://172.100.3.118:2379,http://127.0.0.1:2379"
ETCD_QUOTA_BACKEND_BYTES="8000000000"
#[Clustering]
#ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://172.100.3.118:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://172.100.3.118:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://172.100.3.116:2380,etcd02=https://172.100.3.117:2380,etcd03=https://172.100.3.118:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_LOG_OUTPUT="stdout"

```

(4) 检查etcd集群状态

```
#etcdctl --endpoints="https://172.100.3.116:2379,https://172.100.3.117:2379,https://172.100.3.118:2379" --cacert=/data/etcd/cert/ca.pem --cert=/data/etcd/cert/etcd.pem --key=/data/etcd/cert/etcd-key.pem --write-out=table member list   #查看集群成员   
```

```
+------------------+---------+--------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |  NAME  |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+--------+----------------------------+----------------------------+------------+
| 6bfd5bc5ef71014e | started | etcd02 | https://172.100.3.117:2380 | https://172.100.3.117:2379 |      false |
| 7bed6697d4a82694 | started | etcd01 | https://172.100.3.116:2380 | https://172.100.3.116:2379 |      false |
| a5468701781a7603 | started | etcd03 | https://172.100.3.118:2380 | https://172.100.3.118:2379 |      false |
+------------------+---------+--------+----------------------------+----------------------------+------------+

```



```
#etcdctl --endpoints="https://172.100.3.116:2379,https://172.100.3.117:2379,https://172.100.3.118:2379" --cacert=/data/etcd/cert/ca.pem --cert=/data/etcd/cert/etcd.pem --key=/data/etcd/cert/etcd-key.pem --write-out=table endpoint status  #查看集群状态                                                                                                                         
```

```
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://172.100.3.116:2379 | 7bed6697d4a82694 |   3.5.9 |   20 kB |     false |      false |         2 |          8 |                  8 |        |
| https://172.100.3.117:2379 | 6bfd5bc5ef71014e |   3.5.9 |   20 kB |      true |      false |         2 |          8 |                  8 |        |
| https://172.100.3.118:2379 | a5468701781a7603 |   3.5.9 |   20 kB |     false |      false |         2 |          8 |                  8 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```



## 3. 安装第一台k8s-master服务

### 1 配置4层反向代理

```
#yum install -y keepalived  haproxy    //拉取并配置Keepalived和haproxy
#vim /etc/keepalived/keepalived.conf
! Configuration File for keepalived
global_defs {
   router_id K8S-HAPROXY
   script_user root
   enable_script_security
}
vrrp_script check_haproxy {
    script "/etc/keepalived/check_haproxy.sh"
    interval 2
    weight -40
}
vrrp_instance VI_HAPROXY {
    state BACKUP
    interface eth0
    virtual_router_id 218
    priority 120
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass 2121
    }
    virtual_ipaddress {
        172.100.3.100
    }
    track_script {
        check_haproxy
    }
}
#journalctl -f -u keepalived    //查看实时日志打印
#vim /etc/keepalived/check_haproxy.sh
#!/bin/bash
flag=`systemctl status haproxy |grep -cE "running"`
if [ ${flag} -eq 1 ];then
  exit 0
else
  exit 1
fi
#chmod 755  /etc/keepalived/check_haproxy.sh     //可执行权限
#vim /etc/haproxy/haproxy.cfg
global
  log 127.0.0.1 local2 info
  chroot      /var/lib/haproxy
  pidfile     /var/run/haproxy.pid
  maxconn 4096
  nbproc      8
  daemon
  stats bind-process 1
  stats socket /var/lib/haproxy/stats
defaults
  mode                     http
  log                     global
  option                  dontlognull
  option http-server-close
  option                  redispatch
  option                  forwardfor
  retries                 3
  timeout http-request    10s
  timeout queue           1m
  timeout connect         10s
  timeout client          1m
  timeout server          1m
  timeout http-keep-alive 10s
  timeout check           10s
  option forceclose
  maxconn                 3000
frontend  main *:5443
    mode tcp
    option tcplog
    default_backend     k8s_apiserver
backend k8s_apiserver
    mode tcp
    option tcplog
    balance     roundrobin  # 默认的负载均衡的方式,轮询方式
    server k8s-master01 172.100.3.116:6443 check inter 2000 fall 2 rise 2 weight 1
    server k8s-master02 172.100.3.117:6443 check inter 2000 fall 2 rise 2 weight 1
    server k8s-master03 172.100.3.118:6443 check inter 2000 fall 2 rise 2 weight 1
#systemctl enable haproxy && systemctl restart haproxy && systemctl status haproxy
#systemctl enable keepalived && systemctl restart keepalived && systemctl status  keepalived
```

### 2 签发所有证书

安装包下载地址：`https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG`
(1) 下载二进制包并解压

```
#tar -zxf kubernetes-server-linux-amd64.tar.gz -C /data/
# mkdir -p /data/kubernetes
#mv /data/kubernetes/server/bin  /data/kubernetes/
#rm -rf /data/kubernetes/{kubernetes-src.tar.gz,LICENSES,addons,server,bin/{*.tar,*_tag}}
#mkdir -p /data/kubernetes/{cfssl,pki,config,data,logs,service,yaml}
#cp /data/kubernetes/bin/kubectl /usr/bin/

```

(2) 创建生成CA证书签名请求（CSR）的JSON配置文件，文件路径及内容：

```
cat > /data/kubernetes/pki/ca-csr.json << EOF
{
    "CA":{"expiry":"876000h"},
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
```

(2) 创建CA根证书策略文件

```
cat > /data/kubernetes/pki/ca-config.json << EOF
{
    "signing": {
        "default": {
            "expiry": "876000h"
        },
        "profiles": {
            "server": {
                "expiry": "876000h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry":"876000h",
                "usages": [
                    "signing",
                    "key enchiperment",
                    "client auth"
                ]
            },
            "kubernetes": {
                "expiry":"876000h",
                "usages": [
                    "signing",
                    "key enchiperment",
                    "server auth",
                    "client auth"
                ]
            },            
            "peer": {
                "expiry": "876000h",
                "usages": [
                    "signing",
                    "key enchiperment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
EOF
```

(3) 创建kube-apiserver的json文件

```
cat > /data/kubernetes/pki/kube-apiserver-csr.json << EOF
{
    "CN": "kubernetes",
    "hosts": [
      "172.100.3.116",
      "172.100.3.117",
      "172.100.3.118",
      "172.100.3.100",
      "10.96.0.1",
      "127.0.0.1",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "BeiJing",
            "ST": "BeiJing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
```

(4) 创建kube-controller-manager的json文件

```
cat > /data/kubernetes/pki/kube-controller-manager-csr.json << EOF
{
  "CN": "system:kube-controller-manager",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "BeiJing", 
      "ST": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
```

(5) 创建kube-scheduler的json文件

```
cat > /data/kubernetes/pki/kube-scheduler-csr.json << EOF
{
  "CN": "system:kube-scheduler",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "BeiJing",
      "ST": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
```

(6) 创建kubectl的json文件

```
cat > /data/kubernetes/pki/kubectl-csr.json <<EOF
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "BeiJing",
      "ST": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
```

(7) 创建kube-proxy的json文件

```
cat > /data/kubernetes/pki/kube-proxy-csr.json << EOF
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "BeiJing",
      "ST": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
```

(8) 创建所有证书文件

```
#cd /data/kubernetes/pki && cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
#cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-apiserver-csr.json | cfssljson -bare kube-apiserver
#cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
#cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare kube-scheduler
#cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubectl-csr.json | cfssljson -bare kubectl
#cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
```

(9) 查询证书文件有效期

```
#openssl x509 -noout -text -in /data/kubernetes/pki/ca.pem | grep Not     //查询ca证书有效期
#openssl x509 -noout -text -in /data/kubernetes/pki/kube-apiserver.pem | grep Not
```

### 3 生成token.csv文件

```
#head -c 16 /dev/urandom | od -An -t x | tr -d ' '
e6c807c0033ea7cfcda16abad126751c
#echo '9c23dac5775a373487d76445adb696e1,kubelet-bootstrap,10001,"system:node-bootstrapper"' >  /data/kubernetes/config/token.csv
```

### 4 创建kube-apiserver启动配置和脚本

```
cat > /data/kubernetes/config/kube-apiserver.conf << EOF
KUBE_APISERVER_OPTS="--logtostderr=false \\
--v=2 \\
--etcd-servers=https://172.100.3.116:2379,https://172.100.3.117:2379,https://172.100.3.118:2379 \\
--bind-address=172.100.3.116 \\
--secure-port=6443 \\
--advertise-address=172.100.3.116 \\
--allow-privileged=true \\
--service-cluster-ip-range=10.96.0.0/16 \\
--enable-admission-plugins=NodeRestriction \\
--authorization-mode=RBAC,Node \\
--enable-bootstrap-token-auth=true \\
--token-auth-file=/data/kubernetes/config/token.csv \\
--service-node-port-range=30000-60000 \\
--kubelet-client-certificate=/data/kubernetes/pki/kube-apiserver.pem \\
--kubelet-client-key=/data/kubernetes/pki/kube-apiserver-key.pem \\
--tls-cert-file=/data/kubernetes/pki/kube-apiserver.pem  \\
--tls-private-key-file=/data/kubernetes/pki/kube-apiserver-key.pem \\
--client-ca-file=/data/kubernetes/pki/ca.pem \\
--service-account-key-file=/data/kubernetes/pki/ca-key.pem \\
--service-account-issuer=https://kubernetes.default.svc.cluster.local \\
--service-account-signing-key-file=/data/kubernetes/pki/ca-key.pem \\
--etcd-cafile=/data/etcd/cert/ca.pem \\
--etcd-certfile=/data/etcd/cert/etcd.pem \\
--etcd-keyfile=/data/etcd/cert/etcd-key.pem \\
--requestheader-client-ca-file=/data/kubernetes/pki/ca.pem \\
--proxy-client-cert-file=/data/kubernetes/pki/kube-apiserver.pem \\
--proxy-client-key-file=/data/kubernetes/pki/kube-apiserver-key.pem \\
--requestheader-allowed-names=kubernetes \\
--requestheader-extra-headers-prefix=X-Remote-Extra- \\
--requestheader-group-headers=X-Remote-Group \\
--requestheader-username-headers=X-Remote-User \\
--enable-aggregator-routing=true \\
--audit-log-maxage=30 \\
--audit-log-maxbackup=3 \\
--audit-log-maxsize=100 \\
--audit-log-path=/data/kubernetes/logs/audit.log"
EOF
```

```
cat > /data/kubernetes/service/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=/data/kubernetes/config/kube-apiserver.conf
ExecStart=/data/kubernetes/bin/kube-apiserver \$KUBE_APISERVER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

```
#chmod +x /data/kubernetes/service/kube-apiserver.service
#cp /data/kubernetes/service/kube-apiserver.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable kube-apiserver 
systemctl restart kube-apiserver
systemctl status kube-apiserver
```

```
# 测试
curl --insecure https://172.100.3.116:6443/
curl --insecure https://172.100.3.117:6443/
curl --insecure https://172.100.3.118:6443/
curl --insecure https://172.100.3.100:5443/
```

### 5 创建kube-controller-manager启动配置和脚本

```
#KUBE_CONFIG="/data/kubernetes/config/kube-controller-manager.kubeconfig" 
#KUBE_APISERVER="https://172.100.3.100:5443" 
#kubectl config set-cluster kubernetes \
  --certificate-authority=/data/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=${KUBE_CONFIG}
#kubectl config set-credentials kube-controller-manager \
  --client-certificate=/data/kubernetes/pki/kube-controller-manager.pem \
  --client-key=/data/kubernetes/pki/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}
#kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-controller-manager \
  --kubeconfig=${KUBE_CONFIG}
#kubectl config use-context default --kubeconfig=${KUBE_CONFIG}
```

```
#cat > /data/kubernetes/config/kube-controller-manager.conf << EOF
KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=false \\
--v=2 \\
--leader-elect=true \\
--kubeconfig=/data/kubernetes/config/kube-controller-manager.kubeconfig \\
--bind-address=127.0.0.1 \\
--allocate-node-cidrs=true \\
--cluster-cidr=10.244.0.0/16 \\
--service-cluster-ip-range=10.96.0.0/16 \\
--cluster-signing-cert-file=/data/kubernetes/pki/ca.pem \\
--cluster-signing-key-file=/data/kubernetes/pki/ca-key.pem  \\
--root-ca-file=/data/kubernetes/pki/ca.pem \\
--service-account-private-key-file=/data/kubernetes/pki/ca-key.pem \\
--cluster-signing-duration=876000h0m0s"
EOF
```

```
#cat > /data/kubernetes/service/kube-controller-manager.service << EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=/data/kubernetes/config/kube-controller-manager.conf
ExecStart=/data/kubernetes/bin/kube-controller-manager \$KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

```
#chmod +x /data/kubernetes/service/kube-controller-manager.service
#cp /data/kubernetes/service/kube-controller-manager.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl restart kube-controller-manager
systemctl status kube-controller-manager
```



### 6 创建kube-scheduler启动配置和脚本

```
KUBE_CONFIG="/data/kubernetes/config/kube-scheduler.kubeconfig"
KUBE_APISERVER="https://172.100.3.100:5443"
kubectl config set-cluster kubernetes \
  --certificate-authority=/data/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=${KUBE_CONFIG}
kubectl config set-credentials kube-scheduler \
  --client-certificate=/data/kubernetes/pki/kube-scheduler.pem \
  --client-key=/data/kubernetes/pki/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-scheduler \
  --kubeconfig=${KUBE_CONFIG}
kubectl config use-context default --kubeconfig=${KUBE_CONFIG}
```

```
#cat > /data/kubernetes/config/kube-scheduler.conf << EOF
KUBE_SCHEDULER_OPTS="--logtostderr=false \\
--v=2 \\
--leader-elect \\
--kubeconfig=/data/kubernetes/config/kube-scheduler.kubeconfig \\
--bind-address=127.0.0.1"
EOF
```

```
#cat > /data/kubernetes/service/kube-scheduler.service << EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=/data/kubernetes/config/kube-scheduler.conf
ExecStart=/data/kubernetes/bin/kube-scheduler \$KUBE_SCHEDULER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

```
#chmod +x /data/kubernetes/service/kube-scheduler.service
#cp /data/kubernetes/service/kube-scheduler.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable kube-scheduler
systemctl restart kube-scheduler
systemctl status kube-scheduler
```

### 7 创建kubectl连接配置文件

```
#KUBE_CONFIG="/data/kubernetes/config/kubectl.kubeconfig"
KUBE_APISERVER="https://172.100.3.100:5443"
kubectl config set-cluster kubernetes \
  --certificate-authority=/data/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=${KUBE_CONFIG}
kubectl config set-credentials cluster-admin \
  --client-certificate=/data/kubernetes/pki/kubectl.pem \
  --client-key=/data/kubernetes/pki/kubectl-key.pem \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}
kubectl config set-context default \
  --cluster=kubernetes \
  --user=cluster-admin \
  --kubeconfig=${KUBE_CONFIG}
kubectl config use-context default --kubeconfig=${KUBE_CONFIG}
```

```
#mkdir -p $HOME/.kube && sudo cp -i /data/kubernetes/config/kubectl.kubeconfig  $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config                         //生成kubectl(重要)
```



### 8 授权kubelet-bootstrap用户允许请求证书

```
#kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
```

### 9 创建kubelet启动配置和脚本

```
#cat > /data/kubernetes/config/kubelet.conf << EOF
KUBELET_OPTS="--logtostderr=false \\
--v=2 \\
--hostname-override=k8s-master1 \\
--cluster-domain=cluster.local \\
--kubeconfig=/data/kubernetes/config/kubelet.kubeconfig \\
--bootstrap-kubeconfig=/data/kubernetes/config/kubelet-bootstrap.kubeconfig \\
--config=/data/kubernetes/config/kubelet-config.yml \\
--cert-dir=/data/kubernetes/pki \\
--container-runtime=remote  \\
--runtime-request-timeout=3m  \\
--container-runtime-endpoint=unix:///run/containerd/containerd.sock  \\
--cgroup-driver=systemd \\
--feature-gates=IPv6DualStack=true"
EOF
```

```
#cat > /data/kubernetes/config/kubelet-config.yml << EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: 0.0.0.0
port: 10250
readOnlyPort: 10255
cgroupDriver: cgroupfs
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local 
failSwapOn: false
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 2m0s
    enabled: true
  x509:
    clientCAFile: /data/kubernetes/pki/ca.pem 
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 5m0s
    cacheUnauthorizedTTL: 30s
evictionHard:
  imagefs.available: 15%
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
maxOpenFiles: 1000000
maxPods: 500
EOF
```

```
#KUBE_CONFIG="/data/kubernetes/config/kubelet-bootstrap.kubeconfig"
KUBE_APISERVER="https://172.100.3.100:5443" # apiserver IP:PORT
kubectl config set-cluster kubernetes \
  --certificate-authority=/data/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=${KUBE_CONFIG}
kubectl config set-credentials "kubelet-bootstrap" \
  --token=$(awk -F "," '{print $1}' /data/kubernetes/config/token.csv) \
  --kubeconfig=${KUBE_CONFIG}
kubectl config set-context default \
  --cluster=kubernetes \
  --user="kubelet-bootstrap" \
  --kubeconfig=${KUBE_CONFIG}
kubectl config use-context default --kubeconfig=${KUBE_CONFIG}
```

```
#cat > /data/kubernetes/service/kubelet.service << EOF
[Unit]
Description=Kubernetes Kubelet
After=docker.service

[Service]
EnvironmentFile=/data/kubernetes/config/kubelet.conf
ExecStart=/data/kubernetes/bin/kubelet \$KUBELET_OPTS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

```
#chmod +x /data/kubernetes/service/kubelet.service
cp /data/kubernetes/service/kubelet.service  /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet 
systemctl status kubelet
```



### 10 创建kube-proxy启动配置和脚本

```
#cat > /data/kubernetes/config/kube-proxy.conf << EOF
KUBE_PROXY_OPTS="--logtostderr=false \\
--v=2 \\
--config=/data/kubernetes/config/kube-proxy-config.yml"
EOF
#cat > /data/kubernetes/config/kube-proxy-config.yml << EOF
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
metricsBindAddress: 0.0.0.0:10249
clientConnection:
  kubeconfig: /data/kubernetes/config/kube-proxy.kubeconfig
hostnameOverride: k8s-master1
clusterCIDR: 10.244.0.0/16
mode: ipvs
ipvs:
  scheduler: "rr"
iptables:
  masqueradeAll: true
EOF
```



```
#KUBE_CONFIG="/data/kubernetes/config/kube-proxy.kubeconfig"
KUBE_APISERVER="https://172.100.3.100:5443"
kubectl config set-cluster kubernetes \
  --certificate-authority=/data/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=${KUBE_CONFIG}
kubectl config set-credentials kube-proxy \
  --client-certificate=/data/kubernetes/pki/kube-proxy.pem \
  --client-key=/data/kubernetes/pki/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=${KUBE_CONFIG}
kubectl config use-context default --kubeconfig=${KUBE_CONFIG}
```

```
#cat > /data/kubernetes/service/kube-proxy.service << EOF
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=/data/kubernetes/config/kube-proxy.conf
ExecStart=/data/kubernetes/bin/kube-proxy \$KUBE_PROXY_OPTS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

```
#chmod +x /data/kubernetes/service/kube-proxy.service
cp /data/kubernetes/service/kube-proxy.service  /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable kube-proxy 
systemctl restart kube-proxy
systemctl status kube-proxy
```



### 11 批准kubelete证书申请并加入集群

```
#kubectl get csr                 //查看kubelet证书请求(重要)                      
#kubectl certificate approve     node-csr-XXXXXXXX           //批准kubelet证书申请(重要)
#kubectl get cs && kubectl get sa -A && kubectl get ns -A && kubectl get role -A //查看资源
#kubectl label node [nodename] node-role.kubernetes.io/master=                 //给master打标签
#kubectl label node [nodename] node-role.kubernetes.io/ingress=                 //给master打标签
```

### 12 配置kubectl命令补全功能

```
#yum -y install  bash-completion
chmod +x /usr/share/bash-completion/bash_completion
/usr/share/bash-completion/bash_completion
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> /etc/bashrc
```

### 13 授权apiserver访问kubelet

```
#cat > /data/kubernetes/yaml/apiserver-to-kubelet-rbac.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
      - pods/log
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF
#kubectl apply -f /data/kubernetes/yaml/apiserver-to-kubelet-rbac.yaml
```

### 14 配置calico功能

calico.yaml百度网盘下载链接：https://pan.baidu.com/s/1c5CaBpm5C-7xHuNQ9W7bqA 提取码：tpkt

```
#kubectl apply -f /data/kubernetes/yaml/calico.yaml
```

### 15 配置coredns功能

```
#vim /data/kubernetes/yaml/coredns.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
rules:
- apiGroups:
  - ""
  resources:
  - endpoints
  - services
  - pods
  - namespaces
  verbs:
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
- kind: ServiceAccount
  name: coredns
  namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
          lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf {
          max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/name: "CoreDNS"
spec:
  # replicas: not specified here:
  # 1. Default is 1.
  # 2. Will be tuned in real time if DNS horizontal auto-scaling is turned on.
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  replicas: 2
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
    spec:
      priorityClassName: system-cluster-critical
      serviceAccountName: coredns
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      nodeSelector:
        kubernetes.io/os: linux
      affinity:
         podAntiAffinity:
           preferredDuringSchedulingIgnoredDuringExecution:
           - weight: 100
             podAffinityTerm:
               labelSelector:
                 matchExpressions:
                   - key: k8s-app
                     operator: In
                     values: ["kube-dns"]
               topologyKey: kubernetes.io/hostname
      containers:
      - name: coredns
        image: registry.cn-beijing.aliyuncs.com/dotbalo/coredns:1.7.0
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
          readOnly: true
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - all
          readOnlyRootFilesystem: true
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        readinessProbe:
          httpGet:
            path: /ready
            port: 8181
            scheme: HTTP
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 10.96.0.10
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
  - name: metrics
    port: 9153
    protocol: TCP
#kubectl apply -f /data/kubernetes/yaml/coredns.yaml
```

### 16 配置dashboard功能

```
#vim /data/kubernetes/yaml/dashboard.yaml
# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apiVersion: v1
kind: Namespace
metadata:
  name: kubernetes-dashboard

---

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard

---

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
  type: NodePort
  selector:
    k8s-app: kubernetes-dashboard

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-certs
  namespace: kubernetes-dashboard
type: Opaque

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-csrf
  namespace: kubernetes-dashboard
type: Opaque
data:
  csrf: ""

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-key-holder
  namespace: kubernetes-dashboard
type: Opaque

---

kind: ConfigMap
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-settings
  namespace: kubernetes-dashboard

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
rules:
  # Allow Dashboard to get, update and delete Dashboard exclusive secrets.
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs", "kubernetes-dashboard-csrf"]
    verbs: ["get", "update", "delete"]
    # Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["kubernetes-dashboard-settings"]
    verbs: ["get", "update"]
    # Allow Dashboard to get metrics.
  - apiGroups: [""]
    resources: ["services"]
    resourceNames: ["heapster", "dashboard-metrics-scraper"]
    verbs: ["proxy"]
  - apiGroups: [""]
    resources: ["services/proxy"]
    resourceNames: ["heapster", "http:heapster:", "https:heapster:", "dashboard-metrics-scraper", "http:dashboard-metrics-scraper"]
    verbs: ["get"]

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
rules:
  # Allow Metrics Scraper to get metrics from the Metrics server
  - apiGroups: ["metrics.k8s.io"]
    resources: ["pods", "nodes"]
    verbs: ["get", "list", "watch"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kubernetes-dashboard
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kubernetes-dashboard
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard

---

kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  template:
    metadata:
      labels:
        k8s-app: kubernetes-dashboard
    spec:
      securityContext:
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: kubernetes-dashboard
          image: kubernetesui/dashboard:v2.5.1
          imagePullPolicy: Always
          ports:
            - containerPort: 8443
              protocol: TCP
          args:
            - --auto-generate-certificates
            - --namespace=kubernetes-dashboard
            # Uncomment the following line to manually specify Kubernetes API server Host
            # If not specified, Dashboard will attempt to auto discover the API server and connect
            # to it. Uncomment only if the default does not work.
            # - --apiserver-host=http://my-address:port
          volumeMounts:
            - name: kubernetes-dashboard-certs
              mountPath: /certs
              # Create on-disk volume to store exec logs
            - mountPath: /tmp
              name: tmp-volume
          livenessProbe:
            httpGet:
              scheme: HTTPS
              path: /
              port: 8443
            initialDelaySeconds: 30
            timeoutSeconds: 30
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsUser: 1001
            runAsGroup: 2001
      volumes:
        - name: kubernetes-dashboard-certs
          secret:
            secretName: kubernetes-dashboard-certs
        - name: tmp-volume
          emptyDir: {}
      serviceAccountName: kubernetes-dashboard
      nodeSelector:
        "kubernetes.io/os": linux
      # Comment the following tolerations if Dashboard must not be deployed on master
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule

---

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: dashboard-metrics-scraper
  name: dashboard-metrics-scraper
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 8000
      targetPort: 8000
  selector:
    k8s-app: dashboard-metrics-scraper

---

kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: dashboard-metrics-scraper
  name: dashboard-metrics-scraper
  namespace: kubernetes-dashboard
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: dashboard-metrics-scraper
  template:
    metadata:
      labels:
        k8s-app: dashboard-metrics-scraper
    spec:
      securityContext:
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: dashboard-metrics-scraper
          image: kubernetesui/metrics-scraper:v1.0.7
          ports:
            - containerPort: 8000
              protocol: TCP
          livenessProbe:
            httpGet:
              scheme: HTTP
              path: /
              port: 8000
            initialDelaySeconds: 30
            timeoutSeconds: 30
          volumeMounts:
          - mountPath: /tmp
            name: tmp-volume
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsUser: 1001
            runAsGroup: 2001
      serviceAccountName: kubernetes-dashboard
      nodeSelector:
        "kubernetes.io/os": linux
      # Comment the following tolerations if Dashboard must not be deployed on master
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
      volumes:
        - name: tmp-volume
          emptyDir: {}
#kubectl apply -f /data/kubernetes/yaml/dashboard.yaml
#vim /data/kubernetes/yaml/dashboard-user.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
#kubectl apply -f /data/kubernetes/yaml/dashboard-user.yaml
#kubectl -n kubernetes-dashboard create token admin-user
```

### 17 配置nginx-ingress-controller功能

vim /data/kubernetes/yaml/nginx-ingress-controller.yaml

```
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  name: ingress-nginx
---
apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx
  namespace: ingress-nginx
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-admission
  namespace: ingress-nginx
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx
  namespace: ingress-nginx
rules:
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - configmaps
  - pods
  - secrets
  - endpoints
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses/status
  verbs:
  - update
- apiGroups:
  - networking.k8s.io
  resources:
  - ingressclasses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resourceNames:
  - ingress-controller-leader
  resources:
  - configmaps
  verbs:
  - get
  - update
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - create
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - patch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-admission
  namespace: ingress-nginx
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - endpoints
  - nodes
  - pods
  - secrets
  - namespaces
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - patch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses/status
  verbs:
  - update
- apiGroups:
  - networking.k8s.io
  resources:
  - ingressclasses
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-admission
rules:
- apiGroups:
  - admissionregistration.k8s.io
  resources:
  - validatingwebhookconfigurations
  verbs:
  - get
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx
subjects:
- kind: ServiceAccount
  name: ingress-nginx
  namespace: ingress-nginx
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-admission
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx-admission
subjects:
- kind: ServiceAccount
  name: ingress-nginx-admission
  namespace: ingress-nginx
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx
subjects:
- kind: ServiceAccount
  name: ingress-nginx
  namespace: ingress-nginx
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-admission
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx-admission
subjects:
- kind: ServiceAccount
  name: ingress-nginx-admission
  namespace: ingress-nginx
---
apiVersion: v1
data:
  allow-snippet-annotations: "true"
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-controller
  namespace: ingress-nginx
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  ports:
  - appProtocol: http
    name: http
    port: 80
    protocol: TCP
    targetPort: http
  - appProtocol: https
    name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-controller-admission
  namespace: ingress-nginx
spec:
  ports:
  - appProtocol: https
    name: https-webhook
    port: 443
    targetPort: webhook
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  type: ClusterIP
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  minReadySeconds: 0
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app.kubernetes.io/component: controller
      app.kubernetes.io/instance: ingress-nginx
      app.kubernetes.io/name: ingress-nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/name: ingress-nginx
    spec:
      hostNetwork: true
      containers:
      - args:
        - /nginx-ingress-controller
#        - --publish-service=$(POD_NAMESPACE)/ingress-nginx-controller
        - --election-id=ingress-controller-leader
        - --controller-class=k8s.io/ingress-nginx
        - --ingress-class=nginx
        - --configmap=$(POD_NAMESPACE)/ingress-nginx-controller
        - --validating-webhook=:8443
        - --validating-webhook-certificate=/usr/local/certificates/cert
        - --validating-webhook-key=/usr/local/certificates/key
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: LD_PRELOAD
          value: /usr/local/lib/libmimalloc.so
        image: registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:v1.0.0
        imagePullPolicy: IfNotPresent
        lifecycle:
          preStop:
            exec:
              command:
              - /wait-shutdown
        livenessProbe:
          failureThreshold: 5
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        name: controller
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        - containerPort: 443
          name: https
          protocol: TCP
        - containerPort: 8443
          name: webhook
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources:
          requests:
            cpu: 100m
            memory: 90Mi
        securityContext:
          allowPrivilegeEscalation: true
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - ALL
          runAsUser: 101
        volumeMounts:
        - mountPath: /usr/local/certificates/
          name: webhook-cert
          readOnly: true
      dnsPolicy: ClusterFirst
      nodeSelector:
        kubernetes.io/os: linux
        node-role.kubernetes.io/ingress: ""
      serviceAccountName: ingress-nginx
      terminationGracePeriodSeconds: 300
      volumes:
      - name: webhook-cert
        secret:
          secretName: ingress-nginx-admission
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-admission-create
  namespace: ingress-nginx
spec:
  template:
    metadata:
      labels:
        app.kubernetes.io/component: admission-webhook
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
        app.kubernetes.io/version: 1.2.0
      name: ingress-nginx-admission-create
    spec:
      containers:
      - args:
        - create
        - --host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.$(POD_NAMESPACE).svc
        - --namespace=$(POD_NAMESPACE)
        - --secret-name=ingress-nginx-admission
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: registry.cn-hangzhou.aliyuncs.com/google_containers/kube-webhook-certgen:v1.0
        imagePullPolicy: IfNotPresent
        name: create
        securityContext:
          allowPrivilegeEscalation: false
      nodeSelector:
        kubernetes.io/os: linux
      restartPolicy: OnFailure
      securityContext:
        fsGroup: 2000
        runAsNonRoot: true
        runAsUser: 2000
      serviceAccountName: ingress-nginx-admission
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-admission-patch
  namespace: ingress-nginx
spec:
  template:
    metadata:
      labels:
        app.kubernetes.io/component: admission-webhook
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
        app.kubernetes.io/version: 1.2.0
      name: ingress-nginx-admission-patch
    spec:
      containers:
      - args:
        - patch
        - --webhook-name=ingress-nginx-admission
        - --namespace=$(POD_NAMESPACE)
        - --patch-mutating=false
        - --secret-name=ingress-nginx-admission
        - --patch-failure-policy=Fail
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: registry.cn-hangzhou.aliyuncs.com/google_containers/kube-webhook-certgen:v1.0
        imagePullPolicy: IfNotPresent
        name: patch
        securityContext:
          allowPrivilegeEscalation: false
      nodeSelector:
        kubernetes.io/os: linux
      restartPolicy: OnFailure
      securityContext:
        fsGroup: 2000
        runAsNonRoot: true
        runAsUser: 2000
      serviceAccountName: ingress-nginx-admission
---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: nginx
spec:
  controller: k8s.io/ingress-nginx
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.2.0
  name: ingress-nginx-admission
webhooks:
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: ingress-nginx-controller-admission
      namespace: ingress-nginx
      path: /networking/v1/ingresses
  failurePolicy: Fail
  matchPolicy: Equivalent
  name: validate.nginx.ingress.kubernetes.io
  rules:
  - apiGroups:
    - networking.k8s.io
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - ingresses
  sideEffects: None
```

```
#kubectl apply -f /data/kubernetes/yaml/nginx-ingress-controller.yaml
#vim /data/kubernetes/yaml/test-nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-pod
  template:
    metadata:
      labels:
        app: nginx-pod
    spec:
      containers:
      - name: nginx
        image: nginx:1.17.1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: default
spec:
  type: ClusterIP
  ports:
    - port: 80
      name: nginx
  selector:
    app: nginx-pod
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: default
spec:
  ingressClassName: nginx  #必须存在,否则ingress状态下Address字段无法显示NodeIP！
  rules:
  - host: "test-nginx.k8s-ingress.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: nginx-service
            port:
              number: 80
---
#kubectl apply -f /data/kubernetes/yaml/test-nginx.yaml
#vim /data/kubernetes/yaml/test-tomcat.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tomcat-pod
  template:
    metadata:
      labels:
        app: tomcat-pod
    spec:
      containers:
      - name: tomcat
        image: tomcat:8.5-jre10-slim
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: tomcat-service
  namespace: default
spec:
  type: NodePort
  ports:
    - port: 8080
      name: tomcat
  selector:
    app: tomcat-pod
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tomcat-ingress
  namespace: default
spec:
  ingressClassName: nginx  #必须存在,否则ingress状态下Address字段无法显示NodeIP！
  rules:
  - host: "test-tomcat.k8s-ingress.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: tomcat-service
            port:
              number: 8080
---
#kubectl apply -f /data/kubernetes/yaml/test-tomcat.yaml

```

(1) 在本地电脑上配置hosts解析www.yonxin100.com域名IP为前端nginx主机的IP
C:\Windows\System32\drivers\etc\hosts
10.0.0.4 www.yonxin100.com

(2) 访问nginx代理ingress的nginx域名服务http://www.yonxin100.com/nginx/
(3) 访问nginx代理ingress的tomcat域名服务http://www.yonxin100.com/tomcat/

## 10. 安装其他k8s-master服务

部署Master0X 节点：将Master01所有K8s文件拷贝，删除如下文件，修改涉及配置启动所有服务即可~

master1：

```
scp -r /data/kubernetes/ k8s-master2:/data
scp -r /data/kubernetes/ k8s-master3:/data
scp -r ~/.kube/  k8s-master2:~
scp -r ~/.kube/  k8s-master3:~
```

master2-3：

```
 cp /data/kubernetes/bin/kubectl /usr/bin/
 cp /data/kubernetes/service/kube* /usr/lib/systemd/system/
 修改IP
vim /data/kubernetes/config/kube-apiserver.conf

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl restart kube-apiserver
systemctl status kube-apiserver
systemctl enable kube-controller-manager
systemctl restart kube-controller-manager
systemctl status kube-controller-manager
systemctl enable kube-scheduler
systemctl restart kube-scheduler
systemctl status kube-scheduler
systemctl enable kubelet
systemctl restart kubelet
systemctl status kubelet
systemctl enable kube-proxy
systemctl restart kube-proxy
systemctl status kube-proxy
```

```
# rm -f /data/kubernetes/config/kubelet.kubeconfig && rm -f /data/kubernetes/pki/kubelet*
# kubectl get csr                                                                          //查看kubelet证书请求(重要)
# kubectl certificate approve     node-csr-XXXXXXXX           //批准kubelet证书申请(重要)
```

## 11. 安装新的k8s-node服务

部署新Node节点：将Master01所有K8s文件拷贝，删除如下文件，修改kubelet/kube-proxy配置启动服务~

```
history scp -r ~/.kube/  k8s-node1:~
scp -r ~/.kube/  k8s-node1:~

```

```
# cp /data/kubernetes/bin/kubectl /usr/bin/
# cp /data/kubernetes/service/kube* /usr/lib/systemd/system/
# rm -f /data/kubernetes/config/kubelet.kubeconfig && rm -f /data/kubernetes/pki/kubelet* 
# kubectl get csr                                                                          //查看kubelet证书请求(重要)
# kubectl certificate approve     node-csr-XXXXXXXX           //批准kubelet证书申请(重要)
# kubectl label node [nodename] node-role.kubernetes.io/node=                   //给node打标签
```

## 12. 日常运维服务

### 1 如何把受损的etcd重新添加到集群

```
1.删除受损节点的成员信息
#etcdctl --endpoints="https://172.100.3.116:2379" --cacert=/data/etcd/cert/ca.pem --cert=/data/etcd/cert/etcd.pem --key=/data/etcd/cert/etcd-key.pem member remove fde9dd315b6d0b2
2.在受损节点上删除--data-dir存储的数据
[root@k8s-master2 ~]# rm -rf /data/etcd/data/*
3.在受损节点上重新加入集群
[root@k8s-master2 ~]# etcdctl member add etcd2 --peer-urls="https://172.100.3.117:2380" --endpoints="https://172.100.3.116:2379" --cacert=/data/etcd/cert/ca.pem --cert=/data/etcd/cert/etcd.pem --key=/data/etcd/cert/etcd-key.pem
4.修改受损节点etcd启动参数
将etcd.service的--initial-cluster-state启动参数，改为--initial-cluster-state=existing
5.重启受损节点服务
[root@k8s-master2 ~]# service etcd restart
```

