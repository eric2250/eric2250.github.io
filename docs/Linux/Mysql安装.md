# 1.下载myql 

访问下载地址下载对应版本：MySQL :: Download MySQL Community Server https://dev.mysql.com/downloads/mysql/

驱动包下载：https://downloads.mysql.com/archives/c-j/

选择**Platform Independent为jar包**

#  2.安装msql

## 2.1 新建用户

```Bash
groupadd mysql
useradd -r -g mysql -s /sbin/nologin mysql
```

## 2.2 解压包，改名为计划目录 ，新建数据目录

```Bash
tar xvf soft/mysql-8.0.31-linux-glibc2.12-x86_64.tar.xz

mv mysql-8.0.31-linux-glibc2.12-x86_64/ mysql-8.0.31

cd mysql-8.0.31/

mkdir data

cd ../
chown mysql.mysql -R mysql-8.0.31/
chmod 750 -R mysql-8.0.31/
```

## 2.3 新建配置文件 

```Bash
# mv /etc/my.cnf /etc/my.cnf.bak
# cat my.cnf

[client]

port = 3306
#socket      = /tmp/mysql.sock


[mysqld]
port = 3306
#socket      = /tmp/mysql.sock
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
log-bin=mysql-bin
binlog_format=mixed
server-id = 1
#innodb_data_home_dir = /usr/local/mysql/data
#innodb_data_file_path = ibdata1:10M:autoextend
#innodb_log_group_home_dir = /usr/local/mysql/data
#innodb_buffer_pool_size = 16M
#innodb_additional_mem_pool_size = 2M
#innodb_log_file_size = 5M
#innodb_log_buffer_size = 8M
#innodb_flush_log_at_trx_commit = 1
#innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
```

## 2.4 初始化数据库，注意密码，此次为空

```Bash
#./bin/mysqld --initialize-insecure --user=mysql --basedir=/apps/mysql-8.0.31/ 
2023-03-07T07:04:59.654720Z 0 [System] [MY-013169] [Server] /apps/mysql-8.0.31/bin/mysqld (mysqld 8.0.31) initializing of server in progress as process 25378
2023-03-07T07:04:59.662327Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
2023-03-07T07:05:00.398774Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
2023-03-07T07:05:01.568201Z 6 [Warning] [MY-010453] [Server] root@localhost is created with an empty password ! Please consider switching off the --initialize-insecure option.
报错：
error while loading shared libraries: libaio.so.1: cannot open shared object file: No such file or directory
解决：
centos：yum install -y libaio
ubuntu：apt-get install libaio1
```

## 2.5 复制启动脚本，启动mysql

```Bash
#vim support-files/mysql.server
basedir=/apps/mysql-8.0.31
datadir=/apps/mysql-8.0.31/data

#cp support-files/mysql.server /etc/init.d/
#/etc/init.d/mysql.server start
. SUCCESS!
#----------------------------------
cat >/etc/systemd/system/mysql.service<<"EOF"
[Unit]
Description=Mysql
After=syslog.target
After=network.target
###
[Service]
RestartSec=2s
Type=simple

ExecStart=/etc/init.d/mysql.server start
Restart=always


[Install]
WantedBy=multi-user.target
EOF
#-----------------------------
chmod +x /etc/systemd/system/mysql.service
```

## 2.6 配置环境变量，登录测试

```Bash
# vim /etc/profile
MYSQL_HOME=/apps/mysql-8.0.31
GIT_HOME=/usr/local/git
#JAVA_HOME=/apps/jdk-11.0.17
JAVA_HOME=/apps/jdk-17.0.4.1
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tool.jar


export PATH=$MYSQL_HOME/bin:$JAVA_HOME/bin:$GIT_HOME/bin:$PATH

# source /etc/profile

# mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.31 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>


#--------------------------------------------
ubuntu下报错：mysql: error while loading shared libraries: libtinfo.so.5: cannot open shared object file: No such file or directory

解决：sudo apt-get install libncurses5 -y
```

## 2.7 字符集设置

```SQL
//查看字符集
mysql> show variables like 'character%';
+--------------------------+------------------------------------+
| Variable_name            | Value                              |
+--------------------------+------------------------------------+
| character_set_client     | utf8mb4                            |
| character_set_connection | utf8mb4                            |
| character_set_database   | utf8mb4                            |
| character_set_filesystem | binary                             |
| character_set_results    | utf8mb4                            |
| character_set_server     | utf8mb4                            |
| character_set_system     | utf8mb3                            |
| character_sets_dir       | /apps/mysql-8.0.31/share/charsets/ |
+--------------------------+------------------------------------+
8 rows in set (0.67 sec)
//说明
character_set_server ：服务器级别的字符集
character_set_database ：当前数据库的字符集
character_set_client ：服务器解码请求时使用的字符集
character_set_connection ：服务器处理请求时会把请求字符串从character_set_client 转为character_set_connection
character_set_results ：服务器向客户端返回数据时使用的字符集
常用命令
#查看GBK字符集的比较规则
SHOW COLLATION LIKE 'gbk%';
#查看UTF-8字符集的比较规则
SHOW COLLATION LIKE 'utf8%';

#查看服务器的字符集和比较规则
SHOW VARIABLES LIKE '%_server';
#查看数据库的字符集和比较规则
SHOW VARIABLES LIKE '%_database';

#查看具体数据库的字符集
SHOW CREATE DATABASE dbtest1;
#修改具体数据库的字符集
ALTER DATABASE dbtest1 DEFAULT CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';

#查看表的字符集
show create table employees;
#查看表的比较规则
show table status from atguigudb like 'employees';
#修改表的字符集和比较规则
ALTER TABLE emp1 DEFAULT CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';
```

全局设置

```undefined
vim my.cnf
character_set_server=utf8
修改已创建数据库的字符集
alter database confluence character set 'utf8';
修改已创建数据表的字符集
alter table t_emp convert to character set 'utf8';
```

## 2.8 修改密码及设置远程登录

```SQL
显示数据库
show databases;

修改mysql账户密码：
ALTER USER 'root'@'localhost' IDENTIFIED BY 'gwqgwq' PASSWORD EXPIRE NEVER;

切换到mysql数据库
use mysql

查询
select host,user from user;

更改成可以在所有的主机登录
update user set host='%' where user='root';

更改成加密密码（需要刷新权限，允许远程用户连接）
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'gwqgwq';

刷新权限
flush privileges;

允许远程用户连接（5.x）
GRANT ALL PRIVILEGES ON . TO 'root'@'%' IDENTIFIED BY 'gwqgwq' WITH GRANT OPTION;

退出
exit;
```

# 3.docker安装mysql

```undefined
docker pull mysql:8.0.31
mkdir -p /apps/mysql/data
docker run --name mysql \
-v /apps/mysql/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=gwqgwq \
-p 3306:3306 \
-d mysql:8.0.31


mysql -h 172.100.3.129 -uroot -p
```

# 4.新建库测试

```SQL
新建库
 CREATE DATABASE gitea CHARACTER SET utf8 COLLATE utf8_general_ci; 

 CREATE USER 'gitea' IDENTIFIED BY 'gitea';

 GRANT ALL ON gitea.* TO 'gitea'@'%';

 FLUSH PRIVILEGES;
 
```
