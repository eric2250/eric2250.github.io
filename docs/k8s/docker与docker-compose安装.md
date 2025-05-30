# 1. 安装docker

## 1.1 ubuntu

```Bash
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io 
```

## 1.2 centos

```Bash
#下载安装源
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
yum list docker-ce --showduplicates | sort -r
yum -y install docker-ce-20.10.0-3.el7 docker-ce-cli-20.10.0-3.el7 docker-ce-rootless-extras-20.10.0-3.el7
systemctl enable docker && systemctl start docker &&systemctl status docker
docker --version

cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": ["https://kzjowymh.mirror.aliyuncs.com"],
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

vim /etc/docker/daemon.json
{
        "insecure-registries": ["https://harbor.eric.com"],
        "registry-mirrors": ["https://kzjowymh.mirror.aliyuncs.com"],
        "exec-opts": ["native.cgroupdriver=systemd"]
}

sudo systemctl daemon-reload
sudo systemctl restart docker
#用户使用docker
# 将该用户添加到docker组 --> gpasswd -a 用户名 用户组
gpasswd -a jenkins docker
# 切换到该用户
su jenkins -
# 将当前用户切换到docker组
newgrp - docker
```

## 1.3中标麒麟

```
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# 官方仓库地址（可能需要网络访问权限）
wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo

# 若网络受限，可替换为国内镜像源，如阿里云仓库
wget -O /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo sed -i 's/$releasever/7/g' /etc/yum.repos.d/docker-ce.repo
sudo yum clean all && sudo yum makecache

sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
docker --version



```

离线安装：

```
#下载解压
wget --no-check-certificate https://download.docker.com/linux/static/stable/x86_64/docker-26.0.0.tgz 
tar zxvf docker-26.0.0.tgz 
mv docker/* /usr/bin/
cat > /usr/lib/systemd/system/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start docker
systemctl status docker
docker -v
mkdir -p /etc/docker/
cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": ["https://kzjowymh.mirror.aliyuncs.com"],
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl restart docker

```



# 2. 安装 docker compose 命令：

https://github.com/docker/compose/releases

```Bash
sudo curl -L https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

# 3. 设置容器开机启动

```Bash
docker update --restart=always 容器id
```

# 4. 修改docker默认存储路径方法

默认情况下，docker镜像的默认存储路径是/var/lib/docker，我们想更改为自己的目录

查看docker的路径：

```Bash
[root@ep-jenkins apps]# docker info |grep "Root Dir"
WARNING: bridge-nf-call-iptables is disabled
WARNING: bridge-nf-call-ip6tables is disabled
 Docker Root Dir: /var/lib/docker
```

 修改docker的默认路径，有三种方法

先创建新的docker目录

```Bash
mkdir /apps/docker
```

## 1、修改docker.service

```Bash
vim /usr/lib/systemd/system/docker.service
#在里面的EXECStart的后面增加--graph /home/docker:
...
ExecStart=/usr/bin/dockerd  -H fd:// --containerd=/run/containerd/containerd.sock  --graph /home/docker
...

#重新加载服务重启
systemctl enable docker
systemctl daemon-reload
systemctl restart docker
```

 

## 2、修改daemon.json

编辑配置文件/etc/docker/daemon.json添加 "data-root": "/data/docker

```Bash
vim /etc/docker/daemon.json
 
{
  "registry-mirrors": ["https://registry.docker-cn.com"],
  "data-root": "/data/docker"
  "log-driver":"json-file",
  "log-opts": {"max-size":"100m"}
}


systemctl restart docker
```

## 3、使用软链接

使用软链接需要先把/var/lib下的docker目录删除，删除之前记得迁移数据。然后用下面命令创建软链接

```Bash
systemctl stop docker
mv /var/lib/docker  /apps
ln -s /apps/docker/ /var/lib/

systemctl start docker
#查看
docker info |grep "Root Dir"
 Docker Root Dir: /apps/docker
```

# 5.开启2375远程连接
```
~]# cat /etc/docker/daemon.json 
{
    "registry-mirrors":[
    "https://kzjowymh.mirror.aliyuncs.com",
    "https://docker.1ms.run",
    "https://proxy.1panel.live",
    "https://docker.ketches.cn"
    ],
    "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
   
}

systemctl daemon-reload && systemctl restart docker
```