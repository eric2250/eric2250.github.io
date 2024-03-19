--直接创建:
create table dave(id int);
insert into dave values(1);
insert into dave values(1);
commit;
--查询创建:
create table dm1 as select * from sysobjects;

--查询
SELECT * FROM DAVE;
SELECT * FROM DM1;


--重命名表:
create table dm1 as select * from sysobjects;
alter table dm1 rename to dm2;
select count(1) from dm2;
--添加列:
alter table dm2 add column(age int);
SQL> desc dm2;
--删除列:
alter table dm2 drop column age;
--修改列类型和长度:
alter table dm2 modify "VALID" VARCHAR(50);
--添加主键:
alter table dm2 add primary key("ID");