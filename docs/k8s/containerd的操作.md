## 1. containerd的ctr怎么构建、拉取、上传镜像

ctr是一个用于管理containerd的命令行工具，可以用它来打包、拉取、上传镜像。以下是具体操作步骤：

1. 构建镜像：通过docker或者其他方式构建好一个镜像之后，可以使用ctr命令来打包该镜像：

```
#ctr images build -t <镜像名:标签> -f <Dockerfile路径> .
#如
ctr images build -t registry.cn-hangzhou.aliyuncs.com/erictor888/alpine-mvn:v3.8.6 .
```

2. 拉取镜像：可以使用ctr命令来拉取一个镜像：

```
#ctr images pull [image_name]
#例如：
ctr images pull docker.io/library/ubuntu:latest
```

3. 上传镜像：可以使用ctr命令来上传一个本地镜像到镜像仓库：

```
#ctr images push [image_name]
#例如：
ctr images push docker.io/myrepo/myimage:latest
```

​      需要注意的是，需要先登录到仓库并获取授权，才能上传镜像。可以使用ctr命令的login子命令来登录仓库，例如：

```
ctr login docker.io -u myusername -p mypassword
```

## 2. 镜像的导出导入

```
#导出
ctr -n k8s.io i export  node.tar docker.io/calico/node:v3.26.0
#导入
ctr -n k8s.io images import coredns-v1.10.1.tar.gz 
ctr images list
#查看
crictl img
```



## 3. nerdctl+buildkit+containerd实现容器镜像打包

#### 背景

众所周知，docker运行需要常驻后台，并且需要root权限，并且在使用效率方面，没有其他容器运行时来得高效，K8s1.24版本开始已经不支持docker作为默认的容器运行时，前段时间测试了将容器运行时换成containerd的，今天再测试将容器镜像管理客户端工具替换成nerdctl,而nerdctl本身是不能直接进行镜像构建的，需要buildkit作为构建工具，下面记录实现步骤

#### 客户端安装

安装nerdctl
下载地址

```
https://github.com/containerd/nerdctl/releases/download/v1.4.0/nerdctl-1.4.0-linux-amd64.tar.gz
```

解压后得到nerdctl可执行文件，直接复制到/usr/bin,并给予执行权限chmod +x /usr/bin/nerdctl

安装buildkt
下载地址

```
https://github.com/moby/buildkit/releases/download/v0.11.6/buildkit-v0.11.6.linux-amd64.tar.gz
```

解压后得到一系列build开头的进进制文件，分别将他们移到/usr/bin/并添加可执行权限

#### 用参数启动

使用 --oci-worker=false --containerd-worker=true 参数,可以让buildkitd服务使用containerd后端

```bash
buildkitd --oci-worker=false --containerd-worker=true & 
```

#### 使用配置文件启动

创建配置文件

```text
mkdir -p /etc/buildkit/
vim /etc/buildkit/buildkitd.toml
```

配置使用containerd后端，禁用oic后端，并把默认名字空间改为"default"(这是为了以后和nerdctl配合使用)，把平台限制为本机类型amd64，配置垃圾回收空间限制

```text
[worker.oci]
  enabled = false

[worker.containerd]
  enabled = true
  # namespace should be "k8s.io" for Kubernetes (including Rancher Desktop)
  namespace = "default"
  platforms = [ "linux/amd64" ]
  gc = true
  # gckeepstorage sets storage limit for default gc profile, in MB.
  gckeepstorage = 9000
```

用此配置启动服务

```text
buildkitd --config /etc/buildkit/buildkitd.toml & 
```





```
containerd config default > /etc/containerd/config.toml
```

配置允许私人仓库登陆
vi /etc/containerd/config.toml
添加

        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.xxx.com"]
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.xxx.com".tls]
          insecure_skip_verify = true

添加后重启containerd

```
systemctl restart containerd
```

### 4.构建测试demo镜像

编写Dockerfile

```
# base image （使用的基础镜像）
FROM registry.cn-hangzhou.aliyuncs.com/erictor888/alpine-mvn:v3.8.6

# MAINTAINER （标明作者）
MAINTAINER www.eric.com 

#Yum install base programs
ADD kubectl /usr/local/bin
RUN chmod +x /usr/local/bin/kubectl
```

构建镜像
```
nerdctl build -t registry.cn-hangzhou.aliyuncs.com/erictor888/alpine-mvn:v3.8.7 .
```

查看

```
nerdctl run --rm -it registry.cn-hangzhou.aliyuncs.com/erictor888/alpine-mvn:v3.8.7 bash
bash-5.1# kubectl 

```

上传到harbor镜像仓库

```
nerdctl login -u admin -p "xxx" harbor.xxx.com
nerdctl push harbor.xxx.com/xxx/xxx:2022016
```

