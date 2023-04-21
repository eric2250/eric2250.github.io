# 官方文档：

https://docs.gitlab.cn/jh/raketasks/backup_restore.html#%E5%A4%87%E4%BB%BD%E5%92%8C%E6%81%A2%E5%A4%8D%E6%9E%81%E7%8B%90gitlab
```
gitlab-backup create    最多同时有三份数据：本身、小包、大包
gitlab-backup create STRATEGY=copy  最多同时有三份数据：本身、副本、小包  ---->  本身、小包、大包
gitlab-backup create SKIP=tar   最多同时有两份数据：本身、小包
gitlab-backup create STRATEGY=copy SKIP=tar     最多同时有三份数据：本身、副本、小包
```
# 1.备份
```
 docker exec -t 32a960114995 gitlab-backup create
```
查看备份文件默认备份目录/var/opt/gitlab/backups：
```
cd /var/opt/gitlab/backups
root@gitlab:/var/opt/gitlab/backups# ls
1679556133_2023_03_23_15.9.2-jh_gitlab_backup.tar
```
此命令备份不会备份配置文件，我们需要手动备份：

官方提示：

您必须至少备份：

对于 Omnibus：
```
/etc/gitlab/gitlab-secrets.json

/etc/gitlab/gitlab.rb
```
对于源代码安装：
```
/home/git/gitlab/config/secrets.yml

/home/git/gitlab/config/gitlab.yml
```
我们直接备份/config 目录吧 也不大
```
tar zcvf `date +%Y%m%d%H%M%S`-config_backup.tar /etc/gitlab/*
```
配置一些常用备份参数

编辑 /etc/gitlab/gitlab.rb：

##配置备份复制到指定本地位置一份
```
gitlab_rails['backup_upload_connection'] = {
  :provider => 'Local',
  :local_root => '/mnt/backups'
}

# The directory inside the mounted folder to copy backups to
# Use '.' to store them in the root directory
gitlab_rails['backup_upload_remote_directory'] = 'gitlab_backups'
#====================
##设置备份保留日期
## Limit backup lifetime to 7 days - 604800 seconds
gitlab_rails['backup_keep_time'] = 604800
##备份归档权限
gitlab_rails['backup_archive_permissions'] = 0644 # Makes the backup archives world-readable
```
建本地目录，设置权限
```
mkdir -p /mnt/backups/
chmod 777 /mnt/backups/
```
设置计划任务执行备份

为 root 用户编辑 Crontab：
```
sudo su -
crontab -e
```
添加以下内容，每天上午 2 点调度备份：
```
0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1
```
# 2.还原
停止服务
```
gitlab-ctl stop puma
gitlab-ctl stop sidekiq
# Verify
gitlab-ctl status
```
还原文件
```
# This command will overwrite the contents of your GitLab database!
cd /var/opt/gitlab/backups
chown git:git 1679559553_2023_03_23_15.9.2-jh_gitlab_backup.tar
gitlab-backup restore BACKUP=1679559553_2023_03_23_15.9.2-jh

gitlab-ctl reconfigure
gitlab-ctl restart
gitlab-rake gitlab:check SANITIZE=true
```