操作记录：

## yaml ##
```
apiVersion: 声明K8s的API版本
kind: 声明API对象的类型，这里是Pod
metadata:设置Pod的元数据
  name: hello-world 指定Pod的名称Pod名称必粗在Namespace内唯一
spec:配置Pod的具体规格
  restartPolicy: 重启策略
  containers:容器规格，数组形式，每一项定义一个容器
  - name:指定容器的名称，在Pod的定义中唯一
    image:设置容器镜像
    command:设置容器的启动命令
```
## 1.污点
查看
```
[root@k8s-master ~]# kubectl describe node k8s-master |grep Taint
Taints:             node-role.kubernetes.io/master:NoSchedule
```
创建
```
[root@k8s-master ~]# kubectl taint node k8s-node1 env_role=yes:NoSchedule
node/k8s-node1 tainted
[root@k8s-master ~]# kubectl describe node k8s-node |grep Taint
Taints:             env_role=yes:NoSchedule
Taints:             <none>
 
```

		```测试应用
		[root@k8s-master ~]# kubectl create deployment web --image=nginx
		[root@k8s-master ~]# kubectl scale deployment web --replicas=3
		[root@k8s-master ~]# kubectl get pods  -owide
		[root@k8s-master ~]# kubectl delete deployment web
	
		```
删除
```
[root@k8s-master ~]# kubectl taint node k8s-node1 env_role:NoSchedule-
node/k8s-node1 untainted
[root@k8s-master ~]# kubectl describe node k8s-node |grep Taint
Taints:             <none>
Taints:             <none> 
```
污点容忍
```
spec：
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
```
## 2.yaml

生成yaml
```
kubectl create deployment web --image=nginx --dry-run -o yaml >web.yaml
```
使用yaml部署
```
kubectl apply -f web.yaml
```
查看：
```
kubectl get pods  -owide
```
## 3.暴露端口
生成yaml
```
kubectl expose deployment web --port=80 --type=NodePort --target-port=80 --name web --dry-run -o yaml >web-expost.yaml
```
使用yaml部署
```
kubectl apply -f web-expost.yaml
```
查看：
```
kubectl get svc  -owide
```
## 4.升级回退
升级镜像
```
kubectl set image deployment web nginx=nginx:1.15
```
查看升级状态：
```
kubectl rollout status deployment web
```
查看历史版本：
```
kubectl rollout history deployment web
```

回退到上一个版本
```
kubectl rollout undo deployment web
```
回退到指定版本
```
kubectl rollout undo deployment web --to-revision=2
```
## 5.弹性伸缩
```
kubectl scale deployment web --replicas=3
```

## 6.controller

### 1.有状态部署StatefulSet
```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx-statefulset
  namespace: default

```
命名：主机名称.service名称.名称空间.svc.cluster.loacl
```
eg: nginx-statefulset-0.nginx.default.svc.cluster.loacl
```
删除
```
 kubectl delete statefulset --all

```
查看：
```
kubectl get statefulset
````

### 2.DaemonSet
```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-test 
```

进入到pod里
```
kubectl exec -it ds-test-n9cdv bash
```
### 3.Secret
```
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm

```
base64加密
```
echo -n 'admin'| base64

YWRtaW4=
```
创建：
```
kubectl apply -f secret.yaml
```
查看：
```
kubectl get secret
```
删除：
```
 kubectl delete secret --all
```
以变量挂在使用
```
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password

```
以volume挂载使用
```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: mysecret
```
### 4.ConfigMap
创建：
```
kubectl create configmap redis-config --from-file=redis.properties
```
查看：

```
kubectl get cm
kubectl describe cm

```
以volume挂载使用
```
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: redis-config
  restartPolicy: Never
```
	查看日志
	```
	kubectl logs mypod
	清除
	kubectl delete -f cm.yaml
	```	
以变量挂在使用
定义：
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: myconfig
  namespace: default
data:
  special.level: info
  special.type: hello

```
使用：
```
      env:
        - name: LEVEL
          valueFrom:
            configMapKeyRef:
              name: myconfig
              key: special.level
        - name: TYPE
          valueFrom:
            configMapKeyRef:
              name: myconfig
              key: special.type
  restartPolicy: Never
```
查看
```
kubectl logs mypod
info hello
```

## 7.namespace 命名空间
创建
```
kubectl create  ns ericns
```
查看：
```
kubectl get ns

```
在创建的命名空间下创建pod
```
kubectl run nginx --image=nginx -n ericns

kubectl get pod -n ericns

```
创建角色
```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: ctnrs
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```
```
kubectl apply -f rbac-role.yaml 

kubectl get role -n ericns

```
角色绑定
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: ericns
subjects:
- kind: User
  name: lucy # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```
```
kubectl apply -f rbac-rolebinding.yaml 

kubectl get rolebinding -n ericns

```
## 8.ingress

### 1.创建nginx并暴露端口
```
cat web.yaml web-expost.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: web
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: web
    spec:
      containers:
      - image: nginx:1.14
        name: nginx
        resources: {}
status: {}
```
------------------
```
cat web-expost.yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: web
  name: web
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: web
  type: NodePort
status:
  loadBalancer: {}
```
```
kubectl apply -f web.yaml 
kubectl apply -f web-expost.yaml 

kubectl get pods,svc,deploy
```
### 2.部署ingress controller

创建ingress
```
kubectl apply -f ingress-controller.yaml 

  namespace/ingress-nginx created
  configmap/nginx-configuration created
  configmap/tcp-services created
  configmap/udp-services created
  serviceaccount/nginx-ingress-serviceaccount created
  clusterrole.rbac.authorization.k8s.io/nginx-ingress-clusterrole created
  role.rbac.authorization.k8s.io/nginx-ingress-role created
  rolebinding.rbac.authorization.k8s.io/nginx-ingress-role-nisa-binding created
  clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-clusterrole-nisa-binding created
  deployment.apps/nginx-ingress-controller created
  limitrange/ingress-nginx created
  
```
 查看
```
kubectl get pod -n ingress-nginx
kubectl get pod,svc,ing -n ingress-nginx -owide
```
创建规则
```
----
cat ingress01.yaml 
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: ingress.eric.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web
          servicePort: 80

----
kubectl apply -f ingress01.yaml 

```
测试：
http://ingress.eric.com/

## 9.helm
安装
```
tar zxvf helm-v3.0.0-linux-amd64.tar.gz 
cd linux-amd64/
cp helm /usr/bin/
helm -h
```
配置helm仓库
```
helm repo add stable http://mirror.azure.cn/kubernetes/charts
helm repo add kaiyuanshe http://mirror.kaiyuanshe.cn/kubernetes/charts
helm repo update
helm repo list
helm repo remove stable
```
使用
```

helm search repo weave

helm install myweave apphub/weave-scope

```
查看
```
helm list

helm status myweave

kubectl get pods,svc

```
修改暴露端口
```
kubectl edit svc myweave-weave-scope
     76   sessionAffinity: None
     77   type: NodePort

kubectl get pods,svc


````
新建Chart
```
helm create chart mychart
```
```
 tree mychart/
mychart/
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```
```
cd templates
rm -rf *
kubectl create deployment web1 --image=nginx --dry-run -o yaml >web1.yaml
kubectl apply -f web1.yaml 
kubectl expose deployment web1 --port=80 --target-port=80 --type=NodePort --dry-run -o yaml >servce1.yaml
```
安装
```
cd ../../
helm install web1 mychart/

```
升级
```
helm update web1 mychart/
```
卸载
```
helm uninstall web1 mychart/
```
查看历史版本及回退
```
helm history web1

helm rollback  web1 1
```
用传参数的方式部署
定义参数值
```
cat mychart/values.yaml 
###my values

replicas: 2
image: nginx
tag: 1.15
label: nginx
port: 80
nodeport: 30088
```
定义变量
```
cat mychart/templates/deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: {{ .Values.label}}
  name: {{ .Release.Name}}-deploy
spec:
  replicas: {{ .Values.replicas}}
  selector:
    matchLabels:
      app: {{ .Values.label}}
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: {{ .Values.label}}
    spec:
      containers:
      - image: {{ .Values.image}}
        name: nginx
        resources: {}
status: {}
---------------------------------
cat mychart/templates/service.yaml 
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: {{ .Values.label}}
  name: {{ .Release.Name}}-svc
spec:
  ports:
  - port: {{ .Values.port}}
    protocol: TCP
    targetPort: 80
  selector:
    app: {{ .Values.label}}
  type: NodePort
  ports:
    - port: {{ .Values.port}}
      targetPort: {{ .Values.port}}
      nodePort: {{ .Values.nodeport}}
status:
  loadBalancer: {}

```

## 9.PV/PVC
PVC
``` 
cat pvc.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-dep1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: wwwroot
          mountPath: /usr/share/nginx/html
        ports:
        - containerPort: 80
      volumes:
      - name: wwwroot
        persistentVolumeClaim:
          claimName: my-pvc

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
```
PV
```
 cat pv.yaml 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  nfs:
    path: /data/nfs
    server: 192.168.88.180
```
```
kubectl apply -f pvc.yaml 
kubectl apply -f pv.yaml 
kubectl get pv,pvc
```
## 10.label ##

打标签
```
kubectl label node k8s-node1 agent=true
kubectl label pods tomcat app=eric
```
查看label
```
kubectl get nodes --show-labels
```
删除名为“agent=true”的label 。（使用“ - ”减号相连）
```
kubectl label node k8s-node1 agent-
```

# 附：命令 #
查看写格式
```
 kubectl api-resources
```
查看服务关联后端的节点
```
kubectl get endpoints
```
查看网络状态详细信息
```
kubectl get all -o wide
```
查看日志
```
kubectl logs $podname
```
更新资源的现有容器映像
```
kubectl set image deployment/nginx-gsy nginx-gsy=nginx:1.14

```
-w实时查看状态
```
 kubectl get pods -w
```
查看副本集
```
kubectl get replicaset
```
查看历史版及回退
```
kubectl rollout history deploy/nginx

kubectl rollout undo deploy/nginx --to-revision=2 （不加--to-revision=2 默认上个版本）

kubectl rollout status deploy/nginx
```
进入pod
```
kubectl exec -it nginx-pod

```
查看详细信息
```
kubectl describe deploy nginx  --all-namespaces
```

强制删除pod、ns

```
kubectl delete pod POD_NAME --grace-period=0 --force
```

--grace-period=0：表示pod从删除操作开始到被终止的时间。设置为0表示立即终止，不会等待。

--force：表示强制删除。如果pod无法正常删除时，使用此选项将pod从节点上强制删除。

强制删除pv、pvc

```
kubectl patch pv xxx -p '{"metadata":{"finalizers":null}}'
kubectl patch pvc xxx -p '{"metadata":{"finalizers":null}}'
```



git push 报错解决：
1.报文件过大
```
remote: Powered by GITEE.COM [GNK-6.2]
remote: error: File: 31a18ae894fa17003ec64707a5b9056c917911eb 181.49 MB, exceeds 100.00 MB.
remote: Use command below to see the filename:
remote: git rev-list --objects --all | grep 31a18ae894fa17003ec64707a5b9056c917911eb
remote: Please remove the file from history and try again. (https://gitee.com/help/articles/4232)
To https://gitee.com/erictor/kubernetes.git
 ! [remote rejected] master -> master (pre-receive hook declined)
error: failed to push some refs to 'https://gitee.com/erictor/kubernetes.git'
```
解决：
```
# git rev-list --objects --all | grep 31a18ae894fa17003ec64707a5b9056c917911eb
31a18ae894fa17003ec64707a5b9056c917911eb yaml/jenkins/image/jdk-8u171-linux-x64.tar.gz
# git filter-branch --tree-filter 'rm -f yaml/jenkins/image/jdk-8u171-linux-x64.tar.gz' HEAD 
Rewrite 4e508cb00056d702957259e700749a6fa7c1eee2 (21/22) (16 seconds passed, remaining 0 predicted)     
Ref 'refs/heads/master' was rewritten

```























































