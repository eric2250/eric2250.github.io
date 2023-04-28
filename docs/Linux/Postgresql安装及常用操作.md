# 1. 安装

```Plain
apt install postgresql postgresql-contrib

yum install postgresql postgresql-server
```

docker

```Dockerfile
rm -rf   /data/postgressql/data
mkdir -p /data/postgressql/data
docker run --name postgres \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres \
-v /data/postgressql/data:/var/lib/postgresql/data  \
-p 5432:5432 \
-d postgres:13.0
```

# 2. 常见操作

## 新建用户

```SQL
切换到用户postgres
su - postgres
新建用户
createuser confluence
```

## 新建数据库

```SQL
新建数据库
createdb confluence--owner confluence
```

## 新建表

```SQL
CREATE TABLE IF NOT EXISTS my_sample_table( exampledb(> id SERIAL, exampledb(> wordlist VARCHAR(9) NOT NULL );
```
