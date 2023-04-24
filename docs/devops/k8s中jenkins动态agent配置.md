1.Jenkins安装kubernetes插件

2.系统管理->系统配置->Add a new cloud(最下面)
  Jenkins2.340后在-系统管理-节点管理-配置集群

3.配置地址信息
- kubernetes名称：kubernetes
- kubernetes地址：https://192.168.88.80:6443/或https://kubernetes.default
- Kubernetes 命名空间:eric-ci
- 凭据:之前登录Dashboard所用的key
	kubectl describe secret dashboard-admin-token-rh8hd -n kube-system
- Jenkins 地址：http://jenkins.eric.com/
- Jenkins 通道：jenkins:50000 （固定写法，端口为全局安全设置-代理设置端口，默认50000，因为k8s映射端口是35000）
4.配置Pod Template
- 名称：jnlp-slave
- 名称空间：eric-ci（Jenkins运行的命名空间）
- 标签列表：jnlp-slave （和Jenkinsfile agent label 保持一致： agent {label 'jnlp-slave'}）
- 节点选择器:agent=true  （打标签 kubectl label node k8s-node1 agent=true ）
- 工作空间卷：host path workspace volume ：/data/jenkins_jobs(权限修改chown -R 1000:1000 /data/jenkins_jobs/)

5.容器列表（包含在Pod Template中）
容器1
- 名称:jenkins
- Docker 镜像:192.168.88.80:8888/sw/myjenkins-slave:v1(自定义镜像)
容器2（固定格式）
- 名称:jnlp
- Docker 镜像:jenkins/inbound-agent:4.11-1-jdk11
- 命令参数：jenkins-slave
卷（为了容器里能正常启动docker）
- 主机路径：/var/run/docker.sock
- 挂载路径：/var/run/docker.sock

















