## 安装

```
yum install samba
mkdir samba
chmod 777 samba/
```

## 配置

```
[global]
        workgroup = SAMBA
        security = user

        passdb backend = tdbsam
        map to guest = Bad User
        directory mask = 0775

[war]
     comment = This is a directory of wars.
     path = /samba
     public = no
     admin users = sw
     valid users = @sw
     writable = yes
     create mask = 1444
     directory mask = 1777
     browseable = yes
      guest ok = yes
```

## 添加用户

```
smbpasswd -a root  # 用root**用户作为例子**
```

## 启动服务

```
systemctl start smb nmb
systemctl enable smb nmb  # 设置开机自启
```

