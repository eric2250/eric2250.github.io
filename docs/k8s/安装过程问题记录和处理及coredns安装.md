# 问题1： #
```
Error: image google_containers/coredns:v1.8.4 not found
```
解决方案：

本地执行以下命令：
```
docker pull coredns/coredns:1.8.4
docker tag coredns/coredns:1.8.4 registry.aliyuncs.com/google_containers/coredns:v1.8.4
```
重新初始化集群
```
kubeadm init \
  --apiserver-advertise-address=192.168.88.180 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.18.20 \
  --service-cidr=10.96.0.0/12 \
  --pod-network-cidr=10.244.0.0/16
```


# 问题2： #
加入集群报错
```
[kubelet-check] The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get http://localhost:10248/healthz: dial tcp [::1]:10248: connect: connection refused.
```
大概的原因应该是由于之前操作初始化的时候导致了环境不干净，造成后面加入集群时出现了问题。

解决：
```
kubeadm reset
rm -rf /etc/cni/net.d
rm -rf $HOME/.kube/config
rm -rf /etc/kubernetes/
```
# 问题3： #
安装flanneld时pod一直 CrashLoopBackOff状态，查看日志如下报错
```
kubectl logs kube-flannel-ds-amd64-4ftpk -n kube-system

1 main.go:243] Failed to create SubnetManager: error retrieving pod spec for 'kube-system/kube-flannel-ds-amd64-4ftpk':
```
Kubernetes一共提供五种网络组件，可以根据自己的需要选择。我使用的Flannel网络，此处1.5.5和1.6.1也是不一样的，1.6.1加了RBAC。需要执行一下两个命令安装RBAC：
```
kubectl create -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel-rbac.yml

kubectl create -f  https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

```

# 附： #
coredns安装：

下载文件：
```
https://github.com/coredns/deployment/tree/master/kubernetes
```
删除旧的：
```
kubectl delete deployment  coredns  -n=kube-system

```
生成配置yaml
```
./deploy.sh -r 10.96.0.0/16 -i 10.96.0.10 -d cluster.local -t coredns.yaml.sed -s >coredns.yaml
```
安装
```
kubectl apply -f coredns.yaml
```
查看状态
```
kubectl get pods,svc,deployment -o wide -n=kube-system
```