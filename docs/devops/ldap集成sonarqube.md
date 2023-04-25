## 安装插件 

8.9 之后不支持ldap插件：https://docs.sonarqube.org/8.9/instance-administration/plugin-version-matrix/

1、下载 **LDAP** **Plugin** 插件，地址：https://docs.sonarqube.org/display/SONARQUBE67/LDAP+Plugin 2、将下载的插件，放到 SONARQUBE_HOME/extensions/plugins 目录

## 配置LDAP （AD域）

配置文件路径：SONARQUBE_HOME/conf/sonar.properties 直接添加以下内容，保存并重启即可

```Bash
# LDAP configuration
# General Configuration
sonar.security.realm=LDAP
ldap.url=ldap://192.168.90.220:389
ldap.bindDn=userget@test.com
ldap.bindPassword=test
 
# User Configuration
ldap.user.baseDn=cn=users,dc=test,dc=com
ldap.user.request=(&(objectClass=user)(sAMAccountName={login}))
ldap.user.realNameAttribute=displayName
ldap.user.emailAttribute=mail
 
# Group Configuration
ldap.group.baseDn=cn=groups,dc=test,dc=com
ldap.group.request=(&(objectClass=group)(member={dn}))
ldap.group.idAttribute=sAMAccountName
```

官方配置手册：https://docs.sonarqube.org/display/SONARQUBE67/LDAP+Plugin