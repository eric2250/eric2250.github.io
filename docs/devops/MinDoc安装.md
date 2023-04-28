官方文档：https://doc.gsw945.com/docs/mindoc-docs

下载地址：https://github.com/mindoc-org/mindoc/releases

# 1. docker安装

## 1.1 拉取镜像

```Dockerfile
docker pull registry.cn-hangzhou.aliyuncs.com/mindoc/mindoc:v0.12
```

## 1.2 启动

```Dockerfile
docker run -d  \
--name=mindoc \
--restart=always \
-v /apps/mindoc/uploads:/mindoc/uploads \
-v /apps/mindoc/database:/data/database \
-e DB_ADAPTER=sqlite3 \
-e MYSQL_INSTANCE_NAME=./database/mindoc.db \
-e CACHE=true \
-e CACHE_PROVIDER=file \
-e ENABLE_EXPORT=true \
-p 8181:8181 \
registry.cn-hangzhou.aliyuncs.com/mindoc/mindoc:v0.12

docker run -d \
-p 8181:8181 \
--name mindoc \
-e DB_ADAPTER=mysql \
-e MYSQL_PORT_3306_TCP_ADDR=10.xxx.xxx.xxx \
-e MYSQL_PORT_3306_TCP_PORT=3306 \
-e MYSQL_INSTANCE_NAME=mindoc \
-e MYSQL_USERNAME=root \
-e MYSQL_PASSWORD=123456 \
-e httpport=8181 \
daocloud.io/lifei6671/mindoc:latest
```

## 1.3 访问

此时访问 http://localhost:8181 就能访问 MinDoc 了。

默认密码： admin/123456

# 2. 二进制包安装

## 2.1 下载：[Releases · mindoc-org/mindoc](https://github.com/mindoc-org/mindoc/releases)

```Dockerfile
wget https://github.com/mindoc-org/mindoc/releases/download/v2.1/mindoc_linux_musl_amd64.zip
unzip mindoc_linux_musl_amd64.zip
```

## 2.2 修改配置文件

### 2.2.1 以sqlite3数据库

```Dockerfile
cp  conf/app.conf.example cp  conf/app.conf

vim cp  conf/app.conf
##注释mysql部分
####################MySQL 数据库配置###########################
#支持MySQL和sqlite3两种数据库，如果是sqlite3 则 db_database 标识数据库的物理目录
#db_adapter="${MINDOC_DB_ADAPTER||sqlite3}"
#db_host="${MINDOC_DB_HOST||127.0.0.1}"
#db_port="${MINDOC_DB_PORT||3306}"
#db_database="${MINDOC_DB_DATABASE||./database/mindoc.db}"
#db_username="${MINDOC_DB_USERNAME||root}"
#db_password="${MINDOC_DB_PASSWORD||123456}"
#打开sqlite3
####################sqlite3 数据库配置###########################
db_adapter=sqlite3
db_database=./database/mindoc.db
```

### 2.2.1 以mysql数据库

新建数据库

```SQL
CREATE DATABASE mindoc_db  DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
```

导出数据库

```Bash
mysqldump --databases mindoc_db > mindoc_db.sql
```

导入

```Bash
 source /apps/mindoc/mindoc_db.sql
```

修改配置

```Dockerfile
db_adapter=mysql
db_host=127.0.0.1
db_port=3306
db_database=mindoc_db
db_username=root
db_password=gwqgwq
```

## 2.3安装启动

```Dockerfile
#初始化数据
./mindoc_linux_musl_amd64 install
#启动
./mindoc_linux_musl_amd64
```

## 2.4 nginx代理

这一步可选，如果你不想用端口号访问 MinDoc 就需要配置一个代理了。

Nginx 代理的配置文件如下：

```TOML
server {
    listen       80;

    #此处应该配置你的域名：server_name  webhook.iminho.me;

    charset utf-8;

    #此处配置你的访问日志，请手动创建该目录：access_log  /var/log/nginx/webhook.iminho.me/access.log;

    location / {
        try_files /_not_exists_ @backend;
    }

    # 这里为具体的服务代理配置location @backend {
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host            $http_host;
        proxy_set_header   X-Forwarded-Proto $scheme;

        #此处配置 MinDoc 程序的地址和端口号proxy_pass http://127.0.0.1:8181;
    }
}
```

## 2.5 访问：

此时访问 http://localhost:8181 就能访问 MinDoc 了。

默认密码： admin/123456

# 3. **以docker-compose方式安装**

```Bash
#cat  docker-compose.yml
version: "3"
services:
  mindoc:
    image: registry.cn-hangzhou.aliyuncs.com/mindoc-org/mindoc:v2.1
    depends_on:
      - mysql
    container_name: mindoc
    privileged: false
    restart: always
    ports:
      - 8182:8181
    volumes:
      - /apps/mindoc/docker/mindoc/conf://mindoc/conf
      - /apps/mindoc/docker/mindoc/static://mindoc/static
      - /apps/mindoc/docker/mindoc/views://mindoc/views
      - /apps/mindoc/docker/mindoc/uploads://mindoc/uploads
      - /apps/mindoc/docker/mindoc/runtime://mindoc/runtime
      - /apps/mindoc/docker/mindoc/database://mindoc/database
    environment:
      - MINDOC_BASE_URL=http://wiki.east-port.cn
      - MINDOC_RUN_MODE=prod
      - MINDOC_DB_ADAPTER=mysql
      - MINDOC_DB_HOST=172.100.2.201
      - MINDOC_DB_PORT=3306
      - MINDOC_DB_DATABASE=mindoc_db
      - MINDOC_DB_USERNAME=root
      - MINDOC_DB_PASSWORD=gwqgwq
      - MINDOC_CACHE=true
      - MINDOC_CACHE_PROVIDER=file
      - MINDOC_ENABLE_EXPORT=true
      
    dns:
      - 172.100.2.201
      - 114.114.114.114
  mysql:
    image: mysql:8.0.31
    environment:
      MYSQL_ROOT_PASSWORD: gwqgwq
    volumes:
      - /apps/mysql/data://var/lib/mysql
    ports:
      - 3306:3306
```

```
docker-compose up -d

CREATE DATABASE mindoc_db  DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
source /var/lib/mysql/mindoc_db.sql
```



# 4. 关于ldap集成

```Bash
################Active Directory/LDAP################
#是否启用ldap
ldap_enable=true
#ldap主机名
ldap_host=172.100.2.201
#ldap端口
ldap_port=389
#ldap内哪个属性作为用户名
ldap_attribute=uid
#搜索范围
ldap_base=dc=east-port,dc=cn
#第一次绑定ldap用户dn
ldap_user=cn=admin,dc=east-port,dc=cn
#第一次绑定ldap用户密码
ldap_password=Abc,123.
#自动注册用户角色：0 超级管理员 /1 管理员/ 2 普通用户
ldap_user_role=2
#ldap搜索filter规则,AD服务器: objectClass=User, openldap服务器: objectClass=posixAccount ,也可以定义为其他属性,如: title=mindoc
ldap_filter=objectClass=posixAccount
```

第一次登录后自动同步用户

# 5. 导出配置

```
###############配置导出项目###################
enable_export="${MINDOC_ENABLE_EXPORT||false}"
#同一个项目同时运行导出程序的并行数量，取值1-4之间，取值越大导出速度越快，越占用资源
export_process_num="${MINDOC_EXPORT_PROCESS_NUM||1}"

#并发导出的项目限制，指同一时间限制的导出项目数量，如果为0则不限制。设置的越大，越占用资源
export_limit_num="${MINDOC_EXPORT_LIMIT_NUM||5}"

#指同时等待导出的任务数量
export_queue_limit_num="${MINDOC_EXPORT_QUEUE_LIMIT_NUM||100}"

#导出项目的缓存目录配置
export_output_path="${MINDOC_EXPORT_OUTPUT_PATH||./runtime/cache}"

```

下载安装：https://calibre-ebook.com/download

[Calibre文档转换工具安装](/devops/Calibre文档转换工具安装.md)