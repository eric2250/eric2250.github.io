# 安装东方通TongLINK/Q

## Linux安装

### 获取软件：

链接：https://pan.baidu.com/s/11dWEbDNBnO7wNKh5cr2cMg?pwd=8888 
提取码：8888

### 解压软件

```
tar zxvf Install_TLQ_Standard_Linux2.6.32_x86_64_8.1.16.1.tar.gz 

#赋值key
cp license.dat TLQ8/


```

### 配置环境变量

```
vim setp
#修改$PWD为安装目录：/apps/tlq/TLQ8
cat setp >> ~/.bash_profile
source /apps/tlq/TLQ8
```

### 测试

```
[root@ha2 TLQ8]# tlq -h

Usage:
tlq -h|-?|
	-c<cmd> |-w<time>|-y|
  -h or -?, display help message
  -c<cmd>, start or stop command
     cmd = start, start TLQ. default is start
     cmd = stop,  stop TLQ after AP stopped 
     cmd = abort, stop TLQ after AP being killed 
  -w<time>, time for waiting AP end(seconds)
  -y,   when stop TLQ, no prompt
  -u<TLQLicenseFlag>,  display TLQ License Message flag(1-enable 0-disable)

```

### 客户端安装

```
tar zxvf Install_TLQCli_Standard_Linux2.6.32_x86_64_8.1.16.1.tar.gz 
cd TLQCli8/
vim setp 
#修改$PWD为安装目录：/apps/tlq/TLQCli8
cat  setp >>~/.bash_profile 
source ~/.bash_profile 


```





命令：

```
#启动
tlq -cstart
#查看进程
ps -ef |grep tl_
#强制停止
tlq -cabort -y -w1
#停止
tlq -cstop
#查看qcu1 状态
tlqstat -qcu qcu1 -c
```

### 发送消息测试

编译javadome

```
cd /apps/tlq/TLQCli8/samples/demo_java/base
javac *.java
```

发送消息

```
#放消息
[root@ha2 base]# java SendMsgCli qcu1 lq B no
qcuname=qcu1
myMsgType is :B
--------------共发送消息2条!-----------
-----------sendmsg over!!-----------
[root@ha2 base]# tlqstat -qcu qcu1 -c
[Send Queue General Information]:

Quename                                                Ready  Snding  Rcving   WaitAck       Delay
sq                                                         0       0       0         0           0

[Local Queue General Information]:

Quename                                                Ready  Snding  Rcving   WaitAck       Delay  Getor
lq                                                         2       0       0         0           0      0
TLQ.SYS.EVENT                                              0       0       0         0           0      0
TLQ.SYS.DEAD                                               0       0       0         0           0      0
TLQ.SYS.BROKER.CONTROL                                     0       0       0         0           0      0
TLQ.SYS.BROKER.SYN                                         0       0       0         0           0      0
TLQ.SYS.BROKER.SUB                                         0       0       0         0           0      0
TLQ.SYS.BROKER.SUBREQ                                      0       0       0         0           0      0

[Remote Queue General Information]:

Quename                    SndQName                   DestQName                  SndConnName                HostName                ConnPort  ConnType  ConnStatus
rq                         sq                         lq                         conn1                      127.0.0.1                  10004  long      close   
rq3                        sq                         TLQ.SYS.BROKER.SYN         conn1                      127.0.0.1                  10004  long      close   

[Virtual Queue General Information]:

Quename                                           LocalQueName                                           Ready
#取消息
[root@ha2 base]# java GetMsgCli qcu1 lq 0
--------------------receive message begin------------------
Received a Buffer Msg
msgInfo.MsgId=ID:cfcdddab8000065f164d661100000   msgInfo.MsgSize=10
Received a Buffer Msg
msgInfo.MsgId=ID:cfcdddab8000065f164d661100001   msgInfo.MsgSize=10
com.tongtech.tlq.base.TlqException:syserr:2,tlqerrno:2603:tlq_getmsg: no message matched in the queue now
	at com.tongtech.tlq.base.ClientKernel.tlqGetMsg(Native Method)
	at com.tongtech.tlq.base.KernelFacade.tlqGetMsg(KernelFacade.java:251)
	at com.tongtech.tlq.base.TlqQCU.getMessage(TlqQCU.java:176)
	at GetMsgCli.recvMsg(GetMsgCli.java:76)
	at GetMsgCli.main(GetMsgCli.java:125)
----------GetMsg is over!------------

-------共接收消息2条-------

```

