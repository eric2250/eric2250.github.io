--视图是从用户的实际需要中抽取出来的虚表。
CREATE VIEW PURCHASING.VENDOR_EXCELLENT AS
SELECT*FROM
PURCHASING.VENDOR
WHERE
CREDIT =1;
--查看视图定义:
select view_name,text from dba_views where view_name='VENDOR_EXCELLENT';
--编译视图:
alter view purchasing.vendor_excellent compile;
--删除视图:
drop view "PURCHASING"."VENDOR_EXCELLENT" restrict;