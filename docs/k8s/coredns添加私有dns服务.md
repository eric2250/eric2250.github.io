# k8s中怎么加入私有dns服务器，使pod能解析内部域名

要在Kubernetes中加入私有DNS服务器，以使Pod能够解析内部域名，可以按照以下步骤进行操作：

## 1. 创建一个ConfigMap，用于存储私有DNS服务器的配置信息。可以使用类似以下内容的YAML文件创建ConfigMap：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: private-dns-config
data:
  upstream_dns_servers: |
    nameserver 172.100.3.111
    nameserver 114.114.114.114
```

将上述内容保存为`private-dns-config.yaml`文件，并使用`kubectl apply -f private-dns-config.yaml`命令创建ConfigMap。

## 2. 创建一个Pod，用于运行一个DNS代理容器。可以使用类似以下内容的YAML文件创建Pod：

```
apiVersion: v1
kind: Pod
metadata:
  name: dns-proxy
spec:
  containers:
    - name: dns-proxy
      image: registry.cn-hangzhou.aliyuncs.com/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.15.0
      args:
        - "--cache-size=1000"
        - "--no-resolv"
        - "--server=127.0.0.1#10053"
        - "--log-facility=-"
      ports:
        - containerPort: 53
          name: dns
          protocol: UDP
      volumeMounts:
        - name: private-dns-config
          mountPath: /etc/dnsmasq.d
  volumes:
    - name: private-dns-config
      configMap:
        name: private-dns-config
```

将上述内容保存为`dns-proxy.yaml`文件，并使用`kubectl apply -f dns-proxy.yaml`命令创建Pod。

## 3. 更新Kubernetes集群的CoreDNS配置，以将DNS请求转发到DNS代理容器。可以使用类似以下内容的YAML文件更新CoreDNS配置：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          upstream
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . 127.0.0.1:10053
        cache 30
        loop
        reload
        loadbalance
    }
```

将上述内容保存为`coredns-custom.yaml`文件，并使用`kubectl apply -f coredns-custom.yaml`命令更新CoreDNS配置。

完成上述步骤后，Pod将能够通过DNS代理容器解析内部域名。

你可以将`k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:1.15.0`替换为国内的镜像源来加快下载速度。以下是一些常用的国内镜像源：

- `registry.cn-hangzhou.aliyuncs.com/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.15.0`
- `registry.cn-beijing.aliyuncs.com/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.15.0`
- `dockerhub.azk8s.cn/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.15.0`