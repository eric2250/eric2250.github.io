#1.手动配置
```
nmcli connection modify ens160 connection.autoconnect yes
nmcli connection modify ens160 ipv4.method manual ipv4.addresses 192.168.88.81/24
nmcli connection modify ens160 ipv4.gateway 192.168.88.2
nmcli connection modify ens160 ipv4.dns 114.114.114.114
reboot
```
#2.修改配置yum
```
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
```
#3.安装软件
```
dnf -y install vim wget
```
#4.搭建 NFS 服务器
sudo dnf install nfs-utils
sudo systemctl enable --now nfs-server
## 默认情况下，在 CentOS 8 上启用 NFS 版本 3 和 4.x，禁用版本 2。NFSv2 现在已经很老了，没有理由启用它。要验证它，请运行以下cat 命令：
sudo cat /proc/fs/nfsd/versions

NFS 服务器配置选项在 /etc/nfsmount.conf 和 /etc/nfs.conf 文件中设置。默认设置足以满足我们的教程。

创建输出目录
sudo mkdir -p /data/nfs
##选择你要授权的用户
sudo chown nobody:nogroup /data/nfs
sudo chmod 777 /data/nfs

授予客户端机器访问 NFS 服务器的权限
sudo nano /etc/exports
##添加如下内容
/data/nfs clientIP(rw,sync,no_subtree_check)

##或者添加整个网段的内容
/data/nfs 192.168.88.0/24(rw,sync,no_subtree_check)

##客户端验证配置
sudo dnf install nfs-utils
sudo exportfs -a

mount 192.168.88.80:/data/nfs /mnt/