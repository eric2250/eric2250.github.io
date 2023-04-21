添加node
1、master生成token
```
[root@node-01 ~]# kubeadm token create --print-join-command
kubeadm join 172.19.8.250:8443 --token 83glhm.30nf8cih0q8960nu     --discovery-token-ca-cert-hash sha256:30d13676940237d9c4f0c5c05e67cbeb58cc031f97e3515df27174e6cb777f60
```
2、待加入的node节点确保kubelet，docker已启动

每一个node的kubelet都必须进去设置cgroup-drive和swap关闭的启动选项.

注意检查 /var/lib/kubelet/kubeadm-flags.env
```
[root@node-06 ~]# cat /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS=--cgroup-driver=systemd --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.1
```
3、 docker采用docker-ce需要注意该文件，如果没有就创建

```
[root@node-06 ~]# cat /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
},
"storage-driver": "overlay2",
"storage-opts": [
"overlay2.override_kernel_check=true"
]
}
```
4、 关闭swap,并注销/etc/fstab 关于swap的配置信息
```
swapoff -a
```
5、 启动kubelet和docker
```
[root@node-06 ~]# systemctl start kubelet
[root@node-06 ~]# systemctl strart docker
```
6、 master 检查节点是否加入

```
[root@node-01 ~]# kubectl get nodes
NAME      STATUS   ROLES    AGE     VERSION
node-01   Ready    master   2d19h   v1.14.1
node-02   Ready    master   2d19h   v1.14.1
node-03   Ready    master   2d19h   v1.14.1
node-04   Ready    <none>   2d19h   v1.14.1
node-05   Ready    <none>   2d19h   v1.14.1
node-06   Ready    <none>   78s     v1.14.1
```
如果node上显示添加成功，但Master上显示不出来，在node机上使用systemctl status kubelet查看下服务的状态，检查里面的各项状态，单独处理。

删除node
1、 删除一个节点前，先驱赶掉上面的pod
```
kubectl drain k8s-worker2 --delete-local-data --force --ignore-daemonsets
```
此时节点上面的pod开始迁移

检查节点状态，被标记为不可调度节点

```
[root@node-01 ~]# kubectl get nodes
NAME      STATUS                     ROLES    AGE     VERSION
node-01   Ready                      master   2d19h   v1.14.1
node-02   Ready                      master   2d18h   v1.14.1
node-03   Ready                      master   2d18h   v1.14.1
node-04   Ready                      <none>   2d18h   v1.14.1
node-05   Ready                      <none>   2d18h   v1.14.1
node-06   Ready,SchedulingDisabled   <none>   2d18h   v1.14.1
```
最后删除节点

```
[root@node-01 ~]# kubectl delete node k8s-worker2
node "node-06” deleted

[root@node-01 ~]# kubectl get nodes
NAME      STATUS   ROLES    AGE     VERSION
node-01   Ready    master   2d19h   v1.14.1
node-02   Ready    master   2d19h   v1.14.1
node-03   Ready    master   2d19h   v1.14.1
node-04   Ready    <none>   2d18h   v1.14.1
node-05   Ready    <none>   2d18h   v1.14.1
```
 