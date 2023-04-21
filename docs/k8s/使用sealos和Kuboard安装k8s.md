
下载sealos
```
wget -c https://sealyun-home.oss-cn-beijing.aliyuncs.com/sealos-4.0/latest/sealos-amd64 -O sealos && \
chmod +x sealos && mv sealos /usr/bin
```
安装k8s
```
sealos gen labring/kubernetes:v1.24.0 labring/calico:v3.22.1 --masters 192.168.88.12,192.168.88.13,192.168.88.14 --nodes 192.168.88.15 --passwd gwq > Clusterfile
sealos apply -f Clusterfile
```
vim  .bash_profile
```
alias ka="kubectl apply "
alias kc="kubectl create "
alias kd="kubectl delete "
alias ke="kubectl exec -it "
alias kg="kubectl get "
alias kr="kubectl replace -f "
alias kl="kubectl logs "

alias di="docker images "
alias dri="docker rmi "
alias drm="docker rm "
alias dst="docker start "
alias dsd="docker stop "

alias ci="crictl images "
alias cri="crictl rmi "
alias crm="crictl rm "
alias cst="crictl start "
alias csd="crictl stop "
```
安装kuboard

1.先安装docker
```
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
yum -y install docker-ce
systemctl enable docker && systemctl start docker &&systemctl status docker
```
2.安装kuboard
```
sudo docker run -d \
  --restart=unless-stopped \
  --name=kuboard \
  -p 80:80/tcp \
  -p 10081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://192.168.88.11:80" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
  -v /root/kuboard-data:/data \
  eipwork/kuboard:v3
```
开启转发
```
echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.conf
sysctl -p
```
3.访问 Kuboard v3.x
在浏览器输入 http:/192.168.88.11:80 即可访问 Kuboard v3.x 的界面，登录方式：

用户名： admin
密 码： Kuboard123

