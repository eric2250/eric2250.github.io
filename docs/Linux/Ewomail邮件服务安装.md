http://doc.ewomail.com/docs/ewomail/install

## 1 安装

### 1.1 git安装 （centos7/8）

```Bash
yum -y install git
cd /root
git clone https://gitee.com/laowu5/EwoMail.git
cd /root/EwoMail/install
#需要输入一个邮箱域名，不需要前缀，列如下面的ewomail.cn
sh ./start.sh ewomail.cn
```

### 1.2 在线安装 （centos7/8）安装方式(三)

安装前请服务器必须已链接网络，安装时间将会根据你的系统配置和网络环境大概会在10分钟内安装完成。（需要root权限）

安装前需要先安装wget

打开：http://www.ewomail.com/list-11.html 输入你的域名获取安装代码

```JSON
wget -c https://down.ewomail.com/install-03.sh && sh install-03.sh eric.com
```

安装成功后将会输出”Complete installation”。

查看安装的域名和数据库密码

```Nginx
cat /ewomail/config.ini
domain：eric.com
mysql-root-password：4ASPvQLJPbfe8DxG
mysql-ewomail-password：UYoPppKmqObKQk7V
```

## 2 重启

```Plain
systemctl restart nginx php-fpm mysqld postfix dovecot amavisd
```

## 3 访问

**访问地址（将IP更换成你服务器IP即可）**

邮箱管理后台：http://IP:8010 （默认账号admin，密码ewomail123） ssl端口 https://IP:7010

web邮件系统：http://IP:8000 ssl端口 https://IP:7000

域名解析完成后，可以用子域名访问，例如下面 [http://mail.xxx.com:8000](http://mail.xxx.com:8000/) (http) [https://mail.xxx.com:7000](https://mail.xxx.com:7000/) (ssl)

配置host

```Plain
172.100.3.66 devops eric.com mail.eric.com smtp.eric.com imap.eric.com
```

### 3.1 管理员配置

http://eric.com:8010

默认账号admin，密码ewomail123

![img](https://xlymqcg2kt.feishu.cn/space/api/box/stream/download/asynccode/?code=ODI4NjRjMzVlY2RjZjM0MjQ5MzFjMWI1YmE0YmQzYThfWnVjUHJBSnBmUzN2YkswZElrMk42OTJYQTY1R1JpeXFfVG9rZW46Szl2TmJUU2hxb0VIVGN4NXZiSWN0MEZabjdkXzE2ODI0NzcyNDg6MTY4MjQ4MDg0OF9WNA)

![img](https://xlymqcg2kt.feishu.cn/space/api/box/stream/download/asynccode/?code=MzI4NjdjNGVlMzVmM2M0YTEwMGJlN2VlM2FlOGJmN2NfeDRDYXJvT0FTSW5jMjBCM2JlRlNjUWpzVGszcXJybEtfVG9rZW46QkNod2IxUXFQb3A5OWt4cHhhRmNMbGtwbkJnXzE2ODI0NzcyNDg6MTY4MjQ4MDg0OF9WNA)

### 3.2用户邮箱登录

![img](https://xlymqcg2kt.feishu.cn/space/api/box/stream/download/asynccode/?code=ZTE5ZjdlNjA3YTM1YWVhMGJiYWM4Mjk1YTkxOGJmM2Nfd1pieTJDTlpGVTBGb0lsOTFpY0hsOHk2MVpIdmVFRjRfVG9rZW46WEwzNWI1cG9Ob0NiVWd4NERucmMwellmbnViXzE2ODI0NzcyNDg6MTY4MjQ4MDg0OF9WNA)

发送内部邮件测试

![img](https://xlymqcg2kt.feishu.cn/space/api/box/stream/download/asynccode/?code=ZmUzMzNlOGY3YzZhMjEwOWJiZGFmZjM3OTRlMzc3MDRfVldRTDZBZ05JVDBBa3lTeDFkSGo5RGhLbDVZYlJBWmxfVG9rZW46SXBNZWJRMmRnbzNMNTV4RVI2M2NXUG56bnpmXzE2ODI0NzcyNDg6MTY4MjQ4MDg0OF9WNA)

![img](https://xlymqcg2kt.feishu.cn/space/api/box/stream/download/asynccode/?code=ODkwOTRlNjY3MzNmYmUyYjk1NjI4YWM0ZWIxZmVmMDVfa1FKNlZBdEFBNGY4ZGJ0ckJvM0RNTjNLVWdyZjFkMXNfVG9rZW46TVpoYmIzamRFb1oxQlp4WktjaWNuc2Npbm5nXzE2ODI0NzcyNDg6MTY4MjQ4MDg0OF9WNA)

发送外部邮件测试

![img](https://xlymqcg2kt.feishu.cn/space/api/box/stream/download/asynccode/?code=MTRmMjk5ZGVkY2Y2ZGM0Y2ZlMTU3NWQ3OWY5MjZiY2ZfR2NzbzJlTlJyRmtLZFI1bGJxcU5lbzVha0k2SFFYNE1fVG9rZW46T2w4VGIzeXhTb3JNWG54RjF1bWNXbWdubnVlXzE2ODI0NzcyNDg6MTY4MjQ4MDg0OF9WNA)

## 4 配置应用测试

vim docker-compose.yml

```JavaScript
version: "3"

services:
  phpldapadmin:
    image: registry.cn-hangzhou.aliyuncs.com/erictor888/phpldapadmin:1.2.5
    depends_on:
      - openldap
    environment:
      PHPLDAPADMIN_HTTPS: false
      PHPLDAPADMIN_LDAP_HOSTS: 172.100.3.66
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
      LDAP_SERVER: ldap://172.100.3.66:389
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
      MAIL_FROM: devops@eric.com
      MAIL_FROM_NAME: devops
      NOTIFY_ON_CHANGE: true
      SMTP_HOST: smtp.eric.com
      SMTP_AUTH_ON: true
      SMTP_USER: devops@eric.com
      SMTP_PASS: Abc,123.
      SMTP_PORT: 465
      SMTP_SECURE_TYPE: ssl
    volumes:
      - /apps/ldap/self-service-password:/www
    ports:
      - "8989:80"
```
