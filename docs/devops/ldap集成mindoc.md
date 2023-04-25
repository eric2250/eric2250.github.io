```Bash
修改配置文件
################Active Directory/LDAP################
#是否启用ldap
ldap_enable=true
#ldap主机名
ldap_host=172.100.2.201
#ldap端口
ldap_port=389
#ldap内哪个属性作为用户名
ldap_attribute=uid
#搜索范围
ldap_base=dc=east-port,dc=cn
#第一次绑定ldap用户dn
ldap_user=cn=admin,dc=east-port,dc=cn
#第一次绑定ldap用户密码
ldap_password=Abc,123.
#自动注册用户角色：0 超级管理员 /1 管理员/ 2 普通用户
ldap_user_role=2
#ldap搜索filter规则,AD服务器: objectClass=User, openldap服务器: objectClass=posixAccount ,也可以定义为其他属性,如: title=mindoc
ldap_filter=objectClass=posixAccountxxxxxxxxxx 
```