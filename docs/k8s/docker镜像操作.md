# 1. 镜像下载

```
docker pull registry.cn-hangzhou.aliyuncs.com/erictor888/jenkinsslave:v11-386
```



# 2. 镜像导出

```Bash
docker save -o gitlab-jh.tar  registry.gitlab.cn/omnibus/gitlab-jh:latest
```

# 3. 镜像导入

```Bash
docker load -i gitlab-jh.tar
```

# 4. 将容器打包为镜像

```SQL
Option        功能
-a        指定新镜像作者
-c        使用 Dockerfile 指令来创建镜像
-m        提交生成镜像的说明信息
-p        在 commit 时，将容器暂停

docker commit -a "eric" -m "create git img" ed54ac3a09ac eric:v1
```

# 5. 镜像构建

## 5.1 编写Dockerfile

```dockerfile
# base image （使用的基础镜像）
FROM alpine

# MAINTAINER （标明作者）
MAINTAINER www.eric.com 

#Yum install base programs
RUN 	sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
			apk update && \
			apk add --no-cache  bash curl git tar openjdk8  && \
			rm -rf /var/cache/apk/* 
ADD 	apache-maven-3.8.6-bin.tar.gz /opt
ADD 	/usr/bin/yq /usr/bin/yq

ENV		MAVEN_HOME /opt/apache-maven-3.8.6
ENV		PATH $MAVEN_HOME/bin:$PATH

```



## 5.2 构建

```bash
docker build -t registry.cn-hangzhou.aliyuncs.com/erictor888/jenkinsslave:v11-386 . -f Dockerfile-salve
```

## 5.3 测试

```bash
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock  --name myenkins registry.cn-hangzhou.aliyuncs.com/erictor888/jenkinsslave:v11-386 bash
```

## 5.4 上传

```bash
#修改名称
docker tag ID  新名称
#上传至阿里仓库
docker login --username=erictor888 registry.cn-hangzhou.aliyuncs.com
Password: Abc,123.
docker push registry.cn-hangzhou.aliyuncs.com/erictor888/jenkinsslave:v11-386
```

