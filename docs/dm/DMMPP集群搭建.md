## 前置准备

MPP01
已经安装好dm8数据库

```
外网ip地址：192.168.88.10
内网ip地址：192.168.66.10
```

MPP02
已经安装好dm8

```
外网ip地址：192.168.88.11
内网ip地址：192.168.66.11
```

monitor
已经安装好dm8

```
内网ip地址：192.168.66.130
```



## 数据库初始化

### 在两台节点上初始化数据库

#MPP01机器

```
#mpp01主库
./dminit PATH=/data/dmdata/data DB_NAME=MPP01 INSTANCE_NAME=MPP01
#mpp02备库
./dminit PATH=/data/dmdata/data DB_NAME=BACKUPMPP02 INSTANCE_NAME=BACKUPMPP02
```

#MPP02机器

```
#MPP02主库
dminit PATH=/data/dmdata/data DB_NAME=MPP02 INSTANCE_NAME=MPP02
#MPP01备库
dminit PATH=/data/dmdata/data DB_NAME=BACKUPMPP01 INSTANCE_NAME=BACKUPMPP01
```

#实例启动

```
dmserver /data/dmdata/data/MPP01/dm.ini
dmserver /data/dmdata/data/MPP02/dm.ini
```

### 分别进行数据库的脱机备份与脱机恢复

1.配置dm.ini

```
ARCH_INI=1 #打开归档配置
```

2.MPP01配置

```
vim dmarch.ini
[ARCHIVE_LOCAL1]
ARCH_TYPE = LOCAL #本地归档类型
ARCH_DEST = /data/dmdata/data/MPP01/arch #本地归档文件存放路径
ARCH_FILE_SIZE = 128 #单位 Mb，本地单个归档文件最大值
ARCH_SPACE_LIMIT = 0 #单位 Mb，0 表示无限制，范围 1024~2147483647M
```

此处为脱机备份和脱机还原的方式

1.MPP01关闭数据库
2.MPP01进行脱机备份

```
dmrman CTLSTMT="BACKUP DATABASE '/data/dmdata/data/MPP01/dm.ini' FULL TO BACKUP_FILE1 BACKUPSET '/data/dmdata/data/BACKUP_MPP01'"
```

3.拷贝至备库

```
scp -r /data/dmdata/data/BACKUP_MPP01 192.168.66.11:/data/dmdata/data
```

4.MPP02进行脱机数据库还原和恢复

```
dmrman CTLSTMT="RESTORE DATABASE '/data/dmdata/data/BACKUPMPP01/dm.ini' FROM BACKUPSET '/data/dmdata/data/BACKUP_MPP01'"
```

/*因为脱机备份没有产生任何 REDO 日志，所以恢复这一步此处省略*/

```
./dmrman CTLSTMT="RECOVER DATABASE '/data/dmdata/data/BACKUPMPP01/dm.ini' UPDATE DB_MAGIC"
```

1.MPP02配置dm.ini

```
ARCH_INI=1 #打开归档配置
```

2.MPP02配置

vim dmarch.ini

```
[ARCHIVE_LOCAL1]
ARCH_TYPE = LOCAL #本地归档类型
ARCH_DEST = /data/dmdata/data/MPP02/arch #本地归档文件存放路径
ARCH_FILE_SIZE = 128 #单位 Mb，本地单个归档文件最大值
ARCH_SPACE_LIMIT = 0 #单位 Mb，0 表示无限制，范围 1024~2147483647M
```

1.MPP02关闭数据库
2.MPP02进行脱机备份

```
dmrman CTLSTMT="BACKUP DATABASE '/data/dmdata/data/MPP02/dm.ini' FULL TO BACKUP_FILE1 BACKUPSET '/data/dmdata/data/BACKUP_MPP02'"
```

3.拷贝至MPP01

```
scp -r /data/dmdata/data/BACKUP_MPP02 192.168.66.10:/data/dmdata/data
```

4.MPP01进行脱机数据库还原和恢复

```
dmrman CTLSTMT="RESTORE DATABASE '/data/dmdata/data/BACKUPMPP02/dm.ini' FROM BACKUPSET '/data/dmdata/data/BACKUP_MPP02'"
```

/*因为脱机备份没有产生任何 REDO 日志，所以恢复这一步此处省略*/

```
./dmrman CTLSTMT="RECOVER DATABASE '/data/dmdata/data/BACKUPMPP02/dm.ini' UPDATE DB_MAGIC"
```


备份还原后检查file_lsn和cur_lsn与魔数是否一致

```
select file_LSN, cur_LSN from v$rlog;
select permanent_magic;
```

### 配置MPP01

配置dm.ini
/data/dmdata/data/MPP01/dm.ini

```
 16 INSTANCE_NAME = MPP01
260 PORT_NUM = 5236 #数据库实例监听端口
446 RLOG_SEND_APPLY_MON = 64 #统计最近 64 次的日志发送信息
664 DW_INACTIVE_INTERVAL = 60 #接收守护进程消息超时时间
666 ALTER_MODE_STATUS = 0 #不允许手工方式修改实例模式/状态/OGUID
667 ENABLE_OFFLINE_TS = 2 #不允许备库 OFFLINE 表空间
683 MAL_INI = 1 #打开 MAL 系统
684 ARCH_INI = 1 #打开归档配置
688 MPP_INI = 1 #启用 MPP 配置
```

配置dmmal.ini
vim /data/dmdata/data/MPP01/dmmal.ini

```
MAL_CHECK_INTERVAL = 5 #MAL 链路检测时间间隔
MAL_CONN_FAIL_INTERVAL = 5 #判定 MAL 链路断开的时间
[MAL_INST1]
MAL_INST_NAME = MPP01#实例名，和 dm.ini 中的 INSTANCE_NAME 一致
MAL_HOST = 192.168.66.10 #MAL 系统监听 TCP 连接的 IP 地址
MAL_PORT = 5337 #MAL 系统监听 TCP 连接的端口
MAL_INST_HOST = 192.168.88.10 #实例的对外服务 IP 地址
MAL_INST_PORT = 5236 #实例的对外服务端口，和 dm.ini 中的 PORT_NUM 一致
MAL_DW_PORT = 5253 #实例对应的守护进程监听 TCP 连接的端口
MAL_INST_DW_PORT = 5243 #实例监听守护进程 TCP 连接的端口
[MAL_INST2]
MAL_INST_NAME = MPP02
MAL_HOST = 192.168.66.11
MAL_PORT = 5337
MAL_INST_HOST = 192.168.88.11
MAL_INST_PORT = 5236
MAL_DW_PORT = 5253
MAL_INST_DW_PORT = 5243
[MAL_INST3]
MAL_INST_NAME = BACKUPMPP01
MAL_HOST =  192.168.66.11
MAL_PORT = 5338
MAL_INST_HOST = 192.168.88.11
MAL_INST_PORT = 5237
MAL_DW_PORT = 5254
MAL_INST_DW_PORT = 5244
[MAL_INST4]
MAL_INST_NAME = BACKUPMPP02
MAL_HOST = 192.168.66.10
MAL_PORT = 5338
MAL_INST_HOST = 192.168.88.10
MAL_INST_PORT = 5237
MAL_DW_PORT = 5254
MAL_INST_DW_PORT = 5244
```

配置dmarch.ini
 vim /data/dmdata/data/MPP01/dmarch.ini

```
[ARCHIVE_REALTIME1]
ARCH_TYPE = REALTIME #实时归档类型
ARCH_DEST = BACKUPMPP01 #实时归档目标实例名
[ARCHIVE_LOCAL1]
ARCH_TYPE = LOCAL #本地归档类型
ARCH_DEST = /data/dmdata/data/BACKUPMPP01/arch #本地归档文件存放路径
ARCH_FILE_SIZE = 128 #单位 Mb，本地单个归档文件最大值
ARCH_SPACE_LIMIT = 0 #单位 Mb，0 表示无限制，范围 1024~4294967294M
```

配置dmmpp.ini
vim /data/dmdata/data/MPP01/dmmpp.ini

```
[service_name1]
mpp_seq_no = 0
mpp_inst_name = MPP01
[service_name2] 
mpp_seq_no = 1
mpp_inst_name = MPP02
```

/home/dmdba/dmdbms/bin
执行转换命令将dmmpp.ini转换成dmmpp.ctl

```
dmctlcvt TYPE=2 SRC=/data/dmdata/data/MPP01/dmmpp.ini DEST=/data/dmdata/data/MPP01/dmmpp.ctl
```


启动MPP01主库

```
dmserver /data/dmdata/data/MPP01/dm.ini mount

```

配置disql

```
disql SYSDBA/SYSDBA@192.168.66.10:5236#{MPP_TYPE=LOCAL}

SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 1);
sp_set_oguid(45330);#设置OGUID
alter database primary;#设置为主库模式
SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 0);
commit;
```

### 配置BACKUPMPP01备库

配置BACKUPMPP01的

vim dm.ini

```
NSTANCE_NAME  = BACKUPMPP01
PORT_NUM  = 5237 #数据库实例监听端口
DW_INACTIVE_INTERVAL  = 60 #接收守护进程消息超时时间
ALTER_MODE_STATUS  = 0 #不允许手工方式修改实例模式/状态/OGUID
ENABLE_OFFLINE_TS  = 2 #不允许备库 OFFLINE 表空间
MAL_INI = 1 #打开 MAL 系统
ARCH_INI  = 1 #打开归档配置
MPP_INI = 1 #打开 MPP 配置
RLOG_SEND_APPLY_MON = 64 #统计最近 64 次的日志重演信息
```

配置BACKUPMPP01的

vim dmarch.ini

```
[ARCHIVE_REALTIME1]
ARCH_TYPE = REALTIME #实时归档类型
ARCH_DEST = MPP01 #实时归档目标实例名
[ARCHIVE_LOCAL1]
ARCH_TYPE = LOCAL #本地归档类型
ARCH_DEST = /data/dmdata/data/BACKUPMPP01/arch #本地归档文件存放路径
ARCH_FILE_SIZE = 128  #单位 Mb，本地单个归档文件最大值
ARCH_SPACE_LIMIT  = 0 #单位 Mb，0 表示无限制，范围 1024~4294967294M

```


将MPP01的dmmal.ini与dmmpp.ctl发送至BACKUPMPP01

```
scp /data/dmdata/data/MPP01/dmmal.ini 192.168.66.11:/data/dmdata/data/BACKUPMPP01 
scp /data/dmdata/data/MPP01/dmmpp.ctl 192.168.66.11:/data/dmdata/data/BACKUPMPP01 
```


以mount启动备库BACKUPMPP01

```
dmserver /data/dmdata/data/BACKUPMPP01/dm.ini mount

```

修改BACKUPMPP01进入备库状态
#以local模式启动disql

```
disql SYSDBA/SYSDBA@192.168.66.11:5237#{MPP_TYPE=LOCAL} 
```

执行以下指令

```
SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 1);
sp_set_oguid(45330);
ALTER DATABASE standby; 
SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 0);
commit;
```

配置MPP02
配置dm.ini

```
INSTANCE_NAME = MPP02
PORT_NUM = 5236 #数据库实例监听端口
DW_INACTIVE_INTERVAL = 60 #接收守护进程消息超时时间
ALTER_MODE_STATUS = 0 #不允许手工方式修改实例模式/状态/OGUID
ENABLE_OFFLINE_TS = 2 #不允许备库 OFFLINE 表空间
MAL_INI = 1 #打开 MAL 系统
ARCH_INI = 1 #打开归档配置
MPP_INI = 1 #启用 MPP 配置
RLOG_SEND_APPLY_MON = 64 #统计最近 64 次的日志发送信息
```


配置dmmal.ini
与上述的MPP01一致

```
MAL_CHECK_INTERVAL = 5 #MAL 链路检测时间间隔
MAL_CONN_FAIL_INTERVAL = 5 #判定 MAL 链路断开的时间
[MAL_INST1]
MAL_INST_NAME = MPP01#实例名，和 dm.ini 中的 INSTANCE_NAME 一致
MAL_HOST = 192.168.66.10 #MAL 系统监听 TCP 连接的 IP 地址
MAL_PORT = 5337 #MAL 系统监听 TCP 连接的端口
MAL_INST_HOST = 192.168.88.10 #实例的对外服务 IP 地址
MAL_INST_PORT = 5236 #实例的对外服务端口，和 dm.ini 中的 PORT_NUM 一致
MAL_DW_PORT = 5253 #实例对应的守护进程监听 TCP 连接的端口
MAL_INST_DW_PORT = 5243 #实例监听守护进程 TCP 连接的端口
[MAL_INST2]
MAL_INST_NAME = MPP02
MAL_HOST = 192.168.66.11
MAL_PORT = 5337
MAL_INST_HOST = 192.168.88.11
MAL_INST_PORT = 5236
MAL_DW_PORT = 5253
MAL_INST_DW_PORT = 5243
[MAL_INST3]
MAL_INST_NAME = BACKUPMPP01
MAL_HOST =  192.168.66.11
MAL_PORT = 5338
MAL_INST_HOST = 192.168.88.11
MAL_INST_PORT = 5237
MAL_DW_PORT = 5254
MAL_INST_DW_PORT = 5244
[MAL_INST4]
MAL_INST_NAME = BACKUPMPP02
MAL_HOST = 192.168.66.10
MAL_PORT = 5338
MAL_INST_HOST = 192.168.88.10
MAL_INST_PORT = 5237
MAL_DW_PORT = 5254
```


配置dmarch.ini

```
[ARCHIVE_REALTIME1]
ARCH_TYPE = REALTIME #实时归档类型
ARCH_DEST = MPP02 #实时归档目标实例名
[ARCHIVE_LOCAL1]
ARCH_TYPE = LOCAL #本地归档类型
ARCH_DEST = /data/dmdata/data/MPP02 #本地归档文件存放路径
ARCH_FILE_SIZE = 128 #单位 Mb，本地单个归档文件最大值
ARCH_SPACE_LIMIT = 0 #单位 Mb，0 表示无限制，范围 1024~4294967294M
```


配置dmmpp.ctl
从MPP01发送给MPP02

```
scp dmmpp.ctl 192.168.66.11:/data/dmdata/data/MPP02
```


以mount启动备库

```
./dmserver /data/dmdata/data/MPP02/dm.ini mount
```


启动disql登录设置OGUID

```
./disql SYSDBA/SYSDBA@192.168.66.11:5236#{MPP_TYPE=LOCAL}
SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 1);
sp_set_oguid(45331);
ALTER DATABASE PRIMARY; 
SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 0);
commit;
```

配置备库BACKUPMPP02
配置BACKUPMPP02的dm.ini

```
INSTANCE_NAME  = BACKUPMPP02
PORT_NUM  = 5237 #数据库实例监听端口
DW_INACTIVE_INTERVAL  = 60 #接收守护进程消息超时时间
ALTER_MODE_STATUS  = 0 #不允许手工方式修改实例模式/状态/OGUID
ENABLE_OFFLINE_TS  = 2 #不允许备库 OFFLINE 表空间
MAL_INI = 1 #打开 MAL 系统
ARCH_INI  = 1 #打开归档配置
MPP_INI = 1 #打开 MPP 配置
RLOG_SEND_APPLY_MON = 64 #统计最近 64 次的日志重演信息
```


配置BACKUPMPP02的dmarch.ini

```
[ARCHIVE_REALTIME1]
ARCH_TYPE = REALTIME #实时归档类型
ARCH_DEST = MPP02 #实时归档目标实例名
[ARCHIVE_LOCAL1]
ARCH_TYPE = LOCAL #本地归档类型
ARCH_DEST = /data/dmdata/data/BACKUPMPP02/arch #本地归档文件存放路径
ARCH_FILE_SIZE = 128  #单位 Mb，本地单个归档文件最大值
ARCH_SPACE_LIMIT  = 0 #单位 Mb，0 表示无限制，范围 1024~4294967294M
```


将MPP02的dmmal.ini与dmmpp.ctl发送至BACKUPMPP02

```
scp /data/dmdata/data/MPP02/dmmal.ini 192.168.66.10:/data/dmdata/data/BACKUPMPP02
scp /data/dmdata/data/MPP02/dmmpp.ctl 192.168.66.10:/data/dmdata/data/BACKUPMPP02 
```


mount启动BACKUPMPP02

```
./dmserver /data/dmdata/data/BACKUPMPP02/dm.ini mount
```


配置OGUID和备库模式

```
./disql SYSDBA/SYSDBA@192.168.66.11:5237#{MPP_TYPE=LOCAL}
SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 1);
sp_set_oguid(45331);
ALTER DATABASE standby; 
SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 0);
commit;
```

配置MPP01与MPP02的dmwatcher.ini
MPP01的dmwatcher.ini

```
[GRP1]
DW_TYPE = GLOBAL #全局守护类型
DW_MODE = AUTO #自动切换模式
DW_ERROR_TIME = 10  #远程守护进程故障认定时间
INST_RECOVER_TIME = 60 #主库守护进程启动恢复的间隔时间
INST_ERROR_TIME = 10  #本地实例故障认定时间
INST_OGUID = 45330 #守护系统唯一 OGUID 值
INST_INI = /data/dmdata/data/MPP01/dm.ini #dm.ini 配置文件路径
INST_AUTO_RESTART = 1 #打开实例的自动启动功能
INST_STARTUP_CMD = /home/dmdba/dmdbms/bin/dmserver #命令行方式启动
RLOG_SEND_THRESHOLD = 0 #指定主库发送日志到备库的时间阀值，默认关闭
RLOG_APPLY_THRESHOLD = 0 #指定备库重演日志的时间阀值，默认关闭
[GRP2]
DW_TYPE = GLOBAL #全局守护类型
DW_MODE = AUTO #自动切换模式
DW_ERROR_TIME = 10  #远程守护进程故障认定时间
INST_RECOVER_TIME = 60 #主库守护进程启动恢复的间隔时间
INST_ERROR_TIME = 10  #本地实例故障认定时间
INST_OGUID = 45331 #守护系统唯一 OGUID 值
INST_INI = /data/dmdata/data/BACKUPMPP02/dm.ini #dm.ini 配置文件路径
INST_AUTO_RESTART = 1 #打开实例的自动启动功能
INST_STARTUP_CMD = /home/dmdba/dmdbms/bin/dmserver #命令行方式启动
RLOG_SEND_THRESHOLD = 0 #指定主库发送日志到备库的时间阀值，默认关闭
RLOG_APPLY_THRESHOLD = 0 #指定备库重演日志的时间阀值，默认关闭
```


MPP02的dmwatcher.ini

```
[GRP1]
DW_TYPE = GLOBAL #全局守护类型
DW_MODE = AUTO #自动切换模式
DW_ERROR_TIME = 10  #远程守护进程故障认定时间
INST_RECOVER_TIME = 60 #主库守护进程启动恢复的间隔时间
INST_ERROR_TIME = 10  #本地实例故障认定时间
INST_OGUID = 45330 #守护系统唯一 OGUID 值
INST_INI = /data/dmdata/data/BACKUPMPP01/dm.ini #dm.ini 配置文件路径
INST_AUTO_RESTART = 1 #打开实例的自动启动功能
INST_STARTUP_CMD = /home/dmdba/dmdbms/bin/dmserver #命令行方式启动
RLOG_SEND_THRESHOLD = 0 #指定主库发送日志到备库的时间阀值，默认关闭
RLOG_APPLY_THRESHOLD = 0 #指定备库重演日志的时间阀值，默认关闭
[GRP2]
DW_TYPE = GLOBAL #全局守护类型
DW_MODE = AUTO #自动切换模式
DW_ERROR_TIME = 10  #远程守护进程故障认定时间
INST_RECOVER_TIME = 60 #主库守护进程启动恢复的间隔时间
INST_ERROR_TIME = 10  #本地实例故障认定时间
INST_OGUID = 45331 #守护系统唯一 OGUID 值
INST_INI = /data/dmdata/data/MPP02/dm.ini #dm.ini 配置文件路径
INST_AUTO_RESTART = 1 #打开实例的自动启动功能
INST_STARTUP_CMD = /home/dmdba/dmdbms/bin/dmserver #命令行方式启动
RLOG_SEND_THRESHOLD = 0 #指定主库发送日志到备库的时间阀值，默认关闭
RLOG_APPLY_THRESHOLD = 0 #指定备库重演日志的时间阀值，默认关闭
```


第三台机器搭建监控器

```
/data/dmdata/data/dmmonitor.ini
```

#配置单实例监控器
#修改 dmmonitor.ini 配置确认监视器，其中 MON_DW_IP 中的 IP 和 PORT 和dmmal.ini 中的 MAL_HOST 和 MAL_DW_PORT 配置项保持一致。

```
MON_DW_CONFIRM = 1 #确认监视器模式
MON_LOG_PATH =/data/dmdata/data/log#监视器日志文件存放路径
MON_LOG_INTERVAL  = 60  #每隔 60s 定时记录系统信息到日志文件
MON_LOG_FILE_SIZE = 32  #每个日志文件最大 32M
MON_LOG_SPACE_LIMIT = 0 #不限定日志文件总占用空间
[GRP1]
MON_INST_OGUID = 45330 #组 GRP1 的唯一 OGUID 值
#以下配置为监视器到组 GRP1 的守护进程的连接信息，以―IP:PORT‖的形式配置
#IP 对应 dmmal.ini 中的 MAL_HOST，PORT 对应 dmmal.ini 中的 MAL_DW_PORT
MON_DW_IP = 192.168.66.11:5254
MON_DW_IP = 192.168.66.10:5253
[GRP2]
MON_INST_OGUID = 45331 #组 GRP2 的唯一 OGUID 值
#以下配置为监视器到组 GRP2 的守护进程的连接信息，以―IP:PORT‖的形式配置
#IP 对应 dmmal.ini 中的 MAL_HOST，PORT 对应 dmmal.ini 中的 MAL_DW_PORT
MON_DW_IP = 192.168.66.10:5254
MON_DW_IP = 192.168.66.11:5253
```


启动MPP01和MPP02机器上的守护进程

```
./dmwatcher /data/dmdata/data/MPP01/dmwatcher.ini
./dmwatcher /data/dmdata/data/MPP02/dmwatcher.ini 
```


启动监控器

```
./dmmonitor /data/dmdata/data/dmmonitor.ini
```


验证是否安装成功



全部变为open即为正常启动

问题记录
第二台机器启动守护集群时候：报错oguid(45330) configured in dmwatcher.ini not equal with local dmserver’s oguid(45331), cannot build connection!
以local登录disql后

```
SELECT OGUID FROM V$INSTANCE;
```

查看OGUID是否有问题

