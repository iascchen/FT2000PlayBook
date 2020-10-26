TARGET_REGISTRY=k8s.gcr.io

K8S_VERSION=1.19.0
ETCD_VERSION=3.4.9-1
PAUSE_VERSION=3.2
COREDNS_VERSION=1.7.0

echo ""
echo "=========================================================="
echo "Remove ${TARGET_REGISTRY} Kubernetes for arm v${K8S_VERSION} Images ......"
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
