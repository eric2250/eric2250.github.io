

# **nginx安装**

## 下载nginx[nginx: download](http://nginx.org/en/download.html)

```
wget http://nginx.org/download/nginx-1.24.0.tar.gz
tar zxvf nginx-1.24.0.tar.gz
cd nginx-1.24.0
```

## 编译安装

```
yum -y install gcc gcc-c++ pcre pcre-devel openssl openssl-devel zlib zlib-devel gd gd-devel
useradd -s /sbin/nologin nginx
./configure --prefix=/apps/nginx
--user=nginx
--group=nginx
--with-pcre
--with-http_ssl_module
--with-http_v2_module
--with-http_realip_module
--with-http_addition_module
--with-http_sub_module
--with-http_dav_module
--with-http_flv_module
--with-http_mp4_module
--with-http_gunzip_module
--with-http_gzip_static_module
--with-http_random_index_module
--with-http_secure_link_module
--with-http_stub_status_module
--with-http_auth_request_module
--with-http_image_filter_module
--with-http_slice_module
--with-mail
--with-threads
--with-file-aio
--with-stream
--with-mail_ssl_module
--with-stream_ssl_module
make && make install
```

## 配置反向代理

```
cat nginx.conf |grep conf.d
    include       /apps/nginx/conf/conf.d/*.conf;
[jenkins@ep-jenkins conf]$ cat conf.d/jenkins.conf 
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

