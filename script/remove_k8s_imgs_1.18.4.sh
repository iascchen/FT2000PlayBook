TARGET_REGISTRY=k8s.gcr.io

K8S_VERSION=1.18.4
ETCD_VERSION=3.4.3-0
PAUSE_VERSION=3.2
COREDNS_VERSION=1.6.7

echo ""
echo "=========================================================="
echo "Remove Local ${TARGET_REGISTRY} Kubernetes for arm v${K8S_VERSION} Images ......"
echo "=========================================================="
echo ""

docker rmi ${TARGET_REGISTRY}/kube-apiserver:v${K8S_VERSION}
docker rmi ${TARGET_REGISTRY}/kube-controller-manager:v${K8S_VERSION}
docker rmi ${TARGET_REGISTRY}/kube-scheduler:v${K8S_VERSION}
docker rmi ${TARGET_REGISTRY}/kube-proxy:v${K8S_VERSION}
docker rmi ${TARGET_REGISTRY}/pause:${PAUSE_VERSION}
docker rmi ${TARGET_REGISTRY}/etcd:${ETCD_VERSION}
docker rmi ${TARGET_REGISTRY}/coredns:${COREDNS_VERSION}

echo ""
echo "=========================================================="
echo "Remove Kubernetes for arm v${K8S_VERSION} Images FINISHED."
echo "=========================================================="

echo ""
