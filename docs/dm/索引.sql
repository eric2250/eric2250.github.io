--达梦支持的索引:二级索引，位图索引，唯一索引，复合索引，函数索引，分区索引等。
--默认的表是索引组织表，利用rowid创建一个默认的索引，所以我们创建的索引，称为二级索引。
--查看索引:
select TABLE_NAME,INDEX_NAME from  SYS.DBA_INDEXES where TABLE_NAME='';
--创建索引:
create table emp as select * from dmhr.employee;
create tablespace index1 datafile '/apps/dmdata/data/DMDB1/index1.dbf' size 128;
create index ind_emp on emp(employee_id) tablespace index1;
select table_name,index_name from SYS.DBA_INDEXES where table_name='EMP';
--重建:
alter index IND_EMP rebuild;
--删除:
drop index ind_emp;