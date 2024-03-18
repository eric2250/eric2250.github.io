SELECT * FROM SYS.DBA_DATA_FILES;

SELECT * FROM SYS.DBA_TABLESPACES;

SELECT T1.TABLESPACE_NAME,T1.BLOCK_SIZE,T2.FILE_NAME FROM SYS.DBA_TABLESPACES T1,SYS.DBA_DATA_FILES T2 WHERE T1.TABLESPACE_NAME = T2.TABLESPACE_NAME;

/*
数据查询
*/
SELECT * FROM DMHR.CITY;
select city_name,city_id from dmhr.city WHERE CITY_ID = CITY_ID;
select city_name cn,city_id from dmhr.city;
select employee_name,salary as tol from dmhr.employee limit 10;
select employee_name||'的工资是:'||salary as desc1 from dmhr.employee limit 10;
select distinct department_id from dmhr.employee;