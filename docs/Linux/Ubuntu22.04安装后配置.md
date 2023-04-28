# 1. 开启远程登录

## 1.1 以普通用户登录系统，创建root用户的密码

```Bash
# sudo passwd root
#安装sshd
#apt install openssh-server
```

## 1.2 修改配置

```Bash
# sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
# sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
#打开/root/.profile
#注释mesg n 2 > /dev/null || true
#加上tty -s && mesg n || true
#------------------
root@devops:~# cat .profile 
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

#mesg n 2> /dev/null || true
tty -s && mesg n || true
#--------------------------
```

## 1.3 重启sshd

```Bash
systemctl restart sshd
```

# 2. 换源

[ubuntu镜像_ubuntu下载地址_ubuntu安装教程-阿里巴巴开源镜像站 (aliyun.com)](https://developer.aliyun.com/mirror/ubuntu?spm=a2c6h.13651102.0.0.3e221b11HKpKGX)

```Bash
sed -i 's/https:\/\/mirrors.aliyun.com/http:\/\/mirrors.cloud.aliyuncs.com/g' /etc/apt/sources.list
deb https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
```

# 3. 语言设置

```Bash
vim /etc/locale.gen
    en_US.UTF-8 UTF-8   (英语)
    zh_CN.UTF-8 UTF-8   (中文"如果被注释放开即可")
 vi /etc/default/locale  
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN:zh"
```

# 4. 修改网卡

## 4.1 修改配置文件

```Bash
cd /etc/netplan
cp 00-installer-config.yaml 00-installer-config.yaml.old

vim 00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 172.100.3.129/24 #虚拟机局域网IP地址，需跟window的有线网卡处于同一网段
      routes:
        - to: default
          via: 172.100.3.254 #本机局域网网关地址，需跟window的有线网卡设置相同
          metric: 200
      nameservers:
        addresses:
          - 172.100.2.201
          - 114.114.114.114
  version: 2




#====================================
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens33:
      dhcp4: false
      addresses:
        - 192.168.1.27/24 #虚拟机局域网IP地址，需跟window的有线网卡处于同一网段
      routes:
        - to: default
          via: 192.168.1.1 #本机局域网网关地址，需跟window的有线网卡设置相同
          metric: 200
      nameservers:
        addresses:
          - 114.114.114.114
          - 8.8.8.8
    ens37:
      dhcp4: false
      addresses:
        - 192.168.62.27/24 #与1-d步骤 NAT设置中的 网关IP处于同一网段
      routes:
        - to: default
          via: 192.168.62.2 #与1-d步骤 NAT设置中的 网关IP一致
          metric: 100
      nameservers:
        addresses:
          - 114.114.114.114
          - 8.8.8.8
```

## 4.2 应用（重启）

```JSON
netplan apply 
```