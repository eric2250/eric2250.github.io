前台启动
[dmdba@ha1 DAMENG]$  /apps/dmdba/dmdbms/bin/dmserver /apps/dmdba/dmdbms/data/DAMENG/dm.ini
登录修改
[dmdba@ha1 DAMENG]$ disql 
disql V8
用户名:
密码:

服务器[LOCALHOST:5236]:处于主库配置状态
登录使用时间 : 3.046(ms)
SQL> SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 1); 
DMSQL 过程已成功完成
已用时间: 6.597(毫秒). 执行号:1.
SQL> alter database open force;
操作已执行
已用时间: 19.314(毫秒). 执行号:0.
SQL> SELECT MODE$,STATUS$ from v$instance;

行号     MODE$   STATUS$
---------- ------- -------
1          STANDBY OPEN

已用时间: 0.336(毫秒). 执行号:3.
SQL> 