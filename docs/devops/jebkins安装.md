自定义目录，编辑tomcat catalina.sh加入

```Plaintext
export JENKINS_HOME=/apps/jenkins
```

java环境变量设置

```Plaintext
JAVA_HOME=/apps/jdk-11.0.17
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tool.jar

export PATH=$JAVA_HOME/bin:$PATH
```

最新Jenkins需要安装以下包

```Plaintext
yum install fontconfig -y
```



下载Jenkins安装包放到tomcat/webapps下启动

[Jenkins download and deployment](http://www.jenkins.io/download/)

```
cat jenkins.sh 
#!/bin/bash
mysql_dir=/apps/tomcat-jenkins/
echo "URL:http://172.100.2.201:8080/"
start(){
        cd $mysql_dir/bin
        ./startup.sh
}

stop(){
        cd $mysql_dir/bin
        ./shutdown.sh
}
status(){
        ps -ef |grep java |grep -v grep
}
case $1 in
start)
        start ;;
stop)
        stop ;;
status)
        status ;;
*)
        echo "Uage :start|stop|status"
;;
esac

```

配置nginx代理

编辑主配置

```
 cat nginx.conf |grep conf.d
    include       /apps/nginx/conf/conf.d/*.conf;

```

新建conf.d/jenkins.conf 

```
 cat jenkins.conf 
upstream jenkins{
        server localhost:8080 max_fails=2 weight=3 fail_timeout=10s;
}

server {
        listen          80;
        server_name     jenkins.east-port.cn;

        location        /{
                proxy_pass              http://localhost:8080;
                proxy_set_header        X-Real-IP $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header        Host $host;
                client_max_body_size    0;
        }
location /rest/analytics/1.0/publish/bulk{
        deny all;
        return 200;
        }
}

```

