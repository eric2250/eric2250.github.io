# 1. 新建一个Dockerfile

```
[root@ha1 kaniko]# cat Dockerfile 
FROM alpine
ENTRYPOINT ["/bin/sh", "-c", "echo hello"]
```



# 2. 新建cm和secret

```
kubectl create configmap kanikodockerfile --from-file=./Dockerfile
kubectl delete  secret dockerhub
kubectl create secret docker-registry dockerhub --docker-server=registry.cn-hangzhou.aliyuncs.com --docker-username=erictor888 --docker-password=Abc,123. --docker-email=gouwqiang@163.com
```

# 3.新建pod

```
cat kaniko.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: registry.cn-hangzhou.aliyuncs.com/weiyigeek/kaniko-executor:latest
    env:
    - name: DOCKERHUB
      value: "registry.cn-hangzhou.aliyuncs.com"
    - name: AUTHOR
      value: "erictor888"
    - name: IMAGE_NAME
      value: "myappweb"
    - name: IMAGE_VERSION
      value: "v1"
    args: [ "--dockerfile=Dockerfile",
            "--context=dir://workspace",
            "--destination=registry.cn-hangzhou.aliyuncs.com/erictor888/myappweb:v2",
            "--cache",
            "--cache-dir=/cache"]
    volumeMounts:
      - name: kaniko-secret
        mountPath: /kaniko/.docker
      - name: dockerfile-storage
        mountPath: /workspace
      - name: kaniko-cache
        mountPath: /cache
  restartPolicy: Never
  nodeSelector:
    kubernetes.io/hostname: "k8s-node1"
  volumes:
    - name: kaniko-secret
      secret:
        secretName: dockerhub
        items:
          - key: .dockerconfigjson
            path: config.json
    - name: dockerfile-storage
      hostPath:
        path: /storage/dev/soft/kaniko/demo
        type: DirectoryOrCreate
    - name: kaniko-cache
      hostPath:
        path: /storage/dev/soft/kaniko/cache
        type: DirectoryOrCreate
```

# 4.执行

```
[root@ha1 kaniko]# kubectl apply -f kaniko.yaml 
pod/kaniko created
[root@ha1 kaniko]# kubectl logs kaniko
INFO[0000] Retrieving image manifest alpine             
INFO[0000] Retrieving image alpine from registry index.docker.io 
INFO[0003] Retrieving image manifest alpine             
INFO[0003] Returning cached image manifest              
INFO[0004] Built cross stage deps: map[]                
INFO[0004] Retrieving image manifest alpine             
INFO[0004] Returning cached image manifest              
INFO[0004] Retrieving image manifest alpine             
INFO[0004] Returning cached image manifest              
INFO[0004] Executing 0 build triggers                   
INFO[0004] Building stage 'alpine' [idx: '0', base-idx: '-1'] 
INFO[0004] Skipping unpacking as no commands require it. 
INFO[0004] ENTRYPOINT ["/bin/sh", "-c", "echo hello"]   
INFO[0004] No files changed in this command, skipping snapshotting. 
INFO[0004] Pushing image to registry.cn-hangzhou.aliyuncs.com/erictor888/myappweb:v2 
INFO[0005] Pushed registry.cn-hangzhou.aliyuncs.com/erictor888/myappweb@sha256:978d699274b9c097b4c840cd322f70a1bd8b3a99c269c6e1dc84f3b40e16fc80 
```

