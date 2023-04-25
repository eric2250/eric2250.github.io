参考：https://blog.csdn.net/Im_Shuang/article/details/123550353

# 安装插件

[插件名称：Role-based Authorization Strategy](https://plugins.jenkins.io/role-strategy)

![img](..\images\jenkins1.png)

# 配置Jenkins

### 打开系统设置--**Configure Global Security（全局权限设置）**

![img](..\images\jenkins2.png)

### 将授权策略修改为Role-Based Strategy-保存

![img](..\images\jenkins3.png)

### 打开系统设置-**Manage and Assign Roles（选择上面后多出的选项）-点击进入**

![img](..\images\jenkins4.png)

#### 点击**Manage Roles-设置角色**

![img](..\images\jenkins5.png)

##### 设置全局角色与item 角色-如图-保存

全局角色权限必须设置admin为管理权限，build为其他只允许查看权限（不设置登录无法查看内容）

item 角色为按照匹配规则实现指定用户实现指定权限，如001组只可看见构建001开头JOB

![img](..\images\jenkins6.png)

### 点击**Assign Roles-分配角色**

![img](..\images\jenkins7.png)

##### 设置全局角色与item 角色-如图-保存

![img](..\images\jenkins8.png)

### 登录测试

test组成员登录

![img](..\images\jenkins9.png)

dev组成员登录

![img](..\images\jenkins11.png)