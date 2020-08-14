MY_REGISTRY=mirrorgcrio
K8S_VERSION=1.18.6

echo ""
echo "=========================================================="
echo "Pull Kubernetes for arm v${K8S_VERSION} Images from docker.io ......"
echo "=========================================================="
echo ""

## 拉取镜像
docker pull ${MY_REGISTRY}/kube-apiserver-arm64:v${K8S_VERSION}
docker pull ${MY_REGISTRY}/kube-controller-manager-arm64:v${K8S_VERSION}
docker pull ${MY_REGISTRY}/kube-scheduler-arm64:v${K8S_VERSION}
docker pull ${MY_REGISTRY}/kube-proxy-arm64:v${K8S_VERSION}
docker pull ${MY_REGISTRY}/etcd-arm64:3.4.3-0
docker pull ${MY_REGISTRY}/pause-arm64:3.2

# 注意，coredns的仓库可以直接使用官方的：
docker pull coredns/coredns:1.6.7

## 添加Tag
docker tag ${MY_REGISTRY}/kube-apiserver-arm64:v${K8S_VERSION} k8s.gcr.io/kube-apiserver:v${K8S_VERSION}
docker tag ${MY_REGISTRY}/kube-scheduler-arm64:v${K8S_VERSION} k8s.gcr.io/kube-scheduler:v${K8S_VERSION}
docker tag ${MY_REGISTRY}/kube-controller-manager-arm64:v${K8S_VERSION} k8s.gcr.io/kube-controller-manager:v${K8S_VERSION}
docker tag ${MY_REGISTRY}/kube-proxy-arm64:v${K8S_VERSION} k8s.gcr.io/kube-proxy:v${K8S_VERSION}
docker tag ${MY_REGISTRY}/etcd-arm64:3.4.3-0 k8s.gcr.io/etcd:3.4.3-0
docker tag ${MY_REGISTRY}/pause-arm64:3.2 k8s.gcr.io/pause:3.2

#codredns也要改tag:
docker tag coredns/coredns:1.6.7 k8s.gcr.io/coredns:1.6.7

echo ""
echo "=========================================================="
echo "Pull Kubernetes for arm v${K8S_VERSION} Images FINISHED."
echo "into docker.io/mirrorgcrio, "
echo " by openthings@https://my.oschina.net/u/2306127."
echo "=========================================================="

echo ""
