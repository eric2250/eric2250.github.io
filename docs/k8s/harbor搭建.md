#第一步：下载harbor二进制文件：https://github.com/goharbor/harbor/releases 
下载地址：
```
https://github.com/goharbor/harbor/releases
```
#第二步：安装 docker compose
命令：
```
sudo curl -L https://github.com/docker/compose/releases/download/1.23.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
```
然后把下载的docker-compose 设置可执行权限
```
chmod +x /usr/local/bin/docker-compose
```
#第三步：此处应该设置自签证书的，即访问的时候是采用HTTPS进行访问的。此处略去，不影响我们接下去的部署。（后期会出一篇关于自签证书的文章，仅供参考）

#第四步：将下载好的Harbor二进制包上传到服务器上面，然后解压出来

解压的命令为： tar xzvf 包名
```
tar zxvf harbor-offline-installer-v2.2.4.tgz
```
#第五步：进入解压出来的文件夹harbor中，有如下文件。
```
配置文件，cp harbor.yml.tmpl harbor.yml
vim harbor.yml
  6 hostname: 192.168.88.161
	http:
 	 # port for http, default is 80. If https enabled, this port will redirect to https port
  		port: 8888
  ……
  35 harbor_admin_password: gwqgwq

  ……
把其中的hostname修改为：master1 的IP地址。
然后 修改harbor的登录密码：为了方便起见，我修改为123456,大家可自行修改

不用https可以注释：
 13 # https related config
 14 #https:
 15   # https port for harbor, default is 443
 16   #  port: 443
 17   # The path of cert and key files for nginx
 18   # certificate: /your/certificate/path
 19   #private_key: /your/private/key/path

 ```
#第六步：在当前文件夹中开启harbor
```
执行命令：

./prepare
./install.sh  (运行此处的时候需要一定的时间，请等待吧)

...
Creating network "harbor_harbor" with the default driver
Creating harbor-log ... done
Creating harbor-db     ... done
Creating registry      ... done
Creating redis         ... done
Creating harbor-portal ... done
Creating registryctl   ... done
Creating harbor-core   ... done
Creating harbor-jobservice ... done
Creating nginx             ... done
✔ ----Harbor has been installed and started successfully.----

```
#第七步：启动成功，查看一下（完美的运行）
```
docker-compose ps
```

#第八步：配置harbor上传镜像
1、修改docker配置文件，使docker支持harbor
```
编辑客户机/etc/docker/daemon.json文件
{
  "registry-mirrors": ["http://192.168.88.80:8888"]
}

vim /usr/lib/systemd/system/docker.service
在ExecStart=后面添加  --insecure-registry 192.168.88.80:8888 
ExecStart=/usr/bin/dockerd --insecure-registry 192.168.88.80:8888 


重启客户机docker服务
systemctl daemon-reload
systemctl restart docker   #或者(service docker restart) 
```
2、登录
```
docker login 192.168.88.80:8888
 
Username: admin
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

```
3.push镜像
```
docker tag tomcat:latest 192.168.88.80:8888/library/tomcat:10.0
docker push 192.168.88.80:8888/library/tomcat:10.0
```
4.pull镜像
```
docker pull 192.168.88.80:8888/library/jenkins:latest
```
#关于harbor的停止与启动
```
cd harbor
docker-compose down   #停止
docker-compose up -d  #启动
```
设置Harbor开机启动

使用vim编辑器编辑配置文件vim /lib/systemd/system/harbor.service并向文件中写入
```
[Unit]

Description=Harbor

After=docker.service systemd-networkd.service systemd-resolved.service

Requires=docker.service

Documentation=http://github.com/vmware/harbor

[Service]

Type=simple

Restart=on-failure

RestartSec=5

#需要注意harbor的安装位置

ExecStart=/usr/bin/docker-compose -f  /data/dockerfile/app/harbor/harbor/docker-compose.yml up

ExecStop=/usr/bin/docker-compose -f /data/dockerfile/app/harbor/harbor/docker-compose.yml down

[Install]

WantedBy=multi-user.target

```


systemctl daemon-reload
systemctl enable harbor #设置harbor开机自启

systemctl start harbor #启动harbor

#https方式搭建harbor

1.生成CA certificate
```
openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=harbor.eric.com" \
 -key ca.key \
 -out ca.crt
 ```
 
 2.生成Server Certificate
 ```
 openssl genrsa -out harbor.eric.com.key 4096
 
 openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=harbor.eric.com" \
    -key harbor.eric.com.key \
    -out harbor.eric.com.csr
 ````
 3.Generate an x509 v3 extension file
 ```
 cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=harbor.eric.com
DNS.2=eric
DNS.3=harbor
EOF
```
4.Use the v3.ext file to generate a certificate for your Harbor host
```
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in harbor.eric.com.csr \
    -out harbor.eric.com.crt

 ```
 
5.Provide the Certificates to Harbor and Docker
```
cp harbor.eric.com.crt /data/cert/
cp harbor.eric.com.key /data/cert/

openssl x509 -inform PEM -in harbor.eric.com.crt -out harbor.eric.com.cert

mkdir -p /etc/docker/certs.d/harbor.eric.com/
cp harbor.eric.com.cert /etc/docker/certs.d/harbor.eric.com/
cp harbor.eric.com.key /etc/docker/certs.d/harbor.eric.com/
cp ca.crt /etc/docker/certs.d/harbor.eric.com/

tree /etc/docker/certs.d/
/etc/docker/certs.d/
└── harbor.eric.com
    ├── ca.crt
    ├── harbor.eric.com.cert
    └── harbor.eric.com.key

```
```
cp harbor.eric.com.crt /etc/pki/ca-trust/source/anchors/harbor.eric.com.crt
update-ca-trust
systemctl restart docker
```
6.安装harbor
```
vim  harbor.yml
.................
hostname: harbor.eric.com

# http related config
http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
  port: 80

# https related config
https:
  # https port for harbor, default is 443
  port: 443
  # The path of cert and key files for nginx
  certificate: /data/harbor/cert/ca.crt
  private_key: /data/harbor/cert/ca.key
  ...
  harbor_admin_password: Abc,123.
  ...
  # The default data volume
  data_volume: /data/harbor/data

...................

 ./prepare

 ./install.sh 

```
7.配置docker登录
```
vim /etc/docker/daemon.json
{
        "insecure-registries": ["https://harbor.eric.com"],
        "registry-mirrors": ["https://kzjowymh.mirror.aliyuncs.com"],
        "exec-opts": ["native.cgroupdriver=systemd"]
}

systemctl restart docker

docker login harbor.eric.com

Username: admin
Password:
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded


```
# heml方式安装harbor #
https://github.com/goharbor/harbor-helm/releases


```
helm repo add harbor https://helm.goharbor.io
helm search repo harbor
NAME            CHART VERSION   APP VERSION     DESCRIPTION
harbor/harbor   1.9.1           2.5.1           An open source trusted cloud native registry th...

helm pull harbor/harbor

tar zxvf  harbor-1.9.1.tgz


kubectl create namespace harbor

```
准备存储
```
mkdir  -p  /data/nfs/harbor
chmod 777  /data/nfs/harbor

kubectl create ns  harbor
kubectl apply -f nfs-provisioner.yaml
kubectl get po -n harbor
```

$ vim harbor-storageclass.yaml
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: harbor-storageclass
  namespace: harbor
provisioner: example.com/nfs    # 指定外部存储供应商
$ kubectl apply  -f harbor-storageclass.yaml
$ kubectl -n harbor  get storageclass
NAME                  PROVISIONER       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
harbor-storageclass   example.com/nfs   Delete          Immediate           false                  5s


```
修改values.yaml
```
 enabled: false
sed  -i  /type/s/ingress/nodePort/g harbor/values.yaml
sed  -i  /externalURL/s#https://core.harbor.domain#http://192.168.88.12:30002 harbor/values.yaml
sed  -i   /storageClass/s#""#"harbor-storageclass"#g  harbor/values.yaml
sed  -i   /accessMode/s/ReadWriteOnce/ReadWriteMany/g  harbor/values.yaml
特定版本：
sed  -i   /tag/s/v2.4.2/v2.3.5/g  harbor/values.yaml

```

helm install  harbor  harbor/  -n harbor
