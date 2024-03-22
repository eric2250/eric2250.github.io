--前台启动
--[dmdba@ha1 DAMENG]$  /apps/dmdba/dmdbms/bin/dmserver /apps/dmdba/dmdbms/data/DAMENG/dm.ini
--登录修改
--[dmdba@ha1 DAMENG]$ disql 

SP_SET_PARA_VALUE(1, 'ALTER_MODE_STATUS', 1); 

alter database open force;

SELECT MODE$,STATUS$ from v$instance;

SELECT MODE$,STATUS$,OGUID from v$instance;