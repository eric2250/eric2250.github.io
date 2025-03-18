# [DPanel](https://dpanel.cc/)

## 1.1panel

配置参考：https://bbs.fit2cloud.com/t/topic/10745

### 1.下载

离线包下载链接: https://community.fit2cloud.com/#/products/1panel/downloads

```
wget https://cdn0-download-offline-installer.fit2cloud.com/1panel/1panel-v1.10.26-lts-linux-amd64.tar.gz?Expires=1741585272&OSSAccessKeyId=LTAI5tNm6eCXpZo6cgoJet2h&Signature=iEhSEYJywOMZK7%2FR7fBsiz5%2BxVA%3D
```

### 2.安装

```
]# sh install.sh 
Select a language:

1. English
2. Chinese  中文(简体)
3. Persian
4. Português (Brasil)
5. Русский
   Enter the number corresponding to your language choice: 2
   You selected:  Chinese  中文(简体)
    ██╗    ██████╗  █████╗ ███╗   ██╗███████╗██╗     
   ███║    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║     
   ╚██║    ██████╔╝███████║██╔██╗ ██║█████╗  ██║     
    ██║    ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║     
    ██║    ██║     ██║  ██║██║ ╚████║███████╗███████╗
    ╚═╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
   [1Panel Log]: ======================= 开始安装 ======================= 
   设置1Panel安装目录 (默认为/opt): /data
   [1Panel Log]: ... 在线安装Docker 

[1Panel Log]: Docker安装成功

Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /etc/systemd/system/docker.service.
设置1Panel端口 (默认是 33620): 
[1Panel Log]: 您设置的端口是:  33620 
[1Panel Log]: 正在打开防火墙端口 33620 
success
success
设置1Panel安全入口 (默认是 aaa873651e): eastport
[1Panel Log]: 设置1Panel安全入口 (默认是 eastport 
设置1Panel面板用户 (默认是 e2f4f3e2ea): admin
[1Panel Log]: 您设置的面板用户是 admin 
[1Panel Log]: 设置1Panel面板密码，设置后按回车键继续 (默认是 7c58438456):  

********

[1Panel Log]: 正在配置1Panel服务

Created symlink from /etc/systemd/system/multi-user.target.wants/1panel.service to /etc/systemd/system/1panel.service.

[1Panel Log]: 正在启动1Panel服务
[1Panel Log]: 1Panel服务已成功启动！

[1Panel Log]:  

[1Panel Log]: =================感谢您的耐心等待，安装已完成==================

[1Panel Log]:  

[1Panel Log]: 请使用您的浏览器访问面板:

[1Panel Log]: 外部地址:  http://218.244.55.14:33620/eastport 
[1Panel Log]: 内部地址:  http://172.100.3.106:33620/eastport 
[1Panel Log]: 面板用户:  admin 
[1Panel Log]: 面板密码:  1234qwer 
[1Panel Log]:  
[1Panel Log]: 官方网站: https://1panel.cn 
[1Panel Log]: 项目文档: https://1panel.cn/docs 
[1Panel Log]: 代码仓库: https://github.com/1Panel-dev/1Panel 
[1Panel Log]: 前往 1Panel 官方论坛获取帮助: https://bbs.fit2cloud.com/c/1p/7 
[1Panel Log]:  
[1Panel Log]: 如果您使用的是云服务器，请在安全组中打开端口 33620 
[1Panel Log]:  

[1Panel Log]: 为了您的服务器安全，离开此屏幕后您将无法再次看到您的密码，请记住您的密码。

[1Panel Log]:  

[1Panel Log]: ================================================================
```



## 2.Dpanel

### 1.安装

[Docker](https://dpanel.cc/#/zh-cn/install/docker)

```
docker run  --name dpanel --restart=always \
 -p 80:80 \
 -p 443:443 \
 -p 8807:8080 \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v /home/dpanel:/dpanel \
 -e APP_NAME=dpanel \
 -d registry.cn-hangzhou.aliyuncs.com/dpanel/dpanel:latest
 
 
 docker run -d --name dpanel --restart=always \
 -p 8807:8080 -e APP_NAME=dpanel \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v /home/dpanel:/dpanel registry.cn-hangzhou.aliyuncs.com/dpanel/dpanel:lite
```

