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
yum install socat logrotate -y
yum install install -y erlang rabbitmq-server

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
