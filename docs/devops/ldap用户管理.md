# 命令行模式

## 新建用户

- 例如，要创建用户 eric，

```Bash
echo -e "dn: uid=eric,ou=eport,dc=east-port,dc=cn
cn: 文强
displayname: 文强
gidnumber: 0
givenname: eric
homedirectory: /home/users/eric
loginshell: /bin/sh
mail: eric@east-port.cn
objectclass: posixAccount
objectclass: top
objectclass: inetOrgPerson
sn: eric
uid: eric
uidNumber:37366
userpassword: eric@123">/tmp/eric
```

- 可以在 eric文件中看到以下内容:

```Bash
cat /tmp/eric
dn: uid=eric,ou=eport,dc=east-port,dc=cn
cn: 文强
displayname: 文强
gidnumber: 0
givenname: eric
homedirectory: /home/users/eric
loginshell: /bin/sh
mail: eric@east-port.cn
objectclass: posixAccount
objectclass: top
objectclass: inetOrgPerson
sn: eric
uid: eric
uidNumber:37366
userpassword: eric@123
```

- 使用以下命令将用户 eric添加到 LDAP

```Bash
#ldapadd -H ldap://172.100.2.201:389 -x -D 'cn=admin,dc=east-port,dc=cn' -f /tmp/eric   -w Abc,123.
adding new entry "uid=eric,ou=eport,dc=east-port,dc=cn"
```

## 将用户eric添加到test组:

```Bash
echo -e "dn: cn=test,ou=eport,dc=east-port,dc=cn
changetype: modify
add: uid=eric,ou=eport,dc=east-port,dc=cn" >/tmp/eric-add-eport
```

- 可以在文件中看到以下内容:

```Bash
#cat /tmp/eric-add-eport
dn: cn=test,ou=eport,dc=east-port,dc=cn
changetype: modify
add: uid=eric,ou=eport,dc=east-port,dc=cn
```

- 使用以下命令将用户 eric添加到 test组:

```Bash
#ldapmodify -H ldap://172.100.2.201:389 -x -D 'cn=admin,dc=east-port,dc=cn' -f /tmp/eric-add-eport -w Abc,123.
modifying entry "cn=test,ou=eport,dc=east-port,dc=cn"
```

## 搜索查看

```Bash
#ldapsearch -H ldap://172.100.2.201:389 -x -D 'cn=admin,dc=east-port,dc=cn' -w Abc,123
```

# 使用工具或网页

因为用户管理为ldap服务管理。所以新建用户及密码重置等需要登陆ldap后台操作

### 方法1：利用工具操作（推荐）

下载安装LdapAdmin工具：http://www.ldapadmin.org/

（1）打开软件-添加ldap服务器连接-填写ldap服务器信息-test-ok

Host ：172.100.2.201 端口：389 

Base：dc=east-port,dc=cn  可不填，点击FetchDNs按钮自动生成

管理员用户名：cn=admin,dc=east-port,dc=cn

管理员密码：Abc,123.

![img](..\images\ldap18.png)

![img](..\images\ldap19.png)

（2）新建操纵

新建组：

选择ou右键-New-Group-填写信息-OK

![img](..\images\ldap20.png)

![img](..\images\ldap21.png)

#### 新建用户：

选择ou右键-New-User-填写信息-选择组-OK

![img](..\images\ldap22.png)

![img](..\images\ldap23.png)

![img](..\images\ldap24.png)

#### 设置密码：

选择用户右键-set-password-输入密码-OK

![img](..\images\ldap25.png)

![img](..\images\ldap26.png)

### 方法2：登录ldap网页端后台操作

-  登录ldap后台：

-  （1）登录地址：http://ldap.east-port.cn/ldapadmin/

-  管理员用户名：cn=admin,dc=east-port,dc=cn

-  管理员密码：Abc,123.

- ![img](..\images\ldap27.png)

-   （2）新建操作：

#### 新建组：

-   选中新建ou（用户组新建在此ou下）-新建子条目-Generic: Posix Group-输入组名称-确认信息

![img](..\images\ldap28.png)

![img](..\images\ldap29.png)

![img](..\images\ldap30.png)

![img](..\images\ldap31.png)

![img](..\images\ldap32.png)

#### 新建用户：

选中新建ou（用户新建在此ou下）-新建子条目-Generic: User Account-输入组名称-确认信息

![img](..\images\ldap33.png)

![img](..\images\ldap34.png)

![img](..\images\ldap35.png)

![img](..\images\ldap36.png)

![img](..\images\ldap37.png)