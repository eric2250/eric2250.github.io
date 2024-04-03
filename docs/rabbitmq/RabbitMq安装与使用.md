# RabbitMQ

# 1.安装配置

官方文档：https://www.rabbitmq.com/docs/download

## Docker安装

```

# latest RabbitMQ 3.13*
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.13-management


```

## Linux安装

```
#yum安装
yum install socat logrotate -y
yum install install -y erlang rabbitmq-server

https://github.com/rabbitmq/erlang-rpm/releases
https://github.com/rabbitmq/rabbitmq-server/releases



#源码安装
wget https://erlang.org/download/otp_src_25.0.tar.gz
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.13.0/rabbitmq-server-generic-unix-3.13.0.tar.xz


https://erlang.org/download/otp_src_26.tar.gz
tar zxvf otp_src_25.0.tar.gz 
yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel unixODBC-devel
cd otp_src_25.0
./configure --prefix=/usr/local/erlang --without-javac
 make && make install

配置环境变量：
ERL_HOME=/usr/local/erlang
RAMQ_HOME=/apps/rabbitmq/rabbitmq_server-3.13.0
JAVA_HOME=/apps/jdk1.8.0_211
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tool.jar

export PATH=$RAMQ_HOME/sbin:$JAVA_HOME/bin:$ERL_HOME/bin:$PATH

启动mq
cd /apps/rabbitmq/rabbitmq_server-3.13.0/sbin
./rabbitmq-server 
 ...
  Doc guides:  https://www.rabbitmq.com/docs/documentation
  Support:     https://www.rabbitmq.com/docs/contact
  Tutorials:   https://www.rabbitmq.com/tutorials
  Monitoring:  https://www.rabbitmq.com/docs/monitoring

  Logs: /apps/rabbitmq/rabbitmq_server-3.13.0/var/log/rabbitmq/rabbit@ep-test-01.log
        <stdout>

  Config file(s): (none)

  Starting broker... completed with 0 plugins.
....

后台启动
rabbitmq-server -detached

rabbitmqctl status

rabbitmqctl stop
```

### 启动

```
systemctl start rabbitmq-server
systemctl status  rabbitmq-server
systemctl stop rabbitmq-server
```

### Rabbitmq Web界面管理授权

```
rabbitmq-plugins enable rabbitmq_management
systemctl restart rabbitmq-server
```

### 访问

浏览器访问：http://172.100.3.112:15672

①.rabbitmq默认访问账户密码:“guest”、“guest”

②.由于这个账号仅限于localhost本地访问,所以我们要授权账号访问

授权账号设置密码

```
[root@ha2 ~]# rabbitmqctl add_user admin admin
Creating user "admin" ...
...done.
[root@ha2 ~]# rabbitmqctl set_user_tags admin administrator
Setting tags for user "admin" to [administrator] ...
...done.
[root@ha2 ~]#  rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
Setting permissions for user "admin" in vhost "/" ...
...done.
```

在访问：http://172.100.3.112:15672 用admin/admin登录





# [rabbitmq常用命令行汇总](https://www.cnblogs.com/potato-chip/p/9977386.html)

最近处理openstack问题时，碰到了rabbitmq相关的问题，使用相关命令行时，经常去现找相关的帖子，感觉很麻烦，记录下自己定位问题时，用到的一些常用命令行，方便以后问题的查找

1)常用的一些查询和设置命令行

```
rabbitmqctl list_queues：查看所有队列信息

rabbitmqctl stop_app：关闭应用（关闭当前启动的节点）

rabbitmqctl start_app：启动应用，和上述关闭命令配合使用，达到清空队列的目的

rabbitmqctl reset：从管理数据库中移除所有数据，例如配置过的用户和虚拟宿主, 删除所有持久化的消息（这个命令要在rabbitmqctl stop_app之后使用），重置以后，用户，虚拟vhost，都会清除

rabbitmqctl force_reset：作用和rabbitmqctl reset一样，区别是无条件重置节点，不管当前管理数据库状态以及集群的配置。如果数据库或者集群配置发生错误才使用这个最后的手段

rabbitmqctl status：节点状态

rabbitmqctl add_user username password：添加用户

rabbitmqctl list_users：列出所有用户

rabbitmqctl list_user_permissions username：列出用户权限

rabbitmqctl change_password username newpassword：修改密码

rabbitmqctl add_vhost vhostpath：创建虚拟主机

rabbitmqctl list_vhosts：列出所有虚拟主机

rabbitmqctl set_permissions -p vhostpath username ".*" ".*" ".*"：设置用户权限

rabbitmqctl list_permissions -p vhostpath：列出虚拟主机上的所有权限

rabbitmqctl clear_permissions -p vhostpath username：清除用户权限

rabbitmqctl -p vhostpath purge_queue blue：清除队列里的消息

rabbitmqctl delete_user username：删除用户

rabbitmqctl delete_vhost vhostpath：删除虚拟主机
```

2）用户管理详解
1、用户管理
用户管理包括增加用户，删除用户，查看用户列表，修改用户密码。
相应的命令

```
(1) 新增一个用户
rabbitmqctl add_user Username Password
(2) 删除一个用户
rabbitmqctl delete_user Username
(3) 修改用户的密码
rabbitmqctl change_password Username Newpassword
(4) 查看当前用户列表
rabbitmqctl list_users
```

2、 用户角色分类
用户角色可分为五类，超级管理员, 监控者, 策略制定者, 普通管理者以及其他。
(1) 超级管理员(administrator)
可登陆管理控制台(启用management plugin的情况下)，可查看所有的信息，并且可以对用户，策略(policy)进行操作。
(2) 监控者(monitoring)
可登陆管理控制台(启用management plugin的情况下)，同时可以查看rabbitmq节点的相关信息(进程数，内存使用情况，磁盘使用情况等)
(3) 策略制定者(policymaker)
可登陆管理控制台(启用management plugin的情况下), 同时可以对policy进行管理。但无法查看节点的相关信息
(4) 普通管理者(management)
仅可登陆管理控制台(启用management plugin的情况下)，无法看到节点信息，也无法对策略进行管理。
(5) 其他
无法登陆管理控制台，通常就是普通的生产者和消费者。

设置用户角色的命令为：

```
rabbitmqctl set_user_tags User Tag
```

User为用户名， Tag为角色名(对应于上面的administrator，monitoring，policymaker，management，或其他自定义名称)。
也可以给同一用户设置多个角色，例如

```
rabbitmqctl set_user_tags hncscwc monitoring policymaker
```



3. 用户权限

用户权限指的是用户对exchange，queue的操作权限，包括配置权限，读写权限。配置权限会影响到exchange，queue的声明和删除。读写权限影响到从queue里取消息，向exchange发送消息以及queue和exchange的绑定(bind)操作。
例如： 将queue绑定到某exchange上，需要具有queue的可写权限，以及exchange的可读权限；向exchange发送消息需要具有exchange的可写权限；从queue里取数据需要具有queue的可读权限。详细请参考官方文档中"How permissions work"部分。
相关命令为：

```
(1) 设置用户权限
rabbitmqctl set_permissions -p VHostPath User ConfP WriteP ReadP
(2) 查看(指定hostpath)所有用户的权限信息
rabbitmqctl list_permissions [-p VHostPath]
(3) 查看指定用户的权限信息
rabbitmqctl list_user_permissions User
(4) 清除用户的权限信息
rabbitmqctl clear_permissions [-p VHostPath] User
```

4、设置节点类型

如果你想更换节点类型可以通过命令修改，如下：

```
rabbitmqctl stop_app
rabbitmqctl change_cluster_node_type dist
rabbitmqctl change_cluster_node_type ram
rabbitmqctl start_app
```

