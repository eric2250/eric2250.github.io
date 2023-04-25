https://docs.gitea.io/zh-cn/install-from-binary/

# 二进制方式安装

## 安装git

```Plaintext
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.39.2.tar.gz --no-check-certificate
tar zxvf git-2.39.2.tar.gz
cd git-2.39.2
make prefix=/usr/local/git install

ln -s /usr/local/git/bin/git /usr/bin/git
```

## 新建用户与目录配置文件

```Bash
groupadd usr
useradd  -g usr -d /usr/users/sw sw

mkdir -p /apps/gitea/{custom,data,log}
chown -R sw:usr /apps/gitea/
chmod -R 750 /apps/gitea/
mkdir /etc/gitea
chown sw:usr /etc/gitea
chmod 770 /etc/gitea
cp app.ini /etc/gitea
chown sw:usr /etc/gitea/app.ini
chmod 770 /etc/gitea/app.ini
#
export GITEA_WORK_DIR=/apps/gitea/
```

下载gitea：https://dl.gitea.com/gitea/

```Bash
wget https://dl.gitea.com/gitea/1.19/gitea-1.19-linux-arm64
cp gitea /usr/local/bin/gitea
```

## 制作启动

```Bash
cat >/etc/systemd/system/gitea.service<<"EOF"
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target
###
[Service]
RestartSec=2s
Type=simple
User=sw
Group=usr
WorkingDirectory=/apps/gitea/
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=sw 
HOME=/usr/users/sw 
GITEA_WORK_DIR=/apps/gitea

[Install]
WantedBy=multi-user.target
EOF

chmod +x /etc/systemd/system/gitea.service
systemctl daemon-reload
systemctl start gitea
systemctl enable --now gitea
systemctl stop firewalld
systemctl disable firewalld
firewall-cmd --state


```

# docker方式安装

vim docker-compose.yaml

```
version: "3"

networks:
  gitea:
    external: false

services:
  server:
    image: gitea/gitea
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - DB_TYPE=mysql
      - DB_HOST=db:3306
      - DB_NAME=gitea
      - DB_USER=gitea
      - DB_PASSWD=gitea
    restart: always
    networks:
      - gitea
    volumes:
      - ./gitea:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
       - "3000:3000"
       - "222:22"
    depends_on:
       - db
 
  db:
     image: mysql:8.0.31
     restart: always
     environment:
       - MYSQL_ROOT_PASSWORD=gitea
       - MYSQL_USER=gitea
       - MYSQL_PASSWORD=gitea
       - MYSQL_DATABASE=gitea
     networks:
       - gitea
     volumes:
       - ./mysql:/var/lib/mysql
```

```
docker-compose up -d
docker-compose logs -f
```



# 新建MySQL数据库用户

```sql
CREATE DATABASE gitea CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'gitea' IDENTIFIED BY 'gitea';
GRANT ALL ON gitea.* TO 'gitea'@'%';
FLUSH PRIVILEGES;
```

# 初始化

访问:http://172.100.3.50:3000/ 

![gitea](..\images\gitea.png)

注册第一账号为管理员