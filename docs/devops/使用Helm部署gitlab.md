## 使用 Helm 部署gitlab

```
helm repo add gitlab-jh https://charts.gitlab.cn
helm repo update
helm upgrade --install gitlab gitlab-jh/gitlab \
  --version 5.6.2 \
  --timeout 600s \
  --set global.hosts.domain=gitlab.eric.com \
  --set global.hosts.externalIP=172.100.3.66 \
  --set certmanager-issuer.email=admin@eric.com 
```

