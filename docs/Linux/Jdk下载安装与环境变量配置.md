#
# 1. Jdk下载

jdk8 下载：https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html

![img](..\images\jdk.png)

官方最新版本下载:https://www.oracle.com/cn/java/technologies/downloads/#java17

# 2. 环境变量配置

## 2.1 windows配置方法：

此电脑（计算机）-右键-属性-高级系统设置-环境变量

截图为window10设置

![img](..\images\jdk2.png)

在系统变量新建，

```Bash
变量名输入：JAVA_HOME
变量值输入：C:\Program Files\Java\jdk1.8.0_202
```

![img](..\images\jdk3.png)

然后再新建：

```Bash
变量名输入：CLASSPATH（这个也是全部大写！！）
变量值输入：.;%JAVA_HOME% \lib（注意是英文格式下：点 分号 百分号JAVA_HOME百分号 反斜杠 lib）千万别写错！错！错！~~~
```

![img](..\images\jdk4.png)

然后选中path-编辑-新建：

```Bash
新建输入：%JAVA_HOME%\bin
```

![img](..\images\jdk5.png)

确定。在cmd输入java -version验证。

```Bash
PS C:\Users\Administrator> java -version
java version "1.8.0_202"
Java(TM) SE Runtime Environment (build 1.8.0_202-b08)
Java HotSpot(TM) 64-Bit Server VM (build 25.202-b08, mixed mode)
```

## 2.2 Linux配置方法：

系统配置： 编辑 /etc/profile，用户配置：编辑  ~/.bash_profile 添加一下内容 source 一下

```Bash
vim /etc/profile
JAVA_HOME=/apps/jdk1.8.0_211
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tool.jar

export PATH=$JAVA_HOME/bin:$PATH

source /etc/profile

java -version
java version "1.8.0_211"
Java(TM) SE Runtime Environment (build 1.8.0_211-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.211-b12, mixed mode)
```