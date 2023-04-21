
## 8. 安装Dashboard
配置hosts
``` 
192.30.253.112 github.com 
192.30.253.119 gist.github.com 
151.101.100.133 assets-cdn.github.com 
151.101.100.133 raw.githubusercontent.com 
151.101.100.133 gist.githubusercontent.com 
151.101.100.133 cloud.githubusercontent.com 
151.101.100.133 camo.githubusercontent.com 
151.101.100.133 avatars0.githubusercontent.com 
151.101.100.133 avatars1.githubusercontent.com 
151.101.100.133 avatars2.githubusercontent.com 
151.101.100.133 avatars3.githubusercontent.com 
151.101.100.133 avatars4.githubusercontent.com 
151.101.100.133 avatars5.githubusercontent.com 
151.101.100.133 avatars6.githubusercontent.com 
151.101.100.133 avatars7.githubusercontent.com 
151.101.100.133 avatars8.githubusercontent.com 
```
### 1.下载recommended.yaml
```
curl -kfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml --no-check-certificate
```
### 2.修改recommended.yaml
将命名空间改为默认的kube-system
```
sed -i '/namespace/ s/kubernetes-dashboard/kube-system/g' recommended.yaml
```
vim recommended.yaml
添加40行和44行的内容
```
type: NodePort
nodePort: 30001
```
```
 39 spec:
 40   type: NodePort
 41   ports:
 42 - port: 443
 43   targetPort: 8443
 44   nodePort: 30001
 45   selector:
 46 k8s-app: kubernetes-dashboard
 47 
 48 ---
```

### 3.启动kubernetes-dashboard
```
docker pull kubernetesui/dashboard:v2.0.0-beta1
kubectl apply -f recommended.yaml
kubectl get pods,svc -n kube-system
NAME                                              READY   STATUS    RESTARTS   AGE
pod/coredns-7ff77c879f-6fwch                      1/1     Running   1          20h
pod/coredns-7ff77c879f-z6fj5                      1/1     Running   1          20h
pod/etcd-k8s-master                               1/1     Running   1          20h
pod/kube-apiserver-k8s-master                     1/1     Running   1          20h
pod/kube-controller-manager-k8s-master            1/1     Running   2          20h
pod/kube-flannel-ds-amd64-5fzqt                   1/1     Running   1          20h
pod/kube-flannel-ds-amd64-m9c2x                   1/1     Running   1          20h
pod/kube-flannel-ds-amd64-sdgfw                   1/1     Running   1          20h
pod/kube-proxy-2pzdr                              1/1     Running   1          20h
pod/kube-proxy-5pbrv                              1/1     Running   1          20h
pod/kube-proxy-jq9fs                              1/1     Running   1          20h
pod/kube-scheduler-k8s-master                     1/1     Running   2          20h
pod/kubernetes-dashboard-556cdb78cd-r5rhq         1/1     Running   0          2m39s
pod/kubernetes-metrics-scraper-86f6785867-r4q5k   1/1     Running   0          2m39s

NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
service/dashboard-metrics-scraper   ClusterIP   10.111.238.77    <none>        8000/TCP                 2m39s
service/kube-dns                    ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   20h
service/kubernetes-dashboard        NodePort    10.106.244.109   <none>        443:30001/TCP            2m40s


```
#### 问题：####
```
2021/09/07 01:44:43 Initializing csrf token from kubernetes-dashboard-csrf secret panic: Get https://10.1.0.1:443/api/v1/namespaces/kube-system/secrets/kubernetes-dashboard-csrf: dial tcp 10.1.0.1:443: i/o timeout
```
解决：指定部署至master节点,编辑文件添加nodeName: servername
```
vim recommended.yaml
190     spec:
191       nodeName: k8s-master1
192       containers:
193         - name: kubernetes-dashboard
194           image: kubernetesui/dashboard:v2.0.0-beta1
195           imagePullPolicy: Always

...
266     spec:
267       nodeName: k8s-master1
268       containers:
269         - name: kubernetes-metrics-scraper
270           image: kubernetesui/metrics-scraper:v1.0.0
```

### 4.使用token访问，创建SA并绑定默认cluster-admin管理员集群角色
创建管理员用户
```
kubectl create serviceaccount dashboard-admin -n kube-system
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
```
获取token值

kubectl get secret -n kube-system |grep dashboard-admin		#查找管理员用户的token名字
```
[root@k8s-master yaml]# kubectl get secret -n kube-system |grep dashboard-admin
dashboard-admin-token-g5ktl                      kubernetes.io/service-account-token   3      26s
```
查看内容
kubectl describe secret dashboard-admin-token-rh8hd -n kube-system
```
[root@k8s-master yaml]# kubectl describe secret dashboard-admin-token-g5ktl -n kube-system
Name:         dashboard-admin-token-g5ktl
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: dashboard-admin
              kubernetes.io/service-account.uid: 5ce623cd-4785-429e-9780-e6fb1ad8e001

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IjVsNTBVbzBzUDVjRVhXTVVqWm41RmZEczlYTmdSdU1JWGFEZnl5NjBVVnMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkYXNoYm9hcmQtYWRtaW4tdG9rZW4tZzVrdGwiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGFzaGJvYXJkLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNWNlNjIzY2QtNDc4NS00MjllLTk3ODAtZTZmYjFhZDhlMDAxIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmRhc2hib2FyZC1hZG1pbiJ9.qIAsYtarO2mV6c4zR2IMinWuw2gT20ipLi9pGBVrU7euLV8zkE014g-H0FC3zxqs6Uirj7WJ_pbNr4FIrqiTrgdl-pprQ5LaAp16m1I19QI0CTWbz1MhaJmg761JTqLvU8uo1EfyWtv8VQOndej3FTqLxCiSSRkI2qGVFOUp8SRiC3vn5aVb-aoC94F_1SoO0qH5RZPn9Jx0cm5waxucZnOK5W4bqfwpuTSASUlqYjW2aVR-TAnhk622P5iKiYPEjv8aywxFABeCu9SgkQferpqr9nQ63cXrPvrvkmQbJehQRUVwtU8qtISa50bjfPzoP8YNlUsR6ak4rn0AlyOQvQ
[root@k8s-master yaml]# 
```
### 5.访问kubernetes-dashboard
https://192.168.88.180:30001

选择token 输入刚才获取的token值
