
# 1 准备工作
ubnutu
```
sudo apt install curl openssl tar
sudo apt install socat conntrack ebtables ipset
```
centos 
```
yum install sudo curl openssl tar socat conntrack ebtables ipset -y
```
安装kk命令
```
curl -sfL https://get-kk.kubesphere.io | VERSION=v2.2.1 sh -

chmod +x kk
```

# 2 开始安装单节点
## 创建all in one
```
./kk create cluster [--with-kubernetes version] [--with-kubesphere version]

./kk create cluster --with-kubernetes v1.22.10 --with-kubesphere v3.3.0

```

## 验证安装结果

```
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l 'app in (ks-install, ks-installer)' -o jsonpath='{.items[0].metadata.name}') -f

```

输出信息会显示 Web 控制台的 IP 地址和端口号，默认的 NodePort 是 `30880`。现在，您可以使用默认的帐户和密码 (`admin/P@88w0rd`) 通过 `<NodeIP>:30880` 访问控制台。

# 3 集群配置
### 生成配置文件修改以下内容

```
./kk create config [--with-kubernetes version] [--with-kubesphere version] [(-f | --file) path]

```



```
./kk create config --with-kubesphere v3.3.0 --with-kubernetes v1.24.10 -f config
```
```
spec:
  hosts:
  - {name: master1, address: 192.168.11.50, internalAddress: 192.168.11.50, user: root, password: gwqgwq}
  - {name: master2, address: 192.168.11.51, internalAddress: 192.168.11.51, user: root, password: gwqgwq}
  - {name: master3, address: 192.168.11.52, internalAddress: 192.168.11.52, user: root, password: gwqgwq}
  - {name: node1, address: 192.168.11.53, internalAddress: 192.168.11.53, user: root, password: gwqgwq}
  roleGroups:
    etcd:
    - master1
    - master2
    - master3
    control-plane:
    - master1
    - master2
    - master3
    worker:
    - node1
  controlPlaneEndpoint:
    ## Internal loadbalancer for apiservers
    # internalLoadbalancer: haproxy

    domain: k8s.eric.com
    address: "192.168.11.100"
    port: 6443

```
### 创建集群
```
./kk create cluster -f config-sample.yaml
```
### 查看结果

```

```