1、下载nodeJS的安装包

```
https://nodejs.org/zh-cn/download/
```

2、解压nodeJS的解压包，在根目录下新增两个文件夹node_global和node_cache

```Bash
mkdir node_global
mkdir node_cache
```

3、配置环境变量

​        NODE_HOME:配置的是nodeJS解压的根路径/apps/node-v16.17.0-linux-x64

​        Path:%NODE_HOME%;%NODE_HOME%\node_global

```Bash
vim /etc/profile
----
NODE_HOME=/apps/node-v16.17.0-linux-x64
export PATH=$NODE_HOME/bin:$NODE_HOME/node_global:$PATH
----
source /etc/profile
```

​        检验是否配置成功：node -v

```Bash
node -v
v16.17.0
npm -v
8.15.0
```

4、配置npm的全局模块的下载地址

```Bash
npm config set cache "/apps/node-v16.17.0-linux-x64/node_cache"
npm config set prefix "/apps/node-v16.17.0-linux-x64/node_global"
npm config set registry https://registry.npm.taobao.org/
```

​        检验是否配置成功：本机用户找到.npmrc文件,查看是否有以上三行脚本

```Bash
cat ~/.npmrc
cache=/apps/node-v16.17.0-linux-x64/node_cache
prefix=/apps/node-v16.17.0-linux-x64/node_global
registry=https://registry.npm.taobao.org/
```

5、下载github的Vue的项目解压

```Bash
        检验是否安装成功：npm -v
```

6、在解压的项目中是没有node_modules的，在工程的根目录下需要通过doc命令npm install进行再次依赖下载（package.json）

```Bash
npm install --registry=https://registry.npm.taobao.org
```

7、编译前端项目

```Bash
npm run build:prod
```

8、在通过npm run dev 启动项目

```Bash
npm run dev
```