# Docker 部署 ldap+self-service-password服务

## Docker run方式

```
docker run \
    -d \
    -p 389:389 \
    -p 636:636 \
    -v /apps/ldap/openldap/local/ldap:/usr/local/ldap \
    -v /apps/ldap/openldap/ldap:/var/lib/ldap \
    -v /apps/ldap/openldap/slapd.d:/etc/ldap/slapd.d \
    --env LDAP_ORGANISATION="east-port" \
    --env LDAP_DOMAIN="east-port.cn" \
    --env LDAP_ADMIN_PASSWORD="123456" \
    --name openldap \
    --hostname openldap-host\
    --network bridge \
    registry.cn-hangzhou.aliyuncs.com/erictor888/openldap:1.2.5
    
docker run \
    -p 8888:80 \
    --privileged \
    --name phpldapadmin \
    --env PHPLDAPADMIN_HTTPS=false \
    --env PHPLDAPADMIN_LDAP_HOSTS=192.168.88.10  \
    --detach \
    registry.cn-hangzhou.aliyuncs.com/erictor888/phpldapadmin:1.2.5
    
docker run \
    -d \
    -p 8989:80\
    -v /apps/ldap/self-service-password:/www \
    -e LDAP_SERVER=ldap://172.100.2.201:389 \
    -e LDAP_BINDDN=cn=admin,dc=east-port,dc=cn \
    -e LDAP_BINDPASS=123456 \
    -e LDAP_BASE_SEARCH=ou=eport,dc=east-port,dc=cn \
    registry.cn-hangzhou.aliyuncs.com/erictor888/self-service-password:1.2.5
```

## docker-compose方式部署一键部署

```
version: "3"

services:
  phpldapadmin:
    image: registry.cn-hangzhou.aliyuncs.com/erictor888/phpldapadmin:1.2.5
    depends_on:
      - openldap
    environment:
      PHPLDAPADMIN_HTTPS: false
      PHPLDAPADMIN_LDAP_HOSTS: 172.100.3.86
    ports:
      - "8888:80"
  openldap:
    image: registry.cn-hangzhou.aliyuncs.com/erictor888/openldap:1.2.5
    environment:
      LDAP_ORGANISATION: "east-port"
      LDAP_DOMAIN: "east-port.cn"
      LDAP_ADMIN_PASSWORD: "123456"
    volumes:
      - /apps/ldap/openldap/local/ldap:/usr/local/ldap
      - /apps/ldap/openldap/ldap:/var/lib/ldap
      - /apps/ldap/openldap/slapd.d:/etc/ldap/slapd.d
    ports:
      - "389:389"
      - "636:636"
  ssp:
    image: registry.cn-hangzhou.aliyuncs.com/erictor888/self-service-password:1.2.5
    environment:
      LDAP_SERVER: ldap://172.100.3.86:389
      LDAP_BINDDN: cn=admin,dc=east-port,dc=cn
      LDAP_BINDPASS: 123456
      LDAP_BASE_SEARCH: ou=eport,dc=east-port,dc=cn
      PASSWORD_MIN_LENGTH=6
      PASSWORD_MAX_LENGTH=30
      PASSWORD_MIN_LOWERCASE=1
      PASSWORD_MIN_UPPERCASE=0
      PASSWORD_MIN_DIGIT=0
      PASSWORD_MIN_SPECIAL=0
      PASSWORD_NO_REUSE=true
      PASSWORD_SHOW_POLICY=onerror
      MAIL_FROM: gouwqiang@163.com
      MAIL_FROM_NAME: easpport
      NOTIFY_ON_CHANGE: true
      SMTP_HOST: smtp.163.com
      SMTP_AUTH_ON: true
      SMTP_USER: gouwqiang@163.com
      SMTP_PASS: AVUYJNHJCEBSPCZP
      SMTP_PORT: 465
      SMTP_SECURE_TYPE: ssl
    volumes:
      - /apps/ldap/self-service-password:/www
    ports:
      - "8989:80"
```

# Centos7 ldap服务部署

## 安装软件

```Bash
yum install -y openldap openldap-clients openldap-servers vim
```

## 配置openldap server

（1）、vim /etc/openldap/slapd.d/cn=config/olcDatabase={1}monitor.ldif

将

![img](https://xlymqcg2kt.feishu.cn/space/api/box/stream/download/asynccode/?code=OGU3NjNhZmRmZGRlNTkxZWIyZTU4YmJlNTVkMmI0NjNfa2FWQXZ6cERZMkphRzg1T2ZheXNyaVpXNzQxN1Z6ZXJfVG9rZW46Ym94Y25tR0F0RU1xM3ljN2xSNExGb2lkRURoXzE2ODI0MDY5NzE6MTY4MjQxMDU3MV9WNA)

改为你自己的，内容可以随便，但是所有地方都要一致

![img](https://xlymqcg2kt.feishu.cn/space/api/box/stream/download/asynccode/?code=ZDVmZjIyYWVkYWEyNjNjZWMyYjAyMGIxZGFkZDM4ODhfc3k2SnZlRDdJM0xPS1hONENtVVRZazR4bEpZUmVVMlhfVG9rZW46Ym94Y25waFRuR24zRHFYZ1k0Mnp3SlljVjRkXzE2ODI0MDY5NzE6MTY4MjQxMDU3MV9WNA)

```Groovy
  vim /etc/openldap/slapd.d/cn=config/olcDatabase={1}monitor.ldif
  ···
  7  al,cn=auth" read by dn.base="cn=admin,dc=east-port,dc=com" read by * none
  ···
```

（2）、vim /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif

将

![img](..\images\ldap.png)

改为

![img](..\images\ldap1.png)

然后添加一行：olcRootPW: 123456 设置管理员密码

```Bash
vim /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif
···
  8 olcSuffix: dc=east-port,dc=com
  9 olcRootDN: cn=admin,dc=east-port,dc=com
···
 19 olcRootPW: 123456
```

（3）、拷贝DB文件

```Bash
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
修改该文件的权限
chown -R ldap:ldap /var/lib/ldap/
```

（4）、测试配置文件是否正确

```Bash
slaptest -u

63ba5a6f ldif_read_file: checksum error on "/etc/openldap/slapd.d/cn=config/olcDatabase={1}monitor.ldif"
63ba5a6f ldif_read_file: checksum error on "/etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif"
config file testing succeeded
```

（5）、如果修改了hostname，相应的要修改hosts，不然执行命令会卡住，很长时间才会执行完成。

（6）、启动服务

```Bash
systemctl start slapd
systemctl enable slapd
systemctl status slapd
```

（7）、添加scheme表（注意顺序）

```Bash
cd /etc/openldap/schema
cp nis.ldif nis.ldif.old
cp cosine.ldif cosine.ldif.old
cp inetorgperson.ldif inetorgperson.ldif.old
sed -i s/manager/east-port/g nis.ldif
sed -i s/manager/east-port/g cosine.ldif
sed -i s/manager/east-port/g inetorgperson.ldif

ldapadd -Y EXTERNAL -H ldapi:/// -D "cn=config" -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -D "cn=config" -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

全部导入
ls /etc/openldap/schema/*.ldif | xargs -I {} sudo ldapadd -Y EXTERNAL -H ldapi:/// -f {}
```

## 创建base.ldif文件

（1）、拷贝如下内容，标红的内容按照自己的配置修改

```Bash
cat > base.ldif << EOF
dn: dc=east-port,dc=com
objectClass: dcObject
objectClass: organization
o: east-port.com
dc: east-port

dn: ou=users,dc=east-port,dc=com
objectClass: organizationalUnit
objectClass: top
ou: users

dn: ou=groups,dc=east-port,dc=com
objectClass: organizationalUnit
objectClass: top
ou: groups
EOF
cat base.ldif

cat > base2.ldif << EOF
dn: dc=hbgd,dc=com
o: east-port com
dc: east-port
objectClass: top
objectClass: dcObject
objectclass: organization
dn: cn=admin,dc=east-port,dc=com
cn: admin
objectClass: organizationalRole
description: Directory Manager
dn: ou=People,dc=east-port,dc=com
ou: People
objectClass: top
objectClass: organizationalUnit
dn: ou=Group,dc=east-port,dc=com
ou: Group
objectClass: top
objectClass: organizationalUnit
EOF
```

（2）、建立最基础的目录结构

```Bash
ldapadd -x -W -D "cn=admin,dc=east-port,dc=com" -f base.ldif

Enter LDAP Password:123456
adding new entry "dc=east-port,dc=com"

adding new entry "ou=users,dc=east-port,dc=com"

adding new entry "ou=groups,dc=east-port,dc=com"
```

（3）、验证基础目录是否创建成功

```Bash
vim /etc/openldap/ldap.conf
将这两个地方注释去掉，改成如下
BASE    dc=east-port,dc=com
URI     ldap://192.168.88.10 ldap://192.168.88.10:666
```

## 管理用户与组

### 使用ldapscripts工具管理用户

安装工具

```Bash
（1）、安装依赖包 yum install sharutils，手动下载安装ldapscripts
下载地址：https://sourceforge.net/projects/ldapscripts/
tar zxvf ldapscripts-2.0.8.tgz
cd ldapscripts-2.0.8
make install
Configuring scripts... ok.
Installing scripts into /usr/local/sbin... ok.
Installing man files into /usr/local/man... ok.
Installing configuration files into /usr/local/etc/ldapscripts... ok.
Installing library files into /usr/local/lib/ldapscripts... ok.
配置环境变量：
vim /etc/profile

LDAPSCRIPTS_HOME=/usr/local/sbin
export PATH=$LDAPSCRIPTS_HOME/sbin/:$PATH

source /etc/profile   
（2）、配置ldapscripts
vim /usr/local/etc/ldapscripts/ldapscripts.conf

1、将SERVER="ldap://localhost"改成SERVER="ldap://11.3.103.201"
2、将SUFFIX="dc=example,dc=com"改成SUFFIX="dc=east-port,dc=com"
3、将BINDDN="cn=Manager,dc=example改成BINDDN="cn=admin,dc=east-port,dc=com"
4、去掉#ICONVCHAR="ISO-8859-15"的注释#
3）、修改/etc/ldapscripts/ldapscripts.passwd文件
  sh -c "echo -n '123456' > /etc/ldapscripts/ldapscripts.passwd"
```

管理group，user

```Bash
#创建group
ldapaddgroup eport
#创建用户
ldapadduser user1 eport
#设置用户密码
ldapsetpasswd user1

Changing password for user uid=user1,ou=users,dc=east-port,dc=com
New Password:gwqgwq
Retype New Password:gwqgwq
Successfully set password for user uid=user1,ou=users,dc=east-port,dc=com
```

修改密码:

```Bash
ldappasswd -x -h 192.168.88.10 -p 389 -D "cn=admin,dc=east=port,dc=com" -w Abc,123. -s eric
```

### 使用migrationtools工具管理用户

安装工具

```Bash
yum install  migrationtools
```

管理group，user

**修改migrate_common.ph文件**

migrate_common.ph文件主要是用于生成ldif文件使用，修改migrate_common.ph文件，如下：

```Bash
vim /usr/share/migrationtools/migrate_common.ph
 71 $DEFAULT_MAIL_DOMAIN = "east-port.com";
 72
 73 # Default base
 74 $DEFAULT_BASE = "dc=east-port,dc=com";
 88 # turn this on to support more general object clases
 89 # such as person.
 90 $EXTENDED_SCHEMA = 1;
```

默认情况下OpenLDAP是没有普通用户的，但是有一个管理员用户。管理用户就是前面我们刚刚配置的root。 现在我们把系统中的用户，添加到OpenLDAP中。为了进行区分，我们现在新加两个用户ldapuser1和ldapuser2，和两个用户组ldapgroup1和ldapgroup2，如下： 添加用户组，使用如下命令：

```Bash
groupadd ldapgroup1
groupadd ldapgroup2

useradd -g ldapgroup1 ldapuser1
useradd -g ldapgroup2 ldapuser2
echo '123456' | passwd --stdin ldapuser1
echo '123456' | passwd --stdin ldapuser2

grep ":10[0-9][0-9]" /etc/passwd > users
grep ":10[0-9][0-9]" /etc/group > groups

cat users
ldapuser1:x:1002:1003::/home/ldapuser1:/bin/bash
ldapuser2:x:1003:1004::/home/ldapuser2:/bin/bash
cat groups
ldapgroup1:x:1003:
ldapgroup2:x:1004:
```

根据上述生成的用户和用户组属性，使用migrate_passwd.pl文件生成要添加用户和用户组的ldif，如下：

```Bash
/usr/share/migrationtools/migrate_passwd.pl users > users.ldif
/usr/share/migrationtools/migrate_group.pl groups > groups.ldif
cat users.ldif
cat groups.ldif
```

导入用户与组到数据库，使用如下命令：

```Bash
ldapadd -x -W -D "cn=admin,dc=east-port,dc=com" -f users.ldif
ldapadd -x -W -D "cn=admin,dc=east-port,dc=com" -f groups.ldif
```

**把OpenLDAP用户加入到用户组**

尽管我们已经把用户和用户组信息，导入到OpenLDAP数据库中了。但实际上目前OpenLDAP用户和用户组之间是没有任何关联的。 如果我们要把OpenLDAP数据库中的用户和用户组关联起来的话，我们还需要做另外单独的配置。 现在我们要把ldapuser1用户加入到ldapgroup1用户组，需要新建添加用户到用户组的ldif文件，如下：

```Bash
cat > add_user_to_groups.ldif << “EOF”
dn: cn=ldapgroup1,ou=Group,dc=east-port,dc=com
changetype: modify
add: memberuid
memberuid: ldapuser1
EOF

ldapadd -x -W -D "cn=admin,dc=east-port,dc=com" -f add_user_to_groups.ldif

ldapsearch -LLL -x -D 'cn=admin,dc=east-port,dc=com' -W -b 'dc=east-port,dc=com' 'cn=ldapgroup1'
```

## **开启OpenLDAP日志访问功能**

默认情况下OpenLDAP是没有启用日志记录功能的，但是在实际使用过程中，我们为了定位问题需要使用到OpenLDAP日志。 新建日志配置ldif文件，如下：

```Bash
cat > loglevel.ldif << "EOF"
dn: cn=config
changetype: modify
replace: olcLogLevel
olcLogLevel: stats
EOF
```

导入到OpenLDAP中，并重启OpenLDAP服务，如下：

```Bash
ldapmodify -Y EXTERNAL -H ldapi:/// -f loglevel.ldif
systemctl restart slapd

cat >> /etc/rsyslog.conf << "EOF"
local4.* /var/log/slapd.log
EOF
systemctl restart rsyslog


tail -f /var/log/slapd.log
```

## 安装phpldapadmin

ldap装好后，下面安装web界面phpldapadmin。

```Bash
# yum安装时，会自动安装apache和php的依赖。
# 注意： phpldapadmin很多没更新了，只支持php5，如果你服务器的环境是php7，则会有问题，页面会有各种报错
 yum -y install httpd php php-ldap php-gd php-mbstring php-pear php-bcmath php-xml

 yum -y install epel-release
 yum --enablerepo=epel -y install phpldapadmin
# 修改apache的phpldapadmin配置文件
# 修改如下内容，放开外网访问，这里只改了2.4版本的配置，因为centos7 默认安装的apache为2.4版本。所以只需要改2.4版本的配置就可以了
# 如果不知道自己apache版本，执行 rpm -qa|grep httpd 查看apache版本

vim /etc/httpd/conf.d/phpldapadmin.conf
-----------------------------------------------------------------
  <IfModule mod_authz_core.c>
    # Apache 2.4
    Require all granted
  </IfModule>
-----------------------------------------------------------------


# 修改配置用DN登录ldap
vim /etc/phpldapadmin/config.php
-----------------------------------------------------------------
# 398行，默认是使用uid进行登录，我这里改为cn，也就是用户名
$servers->setValue('login','attr','cn');
全称登录设置为dn
$servers->setValue('login','attr','dn');

# 460行，关闭匿名登录，否则任何人都可以直接匿名登录查看所有人的信息
$servers->setValue('login','anon_bind',false);

# 519行，设置用户属性的唯一性，这里我将cn,sn加上了，以确保用户名的唯一性
$servers->setValue('unique','attrs',array('mail','uid','uidNumber','cn','sn'));
-----------------------------------------------------------------


# 启动apache
systemctl start httpd
systemctl enable httpd
```

## cn登录方式

登录phpldapadmin界面

上一步，启动了apache服务后，在浏览器上访问: http://ip/ldapadmin ，然后使用上面定义的用户，进行登录，如下：

账户：admin 密码：123456

![img](..\images\ldap2.png)

OK，到此openldap和phpldapadmin 就安装完成了。至于如果使用，并将ldap集成到我们常用的工具，如jumpserver，jenkins等等。这些有机会的话，后面再新增一篇进行记录

## dn登录方式

上一步，启动了apache服务后，在浏览器上访问: http://ip/ldapadmin ，然后使用上面定义的用户，进行登录，如下：

账户：cn=admin,dc=bkce,dc=com 密码：123456

![img](..\images\ldap3.png)

OK，到此openldap和phpldapadmin 就安装完成了。至于如果使用，并将ldap集成到我们常用的工具，如jumpserver，jenkins等等。这些有机会的话，后面再新增一篇进行记录