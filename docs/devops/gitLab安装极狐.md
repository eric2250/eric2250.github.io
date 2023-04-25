# 使用 Docker Compose 安装极狐GitLab

https://docs.gitlab.cn/jh/install/docker.html

使用 [Docker Compose](https://docs.docker.com/compose/)，您可以轻松配置、安装和升级基于 Docker 的极狐GitLab 安装实例：

[安装 Docker Compose](https://docs.docker.com/compose/install/)。

### 设置工作目录变量

```Bash
mkdir -p /apps/gitlab/data
chmod 777 /apps/gitlab/data
export GITLAB_HOME=/apps/gitlab/data
```

### 创建一个 `docker-compose.yml` 文件：

```Dockerfile
version: '3.6'
services:
  web:
    image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
    restart: always
    hostname: '172.100.2.201'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://172.100.2.201'
        gitlab_rails['gitlab_shell_ssh_port'] = 2288
    ports:
      - '7080:80'
      - '2288:22'
    volumes:
      - '$GITLAB_HOME/config:/etc/gitlab'
      - '$GITLAB_HOME/logs:/var/log/gitlab'
      - '$GITLAB_HOME/data:/var/opt/gitlab'
    shm_size: '256m'
```

带ldap认证参数

```Bash
mkdir -p /apps/gitlab/data
mkdir -p /apps/gitlab/backups
chmod 777 /apps/gitlab/data
chmod 777 /apps/gitlab/backups
version: '3.6'
services:
  web:
    image: 'registry.gitlab.cn/omnibus/gitlab-jh:15.10'
    container_name: gitlab
    restart: always
    hostname: 'git.east-port.cn'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://git.east-port.cn'
        gitlab_rails['gitlab_shell_ssh_port'] = 2288
        gitlab_rails['ldap_enabled'] = true
        gitlab_rails['prevent_ldap_sign_in'] = false
        gitlab_rails['ldap_sync_worker_cron'] = "0 */12 * * *"
        gitlab_rails['ldap_group_sync_worker_cron'] = "0 */12 * * *"
        gitlab_rails['ldap_servers'] = {
          'main' => {
            'label' => '口岸统一认证',
            'host' =>  'ldap.east-port.cn',
            'port' => 389,
            'uid' => 'uid',
            'verify_certificates' => false,
            'encryption' => 'plain',
            'bind_dn' => 'cn=admin,dc=east-port,dc=cn',
            'password' => 'Abc,123.',
            'timeout' => 10,
            'active_directory' => true,
            'allow_username_or_email_login' => true,
            'block_auto_created_users' => false,
            'base' => 'dc=east-port,dc=cn',
            'group_base' => 'ou=eport,dc=east-port,dc=cn',
            'admin_group' => 'admin',
            'external_groups' => ['interns','contractors'],
            'user_filter' => '',
            'lowercase_usernames' => false,
            'attributes' => {
                    'username' => ['uid', 'userid', 'sAMAccountName'],
                    'email' => ['mail', 'email', 'userPrincipalName'],
                    'name' => 'cn',
                    'first_name' => 'givenName',
                    'last_name' => 'sn'
            },
            'sync_ssh_keys' => false
          }
        }   
    ports:
      - '80:80'
      - '2288:22'
    volumes:
      - '/apps/gitlab/data/config:/etc/gitlab'
      - '/apps/gitlab/data/logs:/var/log/gitlab'
      - '/apps/gitlab/data/data:/var/opt/gitlab'
      - '/apps/gitlab/backups:/mnt/backups'
    shm_size: '256m'
```

### 确保您在与 `docker-compose.yml` 相同的目录下并启动极狐GitLab：

```Plaintext
docker compose up -d
```

### 访问登录，设置中文

访问：http://gitlab.east-port.cn/（172.100.2.201：7080）

默认账号：root

密码：12y08sKKlJH4Aor+5JbYmRuBzH70yX64/kr+Uo4PDus= 

```Bash
docker exec -t gitlab cat /etc/gitlab/initial_root_password
```

cat /etc/gitlab/initial_root_password

```Bash
[jenkins@ep-jenkins gitlab]$ docker ps
CONTAINER ID   IMAGE                                         COMMAND                  CREATED          STATUS                   PORTS                                                                                               NAMES
0b9d44629f8a   registry.gitlab.cn/omnibus/gitlab-jh:latest   "/assets/wrapper"        24 minutes ago   Up 8 minutes (healthy)   80/tcp, 443/tcp, 0.0.0.0:7080->7080/tcp, :::7080->7080/tcp, 0.0.0.0:2288->22/tcp, :::2288->22/tcp   gitlab-web-1                                "docker-entrypoint.s…"   2 days ago       Up 27 hours              0.0.0.0:5432->5432/tcp, :::5432->5432/tcp                                                           890-db13-1
[jenkins@ep-jenkins gitlab]$ docker exec -it 0b9d44629f8a bash
root@172:/# cat /etc/gitlab/initial_root_password 
# WARNING: This value is valid only in the following conditions
#          1. If provided manually (either via `GITLAB_ROOT_PASSWORD` environment variable or via `gitlab_rails['initial_root_password']` setting in `gitlab.rb`, it was provided before database was seeded for the first time (usually, the first reconfigure run).
#          2. Password hasn't been changed manually, either via UI or via command line.
#
#          If the password shown here doesn't work, you must reset the admin password following https://docs.gitlab.com/ee/security/reset_user_password.html#reset-your-root-password.

Password: 12y08sKKlJH4Aor+5JbYmRuBzH70yX64/kr+Uo4PDus=

# NOTE: This file will be automatically deleted in the first reconfigure run after 24 hours.
```

GitLab 设置为中文版

![img](..\images\gitlab.png)

# 使用 Docker Engine 安装极狐GitLab

您可以微调这些目录以满足您的要求。 一旦设置了 `GITLAB_HOME` 变量，您就可以运行镜像：

```Bash
sudo docker run --detach \
  --hostname gitlab.example.com \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  registry.gitlab.cn/omnibus/gitlab-jh:latest
```

# CentOS 7安装极狐GitLab

1. 安装和配置必须的依赖项

- 在 CentOS 7上，下面的命令也会在系统防火墙中打开 HTTP、HTTPS 和 SSH 访问。这是一个可选步骤，如果您打算仅从本地网络访问极狐GitLab，则可以跳过它。

```Bash
sudo yum install -y curl policycoreutils-python openssh-server perl
sudo systemctl enable sshd
sudo systemctl start sshd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo systemctl reload firewalld
```

- （可选）下一步，安装 Postfix 以发送电子邮件通知。如果您想使用其他解决方案发送电子邮件，请跳过此步骤并在安装极狐GitLab 后[配置外部 SMTP 服务器](https://docs.gitlab.cn/omnibus/settings/smtp.html)。

```Bash
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
```

- 在安装 Postfix 的过程中可能会出现一个配置界面，在该界面中选择“Internet Site”并按下回车。把“mail name”设置为您服务器的外部 DNS 域名并按下回车。如果还有其它配置界面出现，继续按下回车以接受默认配置。

1. 下载/安装极狐GitLab

- 配置极狐GitLab 软件源镜像。

```Bash
curl -fsSL https://packages.gitlab.cn/repository/raw/scripts/setup.sh | /bin/bash
```

- 接下来，安装极狐GitLab。确保您已正确[设置您的 DNS](https://docs.gitlab.cn/omnibus/settings/dns.html)，并更改 https://gitlab.eric.com 为您要访问极狐GitLab 实例的 URL。安装包将在该 URL 上自动配置和启动极狐GitLab。
- 对于 `https` 站点，极狐GitLab 将使用 Let's Encrypt 自动请求 SSL 证书，这需要有效的主机名和入站 HTTP 访问。您也可以使用自己的证书或仅使用 `http://`（不带`s`）。
- 如果您想为初始管理员用户(`root`)指定自定义密码，请查看[文档](https://docs.gitlab.cn/omnibus/installation/index.html#设置初始密码)。如果未指定密码，将自动生成随机密码。
- 执行如下命令开始安装：

```Bash
sudo EXTERNAL_URL="http://gitlab.eric.com" yum install -y gitlab-jh
```

1. 访问极狐GitLab 实例并登录

```Bash
cat /etc/gitlab/initial_root_password
```

- 除非您在安装过程中指定了自定义密码，否则将随机生成一个密码并存储在 /etc/gitlab/initial_root_password 文件中(出于安全原因，24 小时后，此文件会被第一次 `gitlab-ctl reconfigure` 自动删除，因此若使用随机密码登录，建议安装成功初始登录成功之后，立即修改初始密码）。使用此密码和用户名 `root` 登录。
- 有关安装和配置的详细说明，请参阅我们的[文档](https://docs.gitlab.cn/omnibus/installation/)。

1. 后续配置

- 完成安装后，请参考建议的[后续配置](https://docs.gitlab.cn/jh/install/next_steps.html)，包括身份验证选项和注册限制的配置。

# Kubernetes安装极狐GitLab

```Bash
helm repo add gitlab-jh https://charts.gitlab.cn
helm repo update
helm upgrade --install gitlab gitlab-jh/gitlab \
  --version 5.6.2 \
  --timeout 600s \
  --set global.hosts.domain=eric.com \
  --set global.hosts.externalIP=172.100.3.66 \
  --set certmanager-issuer.email=admin@eric.com 
 

```

```
 helm install gitlab gitlab-jh/gitlab
 helm uninstall gitlab gitlab-jh/gitlab
```

