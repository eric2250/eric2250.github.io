

# #

# 1. Centos 防火墙设置

## 1、查看防火墙的命令

1）查看防火墙的版本

```Bash
firewall-cmd --version
```

2）查看firewall的状态

```Bash
firewall-cmd --state
```

3）查看firewall服务状态（普通用户可执行）

```Bash
systemctl status firewalld
```

4）查看防火墙全部的信息

```Bash
firewall-cmd --list-all
```

5）查看防火墙已开通的端口

```Bash
firewall-cmd --list-port
```

6）查看防火墙已开通的服务

```Bash
firewall-cmd --list-service
```

7）查看全部的服务列表（普通用户可执行）

```Bash
firewall-cmd --get-services
```

8）查看防火墙服务是否开机启动

```Bash
systemctl is-enabled firewalld
```

## 2、配置防火墙的命令

### firewall配置

###  1）启动、重启、关闭防火墙服务

启动

```Bash
systemctl start firewalld
```

重启

```Bash
systemctl restart firewalld
```

关闭

```Bash
systemctl stop firewalld
```

\#查看状态

```Bash
systemctl status firewalld
```

### 2）开放、移去某个端口

开放80端口

```Bash
firewall-cmd --zone=public --add-port=80/tcp --permanent
#移去80端口
firewall-cmd --zone=public --remove-port=80/tcp --permanent
```

### 3）开放、移去范围端口

开放5000-5500之间的端口

```Bash
firewall-cmd --zone=public --add-port=5000-5500/tcp --permanent
#移去5000-5500之间的端口
firewall-cmd --zone=public --remove-port=5000-5500/tcp --permanent
```

### 4）开放、移去服务

开放ftp服务

```Bash
firewall-cmd --zone=public --add-service=ftp --permanent
#移去http服务
firewall-cmd --zone=public --remove-service=ftp --permanent
```

### 5）重新加载防火墙配置（修改配置后要重新加载防火墙配置或重启防火墙服务）

```Bash
firewall-cmd --reload
```

### 6）设置开机时启用、禁用防火墙服务

启用服务

```Bash
systemctl enable firewalld
```

禁用服务

```Bash
systemctl disable firewalld
```

### Iptables配置

### 1）开放80，22，8080 端口

```Bash
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 22 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
#查看开通端口
iptables -L -n
#清空防火墙
iptables -F
```

### 2）保存

```Bash
/etc/rc.d/init.d/iptables save
```

### 3）查看运行状态

```Bash
/etc/init.d/iptables status
```

### 4）启动、关闭防火墙服务

启动服务

```Bash
service iptables start
```

关闭服务

```Bash
service iptables stop
```

### 5）设置开机时启用、禁用防火墙服务

启用服务

```Bash
chkconfig iptables on
```

禁用服务

```Bash
chkconfig iptables off
```

## 3. 关闭防火墙和seLinux

```Bash
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
# 关闭selinux
sed -i 's/enforcing/disabled/' /etc/selinux/config  # 永久
setenforce 0  # 临时
getenforce #  查看
```

# 2. Ubuntu 防火墙设置

1 查看防火墙状态：inactive是关闭，active是开启。

```Bash
sudo ufw status
```

2、使用`sudo ufw enable`开启防火墙。

```Bash
sudo ufw enable
```

3、使用`sudo ufw disable`关闭防火墙

```Bash
sudo ufw disable
```

