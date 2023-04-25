https://docs.gitlab.cn/jh/administration/auth/ldap/#%E9%80%9A%E7%94%A8-ldap-%E8%AE%BE%E7%BD%AE

# 方法1，修改`docker-compose.yml` 重建容器

## 编辑 `docker-compose.yml`：

```Bash
mkdir -p /apps/gitlab/data
chmod 777 /apps/gitlab/data
export GITLAB_HOME=/apps/gitlab/data
version: '3.6'
services:
  web:
    image: 'registry.gitlab.cn/omnibus/gitlab-jh:latest'
    restart: always
    hostname: '172.100.2.201'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.east-port.cn'
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
      - '7080:7080'
      - '2288:22'
    volumes:
      - '$GITLAB_HOME/config:/etc/gitlab'
      - '$GITLAB_HOME/logs:/var/log/gitlab'
      - '$GITLAB_HOME/data:/var/opt/gitlab'
    shm_size: '256m'
```

## 保存文件并重启极狐GitLab：

```Plaintext
docker compose up -d
```

# 方法2 ，在运行的gitlab修改配置文件

centos部署的修改文件/etc/gitlab/gitlab.rb，打开并修改501行到548行以下内容

```Bash
 gitlab_rails['ldap_enabled'] = true
 gitlab_rails['prevent_ldap_sign_in'] = false

###! **remember to close this block with 'EOS' below**
 gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
   main: # 'main' is the GitLab 'provider ID' of this LDAP server
     label: 'LDAP'
     host: '192.168.88.10'
     port: 389
     uid: 'uid'
     bind_dn: 'cn=admin,dc=eric,dc=com'
     password: '123456'
     encryption: 'plain' # "start_tls" or "simple_tls" or "plain"
     verify_certificates: false
     smartcard_auth: false
     active_directory: true
     allow_username_or_email_login: false
     lowercase_usernames: false
     block_auto_created_users: false
     base: 'dc=eric,dc=com'
     user_filter: ''
     ## EE only
     group_base: 'ou=eport,dc=eric,dc=com'
     admin_group: ''
     sync_ssh_keys: false
     EOS
#vim gitlab.rb
#添加一下内容
gitlab_rails['ldap_enabled'] = true
gitlab_rails['prevent_ldap_sign_in'] = false
gitlab_rails['ldap_servers'] = {
'main' => {
  'label' => '口岸统一认证',
  'host' =>  'ldap.east-port.cn',
  'port' => 389,
  'uid' => 'uid',
  'verify_certificates' => false,
  'bind_dn' => 'cn=admin,dc=east-port,dc=cn',
  'password' => 'Abc,123.',
  'timeout' => 10,
  'encryption' => 'plain',
  'active_directory' => true,
  'allow_username_or_email_login' => true,
  'block_auto_created_users' => false,
  'base' => 'dc=east-port,dc=cn',
  'user_filter' => '',
  'attributes' => {
    'username' => ['uid', 'userid', 'sAMAccountName'],
    'email' => ['mail', 'email', 'userPrincipalName'],
    'name' => 'cn',
    'first_name' => 'givenName',
    'last_name' => 'sn'
  },
  'lowercase_usernames' => false,
  'group_base' => 'ou=eport,dc=east-port,dc=cn',
  'admin_group' => 'admin',
  'external_groups' => ['interns','contractors'],
  'sync_ssh_keys' => false
  }
}
```

- 并修改以下字段
- https://docs.gitlab.cn/jh/administration/auth/ldap/#%E5%9F%BA%E6%9C%AC%E9%85%8D%E7%BD%AE

```TOML
  'label' => 'LDAP' # 该字段为LDAP服务名称，该名称会展示在GitLab Portal的登陆界面
  'host' =>  'ldap.mydomain.com' # 该字段为LDAP服务器的地址
  'bind_dn' => '_the_full_dn_of_the_user_you_will_bind_with' # 该字段为LDAP管理员用户的DN
  'password' => '_the_password_of_the_bind_user' # 该字段为LDAP管理员用户的password
  'uid' => 'sAMAccountName',  Linux 为'uid' windows为'sAMAccountName'
  encryption 的值 simple_tls 对应于 LDAP 库中的“Simple TLS”。start_tls 对应于 StartTLS，不要与常规 TLS 混淆。通常，如果您指定 simple_tls 在端口 636 上，而 start_tls（StartTLS）将在端口 389 上。plain 也在端口 389 上运行。删除的值：tls 被替换为 start_tls，ssl 被替换为 simple_tls。
```

- 执行`sudo gitlab-ctl reconfigure`使得上述配置生效

```Plain
gitlab-ctl reconfigure
```

## 使用Rake Task检查同步情况

```Bash
gitlab-rake gitlab:ldap:check

gitlab-rake gitlab:ldap:check[100] #该命令检查前100个LDAP用户
```

## LDAP用户同步周期

https://docs.gitlab.cn/jh/administration/auth/ldap/ldap_synchronization.html

- GitLab默认每日执行LDAP用户同步，如果您需要修改LDAP的同步周期，可以通过修改`/etc/gitlab/gitlab.rb`中配置实现设置为每 12 小时在每小时运行一次。

```Bash
gitlab_rails['ldap_sync_worker_cron'] = "0 */12 * * *"
gitlab_rails['ldap_group_sync_worker_cron'] = "0 */12 * * *"
```