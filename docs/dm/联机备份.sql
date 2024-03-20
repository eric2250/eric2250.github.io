--联机备份在数据库级别只支持备份操作，不支持还原，数据库级别的还原必须在脱机进行。
--默认的备份路径为 dm.in 中 BAK PATH 参数配置的路径，若未配置，则使用 SYSTEM_PATH 下的 bak目录,
--1.数据库备份
--全备:full 参数可以省略，不指定备份类型默认为完全备份
backup database backupset '/apps/dmdba/dmdbms/dmbak/full01';
--增量备份
backup database increment with backupdir '/apps/dmdba/dmdbms/dmbak' backupset '/apps/dmdba/dmdbms/dmbak/inc_back';

--2.表空间备份与还原
--备份表空间:
BACKUP TABLESPACE MAIN BACKUPSET '/apps/dmdba/dmdbms/dmbak/ts_full_bak_01';
--校验表空间备份(可选):
SELECT SF_BAKSET_CHECK('DISK','/apps/dmdba/dmdbms/dmbak/ts_full_bak_01');
--修改表空间为脱机。
ALTER TABLESPACE MAIN OFFLINE;
--还原表空间:
RESTORE TABLESPACE MAIN FROM BACKUPSET '/apps/dmdba/dmdbms/dmbak/ts_full_bak_01';
--修改表空间为联机:
ALTER TABLESPACE MAIN ONLINE;

--3.表备份与还原
--执行表还原，数据库必须处于 OPEN 状态，MOUNT和 SUSPEND 状态下不允许执行表还原
--创建测试表:
create table tbak as select * from sysobjects;
--备份表:
backup table tbak backupset '/apps/dmdba/dmdbms/tbak';
select count(1) from tbak;
--清空表，不是删除
DELETE FROM tbak;
--还原表:
restore table tbak from backupset '/apps/dmdba/dmdbms/tbak';

select count(1) from tbak;
--这里还原时表必须存在，不支持drop 的恢复


--如果表上有索引和约束，需要先还原表结构，示例如下，
--创建待备份的表:
create table dmbak2 as select * from sysobjects;
--创建索引:
create index idx_dmbak2_id on dmbak2(id);
--备份表:
backup table dmbak2 backupset '/apps/dmdba/dmdbms/dmbak2';
--因为表上有索引，直接还原数据会报错:
restore table dmbak2 from backupset '/apps/dmdba/dmdbms/dmbak2';
--[-8327]:还原表中存在二级索引或几余约束.已用时间: 7.418(毫秒).执行号:0.

--执行表结构还原:
restore table dmbak2 struct from backupset '/apps/dmdba/dmdbms/dmbak2';
--执行表数据还原。
restore table dmbak2 from backupset '/apps/dmdba/dmdbms/dmbak2';


