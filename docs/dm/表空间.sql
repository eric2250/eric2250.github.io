--查询表空间
SELECT TABLESPACE_NAME FROM SYS.DBA_TABLESPACES;

--查询表空间文件
SELECT TABLESPACE_NAME,FILE_NAME,STATUS FROM SYS.DBA_DATA_FILES ORDER BY 1;

--创建表空间及文件
CREATE TABLESPACE eric DATAFILE '/apps/dmdata/data/DMDB1/ERIC.DBF' SIZE 128;

create tablespace "ERIC8" datafile '/apps/dmdata/data/DMDB1/ERIC8.DBF' size 256 autoextend on next 10 maxsize 1024000 CACHE = NORMAL;

--扩展表空间
--表空间的扩展有两种方式:1)扩展现有数据文件大小2)增加新的数据文件
ALTER TABLESPACE eric ADD DATAFILE '/apps/dmdata/data/DMDB1/ERIC3.DBF' SIZE 256;
SELECT TABLESPACE_NAME,FILE_ID,bytes/1024/1023 as "size" ,FILE_NAME from SYS.DBA_DATA_FILES where TABLESPACE_NAME='ERIC';

ALTER TABLESPACE  eric resize DATAFILE '/apps/dmdata/data/DMDB1/ERIC.DBF' to 256;
SELECT TABLESPACE_NAME,FILE_ID,bytes/1024/1023 as "size" ,FILE_NAME from SYS.DBA_DATA_FILES where TABLESPACE_NAME='ERIC';

--扩展表空间属性更改
alter tablespace "ERIC" datafile 'ERIC3.DBF' autoextend on next 10 maxsize 102400;

--更改表空间名称

ALTER TABLESPACE ERIC1 RENAME TO ERIC3;
SELECT TABLESPACE_NAME,FILE_ID,bytes/1024/1023 as "size" ,FILE_NAME from SYS.DBA_DATA_FILES where TABLESPACE_NAME='ERIC3';



--在表空间脱机状态下，可以修改数据文件的位置。
alter tablespace eric offline;
alter tablespace eric rename datafile '/apps/dmdata/data/DMDB1/ERIC3.DBF' TO '/apps/dmdata/data/DMDB1/ERIC4.DBF';
alter tablespace eric online;
SELECT TABLESPACE_NAME,FILE_ID,bytes/1024/1023 as "size" ,FILE_NAME from SYS.DBA_DATA_FILES where TABLESPACE_NAME='ERIC';
--注意:这里的移动是操作系统物理的上移动。


--只可以删除用户创建的表空间并且只能删除未使用过的表空间。
--删除表空间时会删除其拥有的所有数据文件。
drop tablespace ERIC8;
SELECT TABLESPACE_NAME,FILE_ID,bytes/1024/1023 as "size" ,FILE_NAME from SYS.DBA_DATA_FILES where TABLESPACE_NAME='ERIC8';








