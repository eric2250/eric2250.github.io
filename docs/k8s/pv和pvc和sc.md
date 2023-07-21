# 1.概念

在Kubernetes中，PV（Persistent Volume）和PVC（Persistent Volume Claim）是用于存储数据的关键概念。

PV是一种抽象的存储资源，它可以是物理存储设备、网络存储、云存储等。PV独立于Pod存在，并且可以由集群管理员预先配置。PV具有自己的生命周期，可以手动创建、删除和维护。

PVC是Pod对PV的请求。PVC定义了Pod对存储的需求，例如存储容量和访问模式。PVC可以视为Pod和PV之间的中间层，它将Pod与具体的存储资源解耦。

关键字是persistentVolumeClaim和persistentVolume。在Kubernetes中，首先需要创建一个PV，然后创建一个PVC，最后将PVC与PV进行绑定。

以下是绑定PV和PVC的一般步骤：

创建PV：使用persistentVolume关键字创建一个PV对象，并指定存储的类型、大小、访问模式等参数。

创建PVC：使用persistentVolumeClaim关键字创建一个PVC对象，并指定存储的需求，例如存储容量和访问模式。

绑定PV和PVC：在PVC对象中，使用spec.volumeName字段指定要绑定的PV的名称。

Pod使用PVC：在Pod的配置中，使用spec.volumes字段指定要使用的PVC。

绑定后，Pod将可以使用PVC来访问和使用PV提供的存储资源。

请注意，PV和PVC之间的绑定是静态的，即PV和PVC之间的关系在绑定后是固定的。如果需要更改绑定关系，需要手动解除绑定并重新绑定。

# 2.实例

实例1：使用静态PV和PVC绑定

创建PV：

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/my-pv
```

创建PVC：

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

绑定PV和PVC：
注意：accessModes必须一致，storage的值pvc一定要小于等于pv的值
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  volumeName: my-pv
```

Pod使用PVC：

```
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: nginx
      volumeMounts:
        - name: my-volume
          mountPath: /data
  volumes:
    - name: my-volume
      persistentVolumeClaim:
        claimName: my-pvc
```

实例2：使用动态PV和PVC绑定

创建StorageClass：

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: my-storage-class
provisioner: my-provisioner
```

创建PVC：

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: my-storage-class
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

Pod使用PVC：

```
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: nginx
      volumeMounts:
        - name: my-volume
          mountPath: /data
  volumes:
    - name: my-volume
      persistentVolumeClaim:
        claimName: my-pvc
```

这些示例演示了如何使用静态PV和PVC或动态PV和PVC进行绑定。你可以根据自己的需求和存储配置进行相应的调整。

# 3.实践

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gitea-pv
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs
  nfs:
    path: /data/nfs/gitea
    server: 172.100.3.111
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gitea-pvc
  namespace: devops
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: nfs    
  volumeName: gitea-pv      
```

希望这些实例对你有所帮助