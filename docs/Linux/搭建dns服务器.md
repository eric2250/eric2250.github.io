安装
```
yum install -y bind bind-utils
```
修改配置文件，两个any
```
[root@k8s-master01 named]#  vim /etc/named.conf 

// configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html

options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     { any; };
```
vim /etc/named.rfc1912.zones 添加
```
zone "eric.com" IN {
        type master;
        file "eric.com.zone";
        allow-update { none; };
};
zone "88.168.192.in-addr.arpa" IN {
        type master;
        file "88.168.192.zone";
};
```
复制反向解析，我用不到不用改内容
```
cp -a named.loopback 88.168.192.zone
```

创建修改正向解析文件内容如下
```
vim /var/named/eric.com.zone 
$TTL 1D
@       IN SOA  @  eric.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       IN   NS ns.eric.com.
ns      IN      A       192.168.88.11
jenkins         IN      A       192.168.88.12
harbor          IN      A       192.168.88.11
sonarqube       IN      A       192.168.88.12
tekton          IN      A       192.168.88.12
bitbucket   IN      A       192.168.88.12
ingress     IN      A       192.168.88.12
appweb      IN      A       192.168.88.12
grafana     IN      A       192.168.88.12
zabbix      IN      A       192.168.88.12
maven       IN      A       192.168.88.12
confluence  IN      A       192.168.88.12
crowd       IN      A       192.168.88.12
argocd       IN      A       192.168.88.12
```

systemctl restart named