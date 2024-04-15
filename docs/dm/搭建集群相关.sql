--备份还原后检查file_lsn和cur_lsn与魔数是否一致
select file_LSN, cur_LSN from v$rlog;
select permanent_magic;
