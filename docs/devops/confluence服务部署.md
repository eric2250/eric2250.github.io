## 1. 新建数据库

```SQL
mkdir -p /apps/confluence
docker run --name confluence-jira-mysql -p 3307:3306 \
  -v /apps/confluence/mysql:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=gwqgwq \
  -it -d registry.cn-hangzhou.aliyuncs.com/erictor888/mysql:5.7.40

mysql -h 172.100.3.86 -P 3307 -uroot -pgwqgwq

--mysql5.x
-- 设置confdb事务级别
show variables like 'tx%';
set session transaction isolation level read committed;
SET GLOBAL tx_isolation='READ-COMMITTED';
show variables like 'tx%';


--创建confluence数据库及用户 
CREATE DATABASE `confluence` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
create user confluence identified by 'confluence';
grant all privileges on *.* to 'confluence'@'%' identified by 'confluence' with grant option;
grant all privileges on *.* to 'confluence'@'localhost' identified by 'confluence' with grant option;
flush privileges;
--mysql8.x
CREATE DATABASE `confluence` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
create user confluence identified by 'confluence';
GRANT ALL ON confluence.* TO 'confluence'@'%';
FLUSH PRIVILEGES;
```

## 2. docker方式启动

```ABAP
docker run --name confluence \
--detach \
--publish 8090:8090 \
registry.cn-hangzhou.aliyuncs.com/erictor888/confluence:6.13.0
```

生成confluence许可命令

```Plaintext
设置产品类型：-p conf， 详情可执行：java -jar atlassian-agent.jar 
java -jar atlassian-agent.jar -d -m test@eric.com -n eric -p conf -o http://172.100.3.86 -s B749-OB11-VXLI-DSFT
```

获取token命令

```Plaintext
bash-4.4# java -jar atlassian-agent.jar -d -m test@eric.com -n eric -p conf -o http://172.100.2.201 -s B715-81TU-AJTC-HCEY

====================================================
=======        Atlassian Crack Agent         =======
=======           https://zhile.io           =======
=======          QQ Group: 30347511          =======
====================================================

Your license code(Don't copy this line!!!): 

AAABUg0ODAoPeJxtkF9LwzAUxd/zKQo+p0tStnWDgrMtOmk3sZ3iYxbvXKBNS5IO56c3/QOCDPJy7
7k599zf3Tt8ejnXHlt5hK5psCah95iXHiMsQLEGbmWjEm4h6juYBJitUHrhVTco0YlXBlACRmjZD
p2DqmQtrfOtpABlwDtevbO1rVnPZj9nWYEvG7TXX1xJM5r0qhPpkvmUEJ/5jFAkGnXyubDyApHVH
aC4UdbVac5lFVkw9h60FL5o6nG2sFxb0FOkoZWNCcprCzteQxTv8zx9jbebDDkXZUFxJSD9bqW+T
keGK0yW7qHp7zaJsm1SpDuc0UVIyJwFYbgIVqgAfQHt5IclneOQlge8eS5j/BSnH+N258hjUH2m4
YDJ8fa6l06LMzfwn/UE8Q206VExVHTHP9iD77Bs19VH0PvTwbjJCFPkIkc3Yk8UBxw9v18k1qX+M
CwCFHm1pneO24WYeVq6I81hNa6z+Zc8AhQcUOU587CjRhFZmJF9aC0IFiX52A==X02go
jdbc:mysql://172.100.2.201:3306/confluence?useUnicode=true&characterEncoding=UTF-8
```

## 3. 访问设置

打开：http://172.100.3.86:8090/

![img](..\images\conference.png)

![img](..\images\conference1.png)

![img](..\images\conference2.png)

```Java
root@devops:/apps# docker exec -it 0d2f44ff6de3 bash
bash-4.4# cd /opt/atlassian/confluence/
bash-4.4# java -jar atlassian-agent.jar -d -m wiki@eric.com -n eric -p conf -o http://172.100.3.86 -s B749-OB11-VXLI-DSFT

====================================================
=======        Atlassian Crack Agent         =======
=======           https://zhile.io           =======
=======          QQ Group: 30347511          =======
====================================================

Your license code(Don't copy this line!!!): 

AAABUg0ODAoPeJxtkF9rgzAUxd/zKYQ9x0YtVQuBreqGoHXMtttrmt2uYRolxm7dp1/8A4NRyMu95
+bcc393r/Bu5UxZbmgRf03C9dK3nvKd5RLXQ5ECpkUjY6aBDh1MPOyGKLmwqh8VemJVByiGjivRj
p29rEQttPGtBAfZgXW8Wmet2269WPycRQW2aFChPpgU3WQyqEZ0fNd2CLE9O1gh3siTzbgWF6Ba9
YCiRmpTJzkTFf0Sn+IelOA2b+ppttRMaVBzorGVTQF21xa2rAYaFXmevETpQ4aMi9QgmeSQfLdCX
ecbgxAT3zw0/01jmqVxmWxx5qwCQnzPD3yy9FAJ6gLKyBt/GeJi4zj48JalOC4fd9N248gikEOm8
YDZ8fa6517xM+vgP+qZ4QFUN5ByUdkf/1iPvuOybV8fQRWnfWcmKXaQiUxvxJ4pjjgGfr/VfqXjM
CwCFCnjJEYOGJz4WzfyTgT2IzqDyr27AhQMojaZ1J2JxEtjJEpFdpe5IVH07A==X02go
```

![img](..\images\conference3.png)

![img](..\images\conference4.png)

![img](..\images\conference5.png)

![img](..\images\conference6.png)

![img](..\images\conference7.png)

![img](..\images\conference8.png)