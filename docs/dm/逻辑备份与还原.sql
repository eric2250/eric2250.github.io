--逻辑导出(dexp)和逻辑导入(dimp)支持如下四种级别操作:
----数据库级(FULL):导出或导入整个数据库中的所有对象。
----用户级(OWNER):导出或导入一个或多个用户所拥有的所有对象。
----模式级(SCHEMAS):导出或导入一个或多个式下的所有对象。
----表级(TABLE):导出或导入一个或多个指定的表或表分区，
--创建测试数据
--创建用户:
create user dexp identified by dameng123;
grant resource,dba to dexp;
--连接测试用户并创建测试表:
--conn dexp/dameng123;
create table dexp as select * from sysobjects;
--导出导入过程数据库要保持OPEN状态
select count(1) from dexp;
--1.全量导出导入
-- 全库导出
--]$dexp SYSDBA/SYSDBA file=full_01.dmp log=full1.log directory=/apps/dmdba/dmdbms/dmbak full=y
--删除测试数据:
drop table dexp ;
select count(1) from dexp;
--全库导入
--]$ dimp USERID=SYSDBA/SYSDBA file=full_01.dmp LOG=full2.log directory=/apps/dmdba/dmdbms/dmbak full=y table_exists_action=replace
--验证之前创建的测试表
select count(1) from dexp;
--2.按用户导出导入
--导出用户
--]$ dexp SYSDBA/SYSDBA file=user_01.dmp log=user_out.log directory=/apps/dmdba/dmdbms/dmbak owner=dexp
--删除测试数据:
drop table dexp ;
select count(1) from dexp;
--导入数据
	--导入数据到原用户:
--]$ dimp USERID=SYSDBA/SYSDBA FILE=user_01.dmp LOG=user_in.log directory=/apps/dmdba/dmdbms/dmbak owner=dexp table_exists_action=replace
--验证之前创建的测试表
select count(1) from dexp;
	--导入数据到其他用户:
create user dimp identified by dameng123;
grant resource,dba to dimp;
--验证导入前数据
--SQL>conn dimp/dameng123
select count(1) from dexp;
--注意这里的remap schema中的模式名要用大写，否则会导入原来的模式中:
--]$ dimp USERID=SYSDBA/SYSDBA FILE=user_01.dmp LOG=user_in_.log directory=/apps/dmdba/dmdbms/dmbak remap_schema=DEXP:DIMP table_exists_action=replace
--验证导入后数据
--SQL>conn dimp/dameng123
select count(1) from dexp;


--3.按模式导出导入
--导出模式
--]$ dexp SYSDBA/SYSDBA file=schema_01.dmp log=schema_out.log directory=/apps/dmdba/dmdbms/dmbak schemas=dexp

--删除测试数据:
--SQL>conn dimp/dameng123
drop table dexp ;
select count(1) from dexp;
--导入模式
--注意这里的remap_schema中的模式名要用大写，否则会导入原来的模式中:
--l$ dimp USERID=dimp/dameng123 file=schema_01.dmp LOG=schema_in.log directory=/apps/dmdba/dmdbms/dmbak remap_schema=DEXP:DIMP table_exists_action=replace
--验证模式
select user();
select count(1) from dexp;


--4.按表导出导入
--导出表
--在原库dexp用户下创建2张测试表
--SQL>conn dexp/dameng123
create table anqing as select * from sysobjects;
create table huaining as select * from sysobjects;
--#导出这2张表:
--]$ dexp dexp/dameng123 file=tables_01.dmp log=tables_out.log directory=/apps/dmdba/dmdbms/dmbak tables=anqing,huaining
drop TABLE anqing;
drop TABLE huaining;
select count(1) from anqing;
select count(1)from huaining;
--导入表
--将表导入到原用户dexp用户下:
--]$ dimp dexp/dameng123 file=tables_01.dmp log=tables_in.log directory=/apps/dmdba/dmdbms/dmbak tables=anqing,huaining table_exists_action=replace
--将表导入到dimp用户下:
--注意这里连接用户必须是对象的原用户，然后加上remap_schema=DEXP:DIMP 就可以导入到新用户下:
--]$ dimp dexp/dameng123 file=tables_01.dmp log=tables_in_dimp.log directory=/apps/dmdba/dmdbms/dmbak tables=anqing,huaining table_exists_action=replace remap_schema=DEXP:DIMP
--验证表
--SQL>conn dimp/dameng123
select user();
select count(1) from anqing;
select count(1)from huaining;




