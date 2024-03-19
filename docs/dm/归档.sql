--启用归档模式
alter database mount;

alter database archivelog;

alter database add archivelog 'DEST=/apps/dmdba/dmdbms/dmarch, TYPE=LOCAL, FILE_SIZE=64, SPACE_LIMIT=0, ARCH_FLUSH_BUF_SIZE=0';


alter database open;

--查看状态
select arch_mode from v$database;

select arch_name,arch_type,arch_dest,arch_file_size from v$dm_arch_ini;


alter system switch logfile;
/*
 cat /apps/dmdata/data/DMDB1/dmarch.ini 
#DaMeng Database Archive Configuration file
#this is comments

	ARCH_WAIT_APPLY      = 0        

[ARCHIVE_LOCAL1]
	ARCH_TYPE            = LOCAL        
	ARCH_DEST            = /apps/dmdba/dmdbms/dmarch        
	ARCH_FILE_SIZE       = 64        
	ARCH_SPACE_LIMIT     = 0        
	ARCH_FLUSH_BUF_SIZE  = 0        
	ARCH_HANG_FLAG       = 1 
	
	*/