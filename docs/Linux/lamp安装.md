官网下载：

https://www.php.net/downloads.php

https://httpd.apache.org/download.cgi

# 1. apache安装

```Bash
tar zxvf httpd-2.4.56.tar.gz
cd httpd-2.4.56
./configure -prefix=/usr/local/apache2 -enable-module=so
make
make install
#启动
/usr/local/apache2/bin/apachectl start
/usr/local/apache2/bin/apachectl restart

#vim httpd.conf 修改以下两处，端口自定义
52 Listen 8088
198 ServerName 172.100.2.201:8088
```

打开浏览器,在地址栏输入“[http://localhost](http://localhost/)”出现“It works!”或apache图标的漂亮界面，说明apache安装成功！

# 2. php安装

## 2.1 准备

```Bash
#查找apxs，手动安装apache指定以下：/usr/local/apache2/bin/apxs
rpm -ql httpd-devel  |grep  apxs
find / -name "apxs"
#如果没有apxs，安装httpd-devel：
yum install httpd-devel
#安装依赖
yum install zlib libxml libjpeg freetype libpng gd curl libiconv zlib-devel libxml2 libxml2-devel libjpeg-devel freetype-devel libpng-devel gd-devel curl-devel openssl-devel libxslt-devel -y
```

## 2.2 编译安装

本次使用

```Bash
tar zxvf php-7.4.33.tar.gz
cd php-7.4.33
./configure prefix=/usr/local/php \
--with-apxs2=/usr/local/apache2/bin/apxs \
--with-xmlrpc \
--with-openssl \
--with-zlib \
--with-iconv \
--enable-short-tags \
--enable-sockets \
--enable-soap \
--enable-mbstring \
--enable-static \
--with-curl \
--with-xsl \
--with-ldap \
--enable-ftp

make 
make install
```

其他参数

```Bash
tar zxvf php-7.4.33.tar.gz
cd php-7.4.33
./configure prefix=/usr/local/php \
--with-apxs2=/usr/local/apache2/bin/apxs \
--with-mysql=/usr/share/mysql \
--with-xmlrpc \
--with-openssl \
--with-zlib \
--with-freetype-dir \
--with-gd \
--with-jpeg-dir \
--with-png-dir \
--with-iconv \
--enable-short-tags \
--enable-sockets \
--enable-zend-multibyte \
--enable-soap \
--enable-mbstring \
--enable-static \
--enable-gd-native-tty \
--with-curl \
--with-xsl \
--enable-ftp \
--with-ldap \
--with-libxml-dir

make 
make install
--prefix=/usr/local/php-8           #指定PHP程序安装目录
 --with-apxs2=/usr/bin/apxs         #调用apache2
 --with-mysql=/usr/share/mysql      #调用MySQL
 --with-xmlrpc                      #打开XML-RPC的C语言
 --with-openssl                     #打开zlib库的支持
 --with-zlib                        #打开openssl支持
 --with-freetype-dir                #打开对Freetype字体库的支持
 --with-gd                          #打开对GD库的支持
 --with-jpeg-dir                    #打开对JPEG图片的支持
 --with-png-dir                     #打开对PNG文件的支持
 --with-iconv                       #开启icovn函数，完成各种字符集之间的转换
 --enable-short-tags                #开启开始和标记函数
 --enable-sockets                   #开启Sockets支持
 --enable-zend-multibyte            #开启zend多字节支持
 --enable-soap                      #开启soap模块
 --enable-mbstring                  #开启mbstring库的支持
 --enable-static                    #生成静态链接库
 --enable-gd-native-tty             #支持Truetype字符串函数库
 --with-curl                        #打开curl浏览工具的支持
 --with-xsl                         #打开xslt文件支持
 --enable-ftp                       #开启FTP支持
 --with-libxml-dir                  #打开libxm12库的支持
 --with-ldap                        #开启ldap支持
```

# 3. 处理报错

### 报错1：No package 'sqlite3' found

```Bash
checking for sqlite3 > 3.7.4... no
configure: error: Package requirements (sqlite3 > 3.7.4) were not met:

No package 'sqlite3' found

Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix.

Alternatively, you may set the environment variables SQLITE_CFLAGS
and SQLITE_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.
```

解决

```Bash
 yum -y install sqlite-devel
```

### 报错2：No package 'oniguruma' found

```Bash
configure: error: Package requirements (oniguruma) were not met:

No package 'oniguruma' found
```

解决

```Bash
yum install oniguruma-devel -y
```

### 报错3：configure: error: Cannot find ldap libraries in /usr/lib.

```Bash
configure: error: Cannot find ldap libraries in /usr/lib.
```

解决

```Bash
cp -frp /usr/lib64/libldap* /usr/lib/
```

### 报错4：make: *** [sapi/cli/php] Error 1

```Bash
/usr/bin/ld: ext/ldap/.libs/ldap.o: undefined reference to symbol 'ber_strdup' 
//usr/lib64/liblber-2.4.so.2: error adding symbols: DSO missing from command line 
collect2: error: ld returned 1 exit status 
make: *** [sapi/cli/php] Error 1
```

解决： 解决办法：遇到这种类似的情况，说明「./configure 」沒抓好一些环境变数值。解决方法，来自老外的一篇文章： 在PHP源码目录下 vi Makefile 找到 EXTRA_LIBS 行，在行末添加 ‘ -llber ‘ 保存退出再次make即可

```Bash
#vim Makefile
97 EXTRA_LIBS = -lcrypt -lresolv -lcrypt -lrt -lldap -lrt -lm -ldl -lpthread -lxml2 -lssl -lcrypto -lsqlite3 -lz -lcurl -lxml2 -lssl -lcrypto -lonig -lsqlite3 -lxml2 -lxml2 -lcrypt -lxml2 -lxml2 -lxml2 -lxml2 -lxslt -lz -ldl -lm -lx     ml2 -lexslt -lxslt -lz -lm -lgcrypt -ldl -lgpg-error -lxml2 -lcrypt -llber
```

# 4. mysql安装

[Mysql安装](/Linux/Mysql安装.md)

# 5. 配置apache支持php

```Bash
#vim httpd.conf
#修改
255 <IfModule dir_module>
256     DirectoryIndex index.php index.html
257 </IfModule>

#添加

395     AddType application/x-httpd-php .php .phtml 
396     AddType application/x-httpd-php-source .phps
#~~~
```

检查重启httpd

```Bash
# /usr/local/apache2/bin/apachectl -t
Syntax OK
# /usr/local/apache2/bin/apachectl restart
```

测试

```Bash
#vi /usr/local/apache2/htdocs/index.php
<?php
phpinfo();
?>
# /usr/local/apache2/bin/apachectl restart
```

# 6. 配置pdo_mysql扩展

```Bash
1、进入 PHP 的软件包 pdo 扩展目录中(注：不是 PHP 安装目录)

# cd /apps/soft/php-7.4.33/ext/pdo_mysql

注：我的 php 软件包在 /apps/soft/php-7.4.33下

执行 phpize 命令

# /usr/local/php/bin/phpize

注：/usr/local/php 是我的 php 安装目录
执行完 phpize 命令后，在 pdo_mysql 目录中就会出现 configure
#报错处理
#Cannot find autoconf. Please check your autoconf installation and the
#$PHP_AUTOCONF environment variable. Then, rerun this script.
# yum -y install autoconf 

编译安装
# ./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/apps/mysql-8.0.31/

参数说明：

--with-php-config=/usr/local/php/bin/php-config 指定安装 PHP 的时候的配置

--with-pdo-mysql=/usr/local/mysql/ 指定 MySQL 数据库的安装目录位置

# make && make install
Installing shared extensions:     /usr/local/php/lib/php/extensions/no-debug-zts-20190902/


编辑配置文件加入下面一行
cp /apps/soft/php-7.4.33/php.ini-production /usr/local/php/lib/php.ini
vim /usr/local/php/lib/php.ini
extension=/usr/local/php/lib/php/extensions/no-debug-zts-20190902/pdo_mysql.so
```
