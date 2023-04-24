kubeadm init [flags]
```
选项
--apiserver-advertise-address string
	API 服务器所公布的其正在监听的 IP 地址。如果未设置，则使用默认网络接口。
--apiserver-bind-port int32     默认值：6443
	API 服务器绑定的端口。
--apiserver-cert-extra-sans stringSlice
	用于 API Server 服务证书的可选附加主题备用名称（SAN）。可以是 IP 地址和 DNS 名称。
--cert-dir string     默认值："/etc/kubernetes/pki"
	保存和存储证书的路径。
--certificate-key string
	用于加密 kubeadm-certs Secret 中的控制平面证书的密钥。
--config string
	kubeadm 配置文件的路径。
--control-plane-endpoint string
	为控制平面指定一个稳定的 IP 地址或 DNS 名称。
--cri-socket string
	要连接的 CRI 套接字的路径。如果为空，则 kubeadm 将尝试自动检测此值；仅当安装了多个 CRI 或具有非标准 CRI 插槽时，才使用此选项。
--dry-run
	不要应用任何更改；只是输出将要执行的操作。
--experimental-patches string
	包含名为 "target[suffix][+patchtype].extension" 的文件的目录路径。 例如，"kube-apiserver0+merge.yaml" 或仅仅是 "etcd.json"。 "patchtype" 可以是 "strategic"、"merge" 或 "json" 之一，并且它们与 kubectl 支持的补丁格式匹配。 默认的 "patchtype" 为 "strategic"。 "extension" 必须为 "json" 或 "yaml"。 "suffix" 是一个可选字符串，可用于确定首先按字母顺序应用哪些补丁。
--feature-gates string
	一组用来描述各种功能特性的键值（key=value）对。选项是：
IPv6DualStack=true|false (ALPHA - default=false)
-h, --help
	init 操作的帮助命令
--ignore-preflight-errors stringSlice
	错误将显示为警告的检查列表；例如：'IsPrivilegedUser,Swap'。取值为 'all' 时将忽略检查中的所有错误。
--image-repository string     默认值："k8s.gcr.io"
	选择用于拉取控制平面镜像的容器仓库
--kubernetes-version string     默认值："stable-1"
	为控制平面选择一个特定的 Kubernetes 版本。
--node-name string
	指定节点的名称。
--pod-network-cidr string
	指明 pod 网络可以使用的 IP 地址段。如果设置了这个参数，控制平面将会为每一个节点自动分配 CIDRs。
--service-cidr string     默认值："10.96.0.0/12"
	为服务的虚拟 IP 地址另外指定 IP 地址段
--service-dns-domain string     默认值："cluster.local"
	为服务另外指定域名，例如："myorg.internal"。
--skip-certificate-key-print
	不要打印用于加密控制平面证书的密钥。
--skip-phases stringSlice
	要跳过的阶段列表
--skip-token-print
	跳过打印 'kubeadm init' 生成的默认引导令牌。
--token string
	这个令牌用于建立控制平面节点与工作节点间的双向通信。格式为 [a-z0-9]{6}\.[a-z0-9]{16} - 示例：abcdef.0123456789abcdef
--token-ttl duration     默认值：24h0m0s
	令牌被自动删除之前的持续时间（例如 1 s，2 m，3 h）。如果设置为 '0'，则令牌将永不过期
--upload-certs
	将控制平面证书上传到 kubeadm-certs Secret。
```