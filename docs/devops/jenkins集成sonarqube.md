# Jenkins下载sonarqube插件 SonarQube Scanner

![sonar](..\images\sonar.png)

# sonar获取token

### 登录sonarqube-配置-权限下拉选用户

![img](..\images\sonar1.png)

### 选择需要生成token的用户-点击令牌下面

![img](..\images\sonar2.png)

### 创建token，复制token值，只出现一次，务必记住，忘记重新生成

```Bash
34171249621e4537fb63528d4586723440d1709c
```

![img](..\images\sonar3.png)

# Jenkins配置sonarqube

[系统管理](http://jenkins.east-port.cn/manage/)-Configure System-SonarQube servers-add

![img](..\images\sonar4.png)

选择token时，如果未新建需要点添加-新建刚才生成的token值

```Bash
34171249621e4537fb63528d4586723440d1709c
```

![img](..\images\sonar5.png)

# 问题处理

sonar-scanner扫描代码出错 SonarQube svn: E170001

![img](..\images\sonar6.png)

```Bash
11:04:35  [ERROR] Failed to execute goal org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.1.2184:sonar (default-cli) on project pms: Authentication error when executing blame for file pms-service/src/main/java/com/eport/pms/service/ChangeProjectCostProductService.java: svn: E170001: Authentication required for '<svn://172.100.2.10:3690> pms' -> [Help 1]
```

问题原因： sonar-runner发现了.svn文件，于是启动了自己的SVN插件，去访问SVN，但是又没有对应SVN路径的授权所以就报错。

```Plaintext
1.打开sonarqube的控制台，使用admin登录后 ，在配置->SCM->菜单中，将Disabled the SCM Sensor设置为true，
第一步就可以了
下面 我的sonarqube没找见 SVN 
2.在svn页面，设置svn的用户名和密码。
```

![img](..\images\sonar7.png)