--在DM数据库中用户管理主要涉及到三块:用户、权限、角色。
--用户是用来连接数据库并进行相关操作的。
--模式是一个用户拥有的所有数据库对象的集合，每个用户都有自己默认的模式，用户默认的模式名和用户名相同,权限是指执行特定类型SQL命令或访问其他模式对象的权利，它用于限制用户可执行的操作。
--角色是将具有相同权限的用户组织在一起，这一组具有相同权限的用户称为角色。

--查看所有角色:
select * from SYS.DBA_ROLES;
--查看所有用户的信息:
select USERNAME,PASSWORD,USER_ID,DEFAULT_TABLESPACE,PROFILE,ACCOUNT_STATUS  from SYS.DBA_USERS;
--查看系统中所有用户对应的角色:
select * from SYS.DBA_ROLE_PRIVS;
--创建用户:
create user eric identified by "eric123123" limit CONNECT_TIME 3;
--对用户授权:
grant PUBLIC,dba,resource to eric;


--验证
--登陆dave用户
conn eric/"eric123123";

--查看当前用户:
select username from USER_USERS;
select user();
create table eric as select * from sysobjects;
select count(1) from eric;