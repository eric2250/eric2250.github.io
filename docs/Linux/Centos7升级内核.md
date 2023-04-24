CentOS7.x系统自带的3.10.x内核存在一些Bug，Docker运行不稳定，建议升级内核

#下载内核源
```
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum -y install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
```
# 安装最新版本内核
```
yum --enablerepo=elrepo-kernel install -y kernel-lt
```
# 查看可用内核
```
cat /boot/grub2/grub.cfg |grep menuentry
```
# 设置开机从新内核启动
```
grub2-set-default "CentOS Linux (5.4.204-1.el7.elrepo.x86_64) 7 (Core)"
```
# 查看内核启动项
```
grub2-editenv list
```
# 重启系统使内核生效
```
reboot
```
# 查看内核版本是否生效
```
uname -r
```
