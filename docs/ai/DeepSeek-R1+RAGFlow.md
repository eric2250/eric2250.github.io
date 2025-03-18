# [DeepSeek R1+RAG，基于开源三件套构建本地AI知识库（文末附笔记及教学材料）](https://bbs.fit2cloud.com/t/topic/10745)

## 1.安装1Panel

### 下载：

https://1panel.cn/docs/installation/package_installation/

### 离线安装：

```
wget https://cdn0-download-offline-installer.fit2cloud.com/1panel/1panel-v1.10.26-lts-linux-amd64.tar.gz?Expires=1741497180&OSSAccessKeyId=LTAI5tNm6eCXpZo6cgoJet2h&Signature=mm7K4pV8xDxAexthPd91l%2FJRoyQ%3D
# tar zxvf 1panel-v1.10.26-lts-linux-amd64.tar.gz
# chmod +x install.sh 
# ./install.sh 
 ██╗    ██████╗  █████╗ ███╗   ██╗███████╗██╗     
███║    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║     
╚██║    ██████╔╝███████║██╔██╗ ██║█████╗  ██║     
 ██║    ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║     
 ██║    ██║     ██║  ██║██║ ╚████║███████╗███████╗
 ╚═╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
[1Panel Log]: ======================= 开始安装 ======================= 
设置1Panel安装目录 (默认为/opt): /data
设置1Panel端口 (默认是 33363): 30888
[1Panel Log]: 您设置的端口是:  30888 
[1Panel Log]: 正在打开防火墙端口 30888 
success
success
设置1Panel安全入口 (默认是 56dc10cf96): my1panel
[1Panel Log]: 设置1Panel安全入口 (默认是 1qaz2wsx 
设置1Panel面板用户 (默认是 631da21283): eric
[1Panel Log]: 您设置的面板用户是 eric 
[1Panel Log]: 设置1Panel面板密码，设置后按回车键继续 (默认是 f6c2d4fe7d):  
********
[1Panel Log]: 正在配置1Panel服务 
Created symlink from /etc/systemd/system/multi-user.target.wants/1panel.service to /etc/systemd/system/1panel.service.
[1Panel Log]: 正在启动1Panel服务 
[1Panel Log]: 1Panel服务已成功启动！ 
[1Panel Log]:  
[1Panel Log]: =================感谢您的耐心等待，安装已完成================== 
[1Panel Log]:  
[1Panel Log]: 请使用您的浏览器访问面板:  
[1Panel Log]: 外部地址:  http://120.244.216.82:30888/1qaz2wsx 
[1Panel Log]: 内部地址:  http://192.168.3.150:30888/1qaz2wsx 
[1Panel Log]: 面板用户:  eric 
[1Panel Log]: 面板密码:  1qaz2wsx 
[1Panel Log]:  
[1Panel Log]: 官方网站: https://1panel.cn 
[1Panel Log]: 项目文档: https://1panel.cn/docs 
[1Panel Log]: 代码仓库: https://github.com/1Panel-dev/1Panel 
[1Panel Log]: 前往 1Panel 官方论坛获取帮助: https://bbs.fit2cloud.com/c/1p/7 
[1Panel Log]:  
[1Panel Log]: 如果您使用的是云服务器，请在安全组中打开端口 30888 
[1Panel Log]:  
[1Panel Log]: 为了您的服务器安全，离开此屏幕后您将无法再次看到您的密码，请记住您的密码。 
[1Panel Log]:  
[1Panel Log]: ================================================================ 

```

启动，重启

[命令行工具 - 1Panel 文档](https://1panel.cn/docs/installation/cli/)

```
1pctl restart
1pctl start
```

配置docker加速

```
cat >> /etc/docker/daemon.json <<-EOF
{
  "registry-mirrors": [
   "https://docker.1ms.run",
    "https://proxy.1panel.live",
    "https://9f73jm5p.mirror.aliyuncs.com",
    "https://docker.ketches.cn",
    "http://74f21445.m.daocloud.io",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
  ], 
  "insecure-registries": ["kubernetes-register.sswang.com"], 
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
cat /etc/docker/daemon.json

```



### 访问：http://192.168.3.150:30888/1qaz2wsx



## 2. 安装ollama

[ollama/docs/linux.md at main · ollama/ollama · GitHub](https://github.com/ollama/ollama/blob/main/docs/linux.md)

```
curl -L https://ollama.com/download/ollama-linux-amd64.tgz -o ollama-linux-amd64.tgz
sudo tar -C /usr -xzf ollama-linux-amd64.tgz
#Start Ollama:
ollama serve
ollama -v
```



拉取镜像：

```
docker pull ollama/ollama:0.5.7
docker pull 1panel/maxkb:v1.10.0-lts
```



需要注意的是，Ollama 容器如果想使用服务器的 GPU 资源，操作系统需要提前安装 NVIDIA Container Toolkit，这是 NVIDIA 容器工具包。以 CentOS 7.9 操作系统为例，安装步骤如下：
1、添加 NVIDIA 的 GPG 密钥和仓库：

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo
```

2、安装 NVIDIA Container Toolkit：
`sudo yum install -y nvidia-container-toolkit`
3、重启 Docker 服务：
`sudo systemctl restart docker`



windows下安装:



下载软件安装：[Ollama](https://ollama.com/)

配置环境变量：

```
OLLAMA_HOST 0.0.0.0:11434
OLLAMA_MODELS D:\Ollama\models
```

安装deekseek模型:

[deepseek-r1](https://ollama.com/library/deepseek-r1)

```
ollama run deepseek-r1:1.5b
```

## 3.安装ragflow：

[GitHub - infiniflow/ragflow: RAGFlow is an open-source RAG (Retrieval-Augmented Generation) engine based on deep document understanding](https://github.com/infiniflow/ragflow)

```
$ git clone https://github.com/infiniflow/ragflow.git
#注释84行，打开87行
# vim  docker/.env
 84 #RAGFLOW_IMAGE=infiniflow/ragflow:v0.17.0-slim
 87  RAGFLOW_IMAGE=infiniflow/ragflow:v0.17.
```

安装docker-compose：

[Releases · docker/compose](https://github.com/docker/compose/releases)

```
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')" /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo curl -L https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

```
 docker-compose -f docker-compose.yml up -d
```

### 访问配置绑定自己模型：

随便注册一个账号登录成功，点击进入点击头像，点击模型提供商，点击Ollama添加deepseek模型

![image-20250317140231695](D:\code\docs\eric2250.github.io\docs\images\ai\image-20250317140231695.png)

填写信息：

```
deepseek-r1:1.5b

http://172.100.3.106:11434
```

![image-20250317140904790](D:\code\docs\eric2250.github.io\docs\images\ai\image-20250317140904790.png)

选择部署的模型



进入知识库配置



上传知识库文件，点击解析。



配置聊天助手，点击-聊天-新建助手-填写名称-选择知识库



新建聊天，输入问题开始聊天



### 添加其他在线模型

点击头像-选择模型

填写apikey

修改模型选择

