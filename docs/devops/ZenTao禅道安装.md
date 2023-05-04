下载：https://www.zentao.net/download/max4.3-82233.html

安装文档：https://www.zentao.net/book/zentaopmshelp/40.html

## 1. 使用lamp环境安装直接下载zip包，解压放到apache目录下，访问就行

lamp安装：[Lamp安装](/Linux/lamp安装.md)

```Python
unzip ZenTaoPMS.11.5.1.zip
mv zentaopms/ /usr/local/apache2/htdocs
/usr/local/apache2/bin/apachectl restart
```

访问：http://172.100.2.201:8050/zentaopms/www/index.php?m=my&f=index

## 2. 集成包一键安装

```Plain
tar zxvf ZenTaoPMS.18.0.beta3.zbox_64.tar.gz -C /opt
cd /opt/zbox/
/opt/zbox/zbox -ap 8050 -mp 330
/opt/zbox/zbox start
```

## 3. docker方式安装

参考：https://hub.docker.com/r/easysoft/zentao

```Bash
docker pull easysoft/zentao:latest
mkdir -p /apps/ZenTao/data/zentaopms
mkdir -p /apps/ZenTao/data/mysql

docker run --name zentao \
-p 8050:80 \
-v /apps/ZenTao/data/zentaopms:/www/zentaopms \
-v /apps/ZenTao/data/mysql:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=123456 \
-d easysoft/zentao:latest
```