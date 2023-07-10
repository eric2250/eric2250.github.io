# 1.安装nfs #
```
yum install -y nfs-utils

mkdir -p /data/nfs
chmod 777 /data/nfs
vi /etc/exports
/data/nfs *(rw,sync,no_root_squash)

systemctl restart rpcbind &&systemctl restart nfs
systemctl enable rpcbind &&systemctl enable nfs
```
# 2.创建工作空间 #
```
kubectl create ns devops
namespace/devops created

```
# 3.安装Jenkins #
## 1.新建jenkins master端 ##
修改添加设置继承主机dns实现上网功能
```
      dnsPolicy: Default
```
```
kubectl apply -f jenkins.yaml

deployment.apps/jenkins created
serviceaccount/jenkins created
service/jenkins created
role.rbac.authorization.k8s.io/jenkins created
rolebinding.rbac.authorization.k8s.io/jenkins created

```
## 2.创建ingress实现域名访问 ##
```
# kubectl apply -f ingress/ingress-controller.yaml
# kubectl apply -f ingress/ingress.yaml
ingress.networking.k8s.io/devops-ingress created
```
## 3.查看状态 ##
```
# kubectl get po,svc,ing -n devops
NAME                           READY   STATUS    RESTARTS   AGE
pod/jenkins-7f49859bb6-dq9bx   1/1     Running   0          8m11s

NAME              TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                           AGE
service/jenkins   NodePort   10.100.241.96   <none>        30011:31000/TCP,30081:30081/TCP   8m11s

NAME                                       CLASS    HOSTS                                 ADDRESS   PORTS   AGE
ingress.networking.k8s.io/devops-ingress   <none>   jenkins.eric.com,sonarqube.eric.com             80      4s
```
## 4.访问测试 http://jenkins.eric.com/ ##
需要配置hosts文件
```
C:\Windows\System32\drivers\etc
192.168.88.12 jenkins.eric.com sonarqube.eric.com gitlab.eric.com harbor.eric.com 
```
jenkins插件更换
```
https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
安装插件：
Kubernetes
Timestamp
ansiColor 
```
## 5.配置Jenkins静态slave ##
在node节点上执行修改权限，不然进入pod会报权限不足
```
chown 1000.1000 ~/.kube/config
chown 1000.1000 /var/run/docker.sock
```
在Jenkins添加slave节点修改yaml对应内容，创建slave deployment
```
48           env:
 49             - name: JENKINS_URL
 50               value: http://192.168.88.12:31000
 51             - name: JENKINS_SECRET
 52               value: 00484d805f99783e86c286ce02f335746f8841f6624cd495b4180c40ba6ac41f
 53             - name: JENKINS_AGENT_NAME
 54               value: k8s
 55             - name: JENKINS_AGENT_WORKDIR
 56               value: /home/jenkins/workspace

kubectl apply  -f jenkinsslave.yml
```


## 6.配置Jenkins与kubernetes实现动态slave ##
```
1.Jenkins安装kubernetes插件

2.系统管理->系统配置->Add a new cloud(最下面)
  Jenkins2.340后在-系统管理-节点管理-配置集群

3.配置地址信息
- kubernetes名称：kubernetes
- kubernetes地址：https://192.168.88.11:6443/或https://kubernetes.default    https://kubernetes.default.svc.cluster.local
- Kubernetes 命名空间:devops
- 凭据:之前登录Dashboard所用的key
	kubectl describe secret dashboard-admin-token-rh8hd -n kube-system
- Jenkins 地址：http://192.168.88.12:31000 （ IP和端口 配置ingress地址不行（大坑）） http://jenkins.devops.svc.cluster.local
- Jenkins 通道：10.100.105.224:50000 可以为空 （CLUSTER-IP：端口 ，端口为全局安全设置-代理设置端口，默认50000） (查看地址docker inspect e5d8274b729f |grep _8080)
- 以上如果要配置域名需要配置dns解析或hosts
- yaml 添加以下与containers同级
      hostAliases:
      - ip: "192.168.88.12"
        hostnames:
        - "harbor.eric.com"
        - "jenkins.eric.com"
      - ip: "192.168.88.13"
        hostnames:
        - "harbor.eric.com"
        - "jenkins.eric.com"
      containers:


4.配置Pod Template
- 名称：jnlp-slave
- 名称空间：devops（Jenkins运行的命名空间）
- 标签列表：jnlp-slave （和Jenkinsfile agent label 保持一致： agent {label 'jnlp-slave'}）
- 节点选择器:agent=true  （打标签 kubectl label node k8s-node1 agent=true ）
- 工作空间卷：1 host path workspace volume ：/data/nfs/jenkins-slave(权限修改chown -R 1000:1000 /data/nfs/jenkins-slave)
		   ：2 Nfs Workspace volume ：服务地址：192.168.88.11 服务路径：/data/nfs/jenkins-slave

5.容器列表（包含在Pod Template中）
容器1
- 名称:jenkins
- Docker 镜像:registry.cn-hangzhou.aliyuncs.com/erictor888/alpine-mvn:v3.8.6(自定义镜像)（我将所有构建放到基本容器上了可以不用）
- 其他默认
容器2（固定格式）
- 名称:jnlp
- Docker 镜像:jenkins/inbound-agent:4.11-1-jdk11
- 命令：空
- 命令参数：空     ${computer.jnlpmac} ${computer.name}（ 查看镜像参数 docker inspect 52b4d160ebcf|grep "Cmd"）
容器3
- 名称:k8s
- Docker 镜像:registry.cn-hangzhou.aliyuncs.com/erictor888/alpine-kubectl:v1(自定义镜像)（执行kubectl）
- 其他默认
- 
卷（为了容器里能正常启动docker）

- 主机路径：/var/run/docker.sock
- 挂载路径：/var/run/docker.sock

- 主机路径：/usr/bin/docker
- 挂载路径：/usr/bin/docker
- 
为了容器里能正常运行kubectl
- 主机路径：/usr/bin/kubectl
- 挂载路径：/usr/bin/kubectl
- 
- 主机路径：/root/.kube/config
- 挂载路径：/home/jenkins/.kube/config
全局工具目录：
- NFS Volume
- 服务地址：192.168.88.11
- 服务路径：/data/nfs/app
- 挂载路径：/home/jenkins/buildtools

maven m2目录：
- NFS Volume
- 服务地址：192.168.88.11
- 服务路径：/data/nfs/m2
- 挂载路径：/home/jenkins/.m2



```
```
Raw YAML for the Pod：(实现容器访问外网)
--------------------------
apiVersion: v1
kind: Pod
metadata:
  name: ad
spec:
  containers:
  - image: jenkins/inbound-agent:4.11-1-jdk11
    command:
      - sleep
      - "10000"
    imagePullPolicy: Always
    name: ad
  dnsPolicy: None
  dnsConfig:
    nameservers: ["114.114.114.114"]
    searches:
    - default.svc.cluster.local
    - svc.cluster.local
    - cluster.local
    options:
    - name: ndots
      value: "2"

---------------------------
```
# 3.部署sonarqube #
准备（nodes上执行）：
```
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192
```
## 1.新建工作目录 ##
方法1：本地挂载
```
mkdir -p /data/nfs/sonar/extensions
mkdir -p /data/nfs/sonar/data
mkdir -p /data/nfs/sonar/logs
mkdir -p /data/nfs/sonar/conf

chmod 777 -R /data/nfs/sonar/
```
方法2：用storageclass方式，提前部署sc
```
 kubectl apply -f storageclass/nfs-provisioner.yaml
# kubectl get sc
NAME                  PROVISIONER    RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-csi   eric.com-nfs   Delete          Immediate           false                  17h
```
## 2.部署sonarqube ##
```
 kubectl apply -f postgresql.yaml
 kubectl  apply -f sonarqube.yml

```
报错处理： chown: changing ownership of '/var/lib/postgresql/data': Operation not permitted
nfs添加 no_root_squash，如 /data/nfs *(rw,sync,no_root_squash)
## 3.访问并安装中文 ##
http://sonarqube.eric.com/
Chinese Pack

## 4.新建token和Jenkins集成 ##

0aa87fb17d7437a5d9e078a6c3d35671d112be90


# 4.部署gitlab #
## 1.创建工作目录 ##
```
mkdir -p /data/nfs/gitlab/config
mkdir -p /data/nfs/gitlab/logs
mkdir -p /data/nfs/gitlab/data

chmod 777 -R /data/nfs/gitlab
```
## 2.部署 ##
```
 kubectl apply -f gitlab.yaml

```
## 3.访问设置 ##

访问：http://gitlab.eric.com/

初始用户名为root，初始密码gitlib自动创建，在如下文件中：
/etc/gitlab/initial_root_password

# 5.部署gitea #
## 1.创建工作目录 ##
```
mkdir -p /data/nfs/gitea

chmod 777 -R /data/nfs/gitea
```
## 2.部署 ##
```
 kubectl apply -f gitea.yaml

```
## 3.访问设置 ##

访问：http://gitea.eric.com/
```
修改：
SSH 服务域名 ：gitea.eric.com
基础URL：http://gitea.eric.com/

管理员用户名 eric
管理员密码 gwqgwq
确认密码 gwqgwq
电子邮件地址 eric@eric.com

其他默认
```
# 6.ladp认证配置




# 附： #
## jdk配置

```
export JAVA_HOME=/data/nfs/jenkins/app/jdk-11
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH
```
