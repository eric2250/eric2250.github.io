网站：https://minikube.sigs.k8s.io/docs/start/
中文网站：https://kubernetes.io/zh/docs/tutorials/hello-minikube/

#1.安装minikube#
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
#2安装Docker（all）

```
$ wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
$ yum -y install docker-ce-18.06.1.ce-3.el7
$ systemctl enable docker && systemctl start docker &&systemctl status docker
$ docker --version
Docker version 18.06.1-ce, build e68fc7a
#3.用minikube启动k8s单节点

##3.1新建用户赋予docker权限（因为minikube不能运行在root）
```
useradd eric
su - eric
sudo usermod -aG docker eric && newgrp docker
```
##3.2用minikube方式启动k8s
```
[eric@k8s-master ~]$ minikube start
* minikube v1.25.2 on Centos 7.9.2009
* Automatically selected the docker driver
* Starting control plane node minikube in cluster minikube
* Pulling base image ...
* Downloading Kubernetes v1.23.3 preload ...
    > preloaded-images-k8s-v17-v1...: 505.68 MiB / 505.68 MiB  100.00% 11.43 Mi
    > index.docker.io/kicbase/sta...: 379.06 MiB / 379.06 MiB  100.00% 4.91 MiB
! minikube was unable to download gcr.io/k8s-minikube/kicbase:v0.0.30, but successfully downloaded docker.io/kicbase/stable:v0.0.30 as a fallback image
* Creating docker container (CPUs=2, Memory=2200MB) ...
! This container is having trouble accessing https://k8s.gcr.io
* To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
* Preparing Kubernetes v1.23.3 on Docker 20.10.12 ...
  - kubelet.housekeeping-interval=5m
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

[eric@k8s-master ~]$alias kubectl="minikube kubectl --"
[eric@k8s-master ~]$ kubectl get po
No resources found in default namespace.
```
#4.验证环境

```
测试应用
	[root@k8s-master ~]# kubectl create deployment web --image=nginx
	[root@k8s-master ~]# kubectl scale deployment web --replicas=3
	[root@k8s-master ~]# kubectl get pods  -owide
	[root@k8s-master ~]# kubectl delete deployment web

```

#5.安装ingress
```
minikube addons enable ingress
```