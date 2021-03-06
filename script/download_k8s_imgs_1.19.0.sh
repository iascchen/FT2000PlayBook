MY_REGISTRY=kubesphere
MY_REGISTRY2=mirrorgcrio

K8S_VERSION=1.19.0
ETCD_VERSION=3.4.9-1
PAUSE_VERSION=3.2
COREDNS_VERSION=1.7.0

## Install K8S
apt install -y kubelet=${K8S_VERSION}-00 kubeadm=${K8S_VERSION}-00 kubectl=${K8S_VERSION}-00

echo ""
echo "=========================================================="
echo "Pull Kubernetes for arm v${K8S_VERSION} Images from ${MY_REGISTRY} ......"
echo "=========================================================="
echo ""

## 拉取镜像
docker pull ${MY_REGISTRY}/kube-apiserver-arm64:v${K8S_VERSION}
docker pull ${MY_REGISTRY}/kube-controller-manager-arm64:v${K8S_VERSION}
docker pull ${MY_REGISTRY}/kube-scheduler-arm64:v${K8S_VERSION}
docker pull ${MY_REGISTRY}/kube-proxy-arm64:v${K8S_VERSION}
docker pull ${MY_REGISTRY}/pause-arm64:${PAUSE_VERSION}

# 注意，coredns的仓库可以直接使用官方的：
docker pull ${MY_REGISTRY2}/etcd-arm64:${ETCD_VERSION}
docker pull coredns/coredns:${COREDNS_VERSION}

## 添加Tag
docker tag ${MY_REGISTRY}/kube-apiserver-arm64:v${K8S_VERSION} k8s.gcr.io/kube-apiserver:v${K8S_VERSION}
docker tag ${MY_REGISTRY}/kube-scheduler-arm64:v${K8S_VERSION} k8s.gcr.io/kube-scheduler:v${K8S_VERSION}
docker tag ${MY_REGISTRY}/kube-controller-manager-arm64:v${K8S_VERSION} k8s.gcr.io/kube-controller-manager:v${K8S_VERSION}
docker tag ${MY_REGISTRY}/kube-proxy-arm64:v${K8S_VERSION} k8s.gcr.io/kube-proxy:v${K8S_VERSION}
docker tag ${MY_REGISTRY}/pause-arm64:${PAUSE_VERSION} k8s.gcr.io/pause:${PAUSE_VERSION}

#etcd-arm64 & codredns也要改tag:
docker tag ${MY_REGISTRY2}/etcd-arm64:${ETCD_VERSION} k8s.gcr.io/etcd:${ETCD_VERSION}
docker tag coredns/coredns:${COREDNS_VERSION} k8s.gcr.io/coredns:${COREDNS_VERSION}

docker rmi ${MY_REGISTRY}/kube-apiserver-arm64:v${K8S_VERSION}
docker rmi ${MY_REGISTRY}/kube-controller-manager-arm64:v${K8S_VERSION}
docker rmi ${MY_REGISTRY}/kube-scheduler-arm64:v${K8S_VERSION}
docker rmi ${MY_REGISTRY}/kube-proxy-arm64:v${K8S_VERSION}
docker rmi ${MY_REGISTRY}/pause-arm64:${PAUSE_VERSION}

docker rmi ${MY_REGISTRY2}/etcd-arm64:${ETCD_VERSION}
docker rmi coredns/coredns:${COREDNS_VERSION}

echo ""
echo "=========================================================="
echo "Pull Kubernetes for arm v${K8S_VERSION} Images FINISHED."
echo "=========================================================="
echo ""
