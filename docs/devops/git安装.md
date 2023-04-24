# git 安装
```
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.37.2.tar.gz --no-check-certificate
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker
tar zxvf git-2.37.2.tar.gz
cd git-2.37.2
make prefix=/usr/local/git all
make prefix=/usr/local/git install
vim /etc/profile
export PATH=/usr/local/git/bin:$PATH
source /etc/profile
git --version
git version 2.37.2
```