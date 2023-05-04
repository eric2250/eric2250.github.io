#

# 1. Linux

## 1.1 安装

```Bash
yum -y install subversion

svn --version
svn, version 1.7.14 (r1542130)
```

## 1.2 创建一个svn库

```Bash
mkdir -p /home/svn/repo/

cd /home/svn
svnserve -dr repo/

ls -l repo/
total 8
drwxr-xr-x 2 root root  54 Feb 15 15:04 conf
drwxr-sr-x 6 root root 253 Feb 15 14:58 db
-r--r--r-- 1 root root   2 Feb 15 14:29 format
drwxr-xr-x 2 root root 231 Feb 15 14:29 hooks
drwxr-xr-x 2 root root  41 Feb 15 14:29 locks
-rw-r--r-- 1 root root 229 Feb 15 14:29 README.txt
```

## 1.3 配置SVN

更改svnserver.conf时需要重启SVN服务才生效，更改authz和passwd文件时则不需要重启服务。

第一步，配置权限控制文件passwd。

配置修改../conf/passwd文件，并在“[users]”下面添加下面的代码：

```Bash
cat repo/conf/passwd
admin1 = 123456
admin2 = 123456
test1 = 123456
test2 = 123456
```

然后就创建了4个用户，admin1、admin2、test1和test2。

第二步，配置权限控制文件authz。

不使用用户分组，配置修改./conf/authz文件，并在最后一行添加下面的代码：

```Bash
[/]              #仓库下的所有文件
admin1 = rw      #admin1对仓库下所有文件具有可读可写权限
admin2 = rw      #admin2对仓库下所有文件具有可读可写权限
test1 = r        #test1只有只读权限
test2 = r        #test2只有只读权限
= r            #其它用户均无任何权限,这一行很重要，不能少
使用用户分组，配置authz文件，修改后的authz文件中的代码如下：
[groups]
# harry_and_sally = harry,sally
# harry_sally_and_joe = harry,sally,&joe
admin = admin1,admin2
test = test1,test2
# [/foo/bar]
# harry = rw
# &joe = r
# * =
[/]
@admin = rw
@test = r
# [repository:/baz/fuz]
# @harry_and_sally = rw
# * = r
= r
```

然后就创建了2个分组，admin和test。

第三步，配置SVN服务配置文件svnserve.conf。

配置修改/usr/local/svn/test/conf/svnserve.conf文件，打开下面的5个注释（删除#号以及空格）：

```Bash
# 禁止匿名用户访问
anon-access = none
# 授权用户可写
auth-access = write
# 使用哪个文件作为账号文件
password-db = passwd
# 使用哪个文件作为权限文件
authz-db = authz
# 认证空间名，版本库所在目录，realm改成创建的svn目录
realm = Repository test
注意：打开注释时切记前面不要留有空格，否则可能有问题。
```

## 1.4 启动与停止SVN

```Bash
# 启动svn
命令：svnserve -dr /usr/local/svn
#注意：-d表示守护进程， -r 表示在后台执行。
# 查看是否启动
命令：ps -ef|grep svnserve
# 停止svn
命令：killall svnserve
# 停止svn还可以采用杀死进程（默认端口为3690）
命令：ps -ef|grep svnserve
kill -9 [进程号]
```

## 1.5 开机自动启动服务

```Bash
修改配置文件/etc/sysconfig/svnserve，代码如下：
OPTIONS="-d -r /usr/local/svn"
说明：-d表示守护进程， -r 表示在后台执行。
命令：
systemctl status svnserve.service
systemctl enable svnserve.service
systemctl start svnserve.service
systemctl stop svnserve.service
systemctl restart svnserve.service
systemctl list-units --type=service
```

# 2. windows

## 2.1 安装

下载：[Downloads | VisualSVN](https://www.visualsvn.com/downloads/)

https://www.visualsvn.com/files/VisualSVN-Server-5.1.4-x64.msi

## 2.2 配置

网上搜

## 2.3 客户端TortoiseSVN

下载：[Downloads · TortoiseSVN](https://tortoisesvn.net/downloads.html)