## LDAP创建组织

- 参考文档：[https://www.cnblogs.com/mascot1/p/10498460.html](https://gitee.com/link?target=https%3A%2F%2Fwww.cnblogs.com%2Fmascot1%2Fp%2F10498460.html)

### 1 创建OU

![img](..\images\ldap4.png)

- 选择Organisational unit 组织单元 

![img](..\images\ldap5.png)

- 输入OU名称 

![img](..\images\ldap6.png)

- 提交信息 

![img](..\images\ldap7.png)

- 查看结果 

![img](..\images\ldap8.png)

### 2 创建人员

- 选择OU->选择新建子条目 

![img](..\images\ldap9.png)

- 选择默认模板 

![img](..\images\ldap10.png)

- 选择inetorgperson 

![img](..\images\ldap11.png)

- 填写并提交信息 

![img](..\images\ldap12.png)

![img](https://xlymqcg2kt.feishu.cn/space/api/box/stream/download/asynccode/?code=N2M0NmVmYjc2MDNiMGU1YTRhNmI3ZDU3MGM5MTZhNTNfeGJ4STFJc3E4UDJNWjkyS2hBQTVmMlZNeVhXWDBvOGNfVG9rZW46Ym94Y25XeDBJbmVuUUZTSTFFQnRtd0FtTXlnXzE2ODI0MDcyNjQ6MTY4MjQxMDg2NF9WNA)

- 用户创建完成 

![img](..\images\ldap13.png)

![img](..\images\ldap14.png)

## Jenkins集成LDAP

- 参考文档：[https://www.cnblogs.com/mascot1/p/10498513.html](https://gitee.com/link?target=https%3A%2F%2Fwww.cnblogs.com%2Fmascot1%2Fp%2F10498513.html)

### 1 先决条件

- 准备一个adminDN账号用于查询用户。 cn=admin,dc=east-port,dc=com
- 2.将访问Jenkins的用户放到一个OU中。 ou=jenkins,dc=my-domain,dc=com
- 3.提供ldap服务器地址。 ldap://192.168.88.10:389

### 2 Jenkins配置

- 安装ldap插件 

![img](..\images\ldap15.png)

- 系统配置-系统管理-全局安全配置 
  -  -安全域-选择-LDAP

  -  服务器:ldap://192.168.88.10:389

  -  User search base :**ou=jenkins,dc=east-port,dc=com**

  -  Group search base:**ou=jenkins,dc=east-port,dc=com**

  - Search for LDAP groups containing user

Manager DN:cn=admin,dc=east-port,dc=com

Manager Password:1qaz2wsx!@

![img](..\images\ldap16.png)

- 选择账号测试，出现一下信息集成完毕 

![img](..\images\ldap17.png)