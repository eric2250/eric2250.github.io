
/*--停止数据库实例
]$ DmServiceDM
DmServiceDMDB1   DmServiceDMDB2   DmServiceDMTEST  
[dmdba@ha2 dmbak]$ DmServiceDMDB1 stop
Stopping DmServiceDMDB1:                                   [ OK ]


进入dmrman
 ]$cd /apps/dmdba/dmdbms/bin
bin]$ ./dmrman 
dmrman V8
RMAN> 

*/


--1.创建数据库完全备份
RMAN> backup database '/apps/dmdata/data/DMDB1/dm.ini'  full backupset '/apps/dmdba/dmdbms/dmbak/db_full_bak_01'
--注意:执行脱机备份要求数据库必须处于脱机状态。


--2.创建数据库增量备份:
RMAN> backup database '/apps/dmdata/data/DMDB1/dm.ini' increment with backupdir '/apps/dmdba/dmdbms/dmbak/' backupset'/apps/dmdba/dmdbms/dmbak/db_increment_bak_02'
--注意:脱机增量备份要求两次备份之间数据库必须有操作，否则备份会报错。


--数据库恢复有三种方式:更新 DB MAGIC 恢复、从备份集恢复和从归档恢复。
--1.更新 DB MAGIC 恢复(脱机备份恢复)可以直接更新 DB MAGIC完成数据库恢复在不需要重做归档日志恢复数据的情况下，
--备份数据库:
RMAN>backup database '/apps/dmdata/data/DMDB1/dm.ini' backupset '/apps/dmdba/dmdbms/dmbak/db_full_bak_01';
--还原数据库:
RMAN>restore database '/apps/dmdata/data/DMDB1/dm.ini' from backupset '/apps/dmdba/dmdbms/dmbak/db_full_bak_01';
--恢复数据库:
RMAN>recover database '/apps/dmdata/data/DMDB1/dm.ini' update db_magic;

--2.从备份集恢复(联机备份恢复)
--如果备份集在备份过程中生成了日志，目这些日志在备份集中有完整备份(如联机数据库备份)，在执行数据库还原后，可以重做备份集中备份的日志，将数据库恢复到备份时的状态，即从备份集恢复。说明:如果数据库要恢复到最新时间点，需要从归档恢复(从归档恢复步骤这里不做说明)
--联机备份数据库:
SQL>backup database backupset '/apps/dmdba/dmdbms/dmbak/db_full_bak_01';
--还原数据库:
RMAN>restore database '/apps/dmdata/data/DMDB1/dm.ini' from backupset '/apps/dmdba/dmdbms/dmbak/db_full_bak_01';
--恢复数据库(从备份集恢复):
RMAN>recover database '/apps/dmdata/data/DMDB1/dm.ini' from backupset '/apps/dmdba/dmdbms/dmbak/db_full_bak_01'.
--更新db magic:
RMAN>recover database '/apps/dmdata/data/DMDB1/dm.ini' update db_magic



