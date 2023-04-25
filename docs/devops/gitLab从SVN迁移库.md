## 准备：安装ruby环境

```Bash
 sudo yum install ruby
```

## 安装 `svn2git`

在本地工作站而不是极狐GitLab 服务器上安装 `svn2git`：

- 在所有系统上，如果您已经安装了 Ruby 和 Git，则可以将其安装为 Ruby gem：

```Plaintext
sudo gem install svn2git
```

- 在基于 Debian 的 Linux 发行版上，您可以安装本机软件包：

```Plaintext
sudo apt-get install git-core git-svn ruby
```

## 准备作者文件（推荐）

准备一个作者文件，以便 `svn2git` 可以将 SVN 作者映射到 Git 作者。如果您选择不创建作者文件，则提交不会归因于正确的极狐GitLab 用户。

要映射作者，您必须将存在的每个作者映射到 SVN 仓库中的更改。如果不这样做，迁移将失败，您必须相应地更新作者文件。

1. 搜索 SVN 仓库，输出作者列表：

```Bash
#!/bin/bash
svn_url=$1
svn log -q $svn_url | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u > authors.txt
```

1. 使用上一条命令的输出构建作者文件。创建一个名为 `authors.txt` 的文件并每行添加一个映射。例如：

```Bash
wangyuan = wangyuan <wangyuan>
yangkeke = yangkeke <yangkeke>
zhaoshuo = zhaoshuo <zhaoshuo>
```

# 使用命令迁移

## 使用git svn clone 克隆svn库为git库

```Bash
#!/bin/bash
svn_url=$1
git svn clone  --authors-file authors.txt $svn_url
```

## 上传至git库

在git服务端新建git库，复制地址

```Bash
cd eportgnssweb
git remote add origin http://gitlab.east-port.cn/eastport/eportgnssweb.git
git push -u origin master
```

整理成脚本

```Bash
#!/bin/bash
svn_url=$1
pjname=` echo "$svn_url" |awk -F "/" '{print$NF}'`
echo $pjname
svn log -q $svn_url | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u > authors.txt

git svn clone  --authors-file authors.txt $svn_url

#git update-ref refs/heads/master refs/remotes/git-svn
cd $pjname
git remote add origin http://gitlab.east-port.cn/eastport/$pjname.git
git push -u origin master
```

# 用`svn2git`将 SVN 仓库迁移到 Git 仓库

`svn2git` 支持排除某些文件路径、分支、标签等。有关所有可用选项的完整文档，请参阅 `svn2git 文档`或运行 `svn2git --help`。

对于要迁移的每个仓库：

1. 创建一个新目录并进入它。
2. 对于以下仓库：
   1. 不需要用户名和密码，运行：
   2. ```Plaintext
      svn2git svn://172.100.2.201/pmsweb --authors ../authors.txt
      ```

   3. 确实需要用户名和密码，运行：
   4. ```Plaintext
      svn2git svn://172.100.2.201/pmsweb --authors ../authors.txt --username eric --password gwqgwq
      ```
3. 为您迁移的代码创建一个新的极狐GitLab 项目。
4. 从极狐GitLab 项目页面复制 SSH 或 HTTP(S) 仓库 URL。
5. 将极狐GitLab 仓库添加为 Git 远端并推送所有更改，会推送所有提交、分支和标签。

```Plaintext
git remote add origin git@gitlab.example.com:<group>/<project>.git
git push --all origin
git push --tags origin
```



# 迁移过程报错处理

## 执行svn命令报错: svn: E220001: Item is not readable

这个是服务端仓库配置问题，根据我们是否需要允许匿名访问，分为两种情况解决。

允许匿名访问（只读）

（1） **svnserve.conf** 文件中   **anon-access** 设为   **read**。

![img](..\images\gitlab001.png)

（2） **authz**  文件中在  **[/]** 下添加  * = r

![img](..\images\gitlab002.png)

**禁止匿名访问（读写都需要用户名、密码）**

（1） **svnserve.conf** 文件中   **anon-access**  设为   **none**。

![img](..\images\gitlab003.png)

（2） **authz**  文件中在   **[/]** 下只需要配置相关的用户，不要添加   *** = r** 了。

![img](..\images\gitlab004.png)

## svn2git 报错：

### 报错1：执行git svn 命令报错

```Bash
[root@ep-jenkins git]# svn2git svn://172.100.2.201/pmsweb --authors ../authors.txt --username eric --password gwqgwq
Can't locate SVN/Core.pm in @INC (@INC contains: /usr/local/git/share/perl5 /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at /usr/local/git/share/perl5/Git/SVN/Utils.pm line 6.
BEGIN failed--compilation aborted at /usr/local/git/share/perl5/Git/SVN/Utils.pm line 6.
Compilation failed in require at /usr/local/git/share/perl5/Git/SVN.pm line 32.
BEGIN failed--compilation aborted at /usr/local/git/share/perl5/Git/SVN.pm line 32.
Compilation failed in require at /usr/local/git/libexec/git-core/git-svn line 23.
BEGIN failed--compilation aborted at /usr/local/git/libexec/git-core/git-svn line 23.
command failed:
git svn init --prefix=svn/ --username='eric' --password='gwqgwq' --no-metadata --trunk='trunk' --tags='tags' --branches='branches' svn://172.100.2.201/pmsweb
```

perl版本过低，安装更高版本perl：https://www.cpan.org/src/

```Bash
wget https://www.cpan.org/src/5.0/perl-5.36.0.tar.gz --no-check-certificate
tar zxvf perl-5.36.0.tar.gz 
cd perl-5.36.0
./Configure -des -Dprefix=/usr/local/perl
make
make install
```

### 报错2：在git svn clone的时候，发现会报一个错误：

fatal: refs/remotes/trunk: not a valid SHA1

后来查了一下，使用下面这句解决了我的问题（在执行clone的目录下执行）：

```Bash
git update-ref refs/heads/master refs/remotes/git-svn
```