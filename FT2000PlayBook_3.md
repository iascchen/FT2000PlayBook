# FT2000/4 & Kylin V10 Desktop 玩耍记录(3) —— Kubernetes

## Kubernetes 的需要

FT2000/4 的机器可以符合要求。

* 一个或者多个兼容 deb 或者 rpm 软件包的操作系统，比如 Ubuntu 或者 CentOS
* 每台机器 2 GB 以上的内存，内存不足时应用会受限制
* 主节点上 2 CPU 以上
* 集群里所有的机器有完全的网络连接，公有网络或者私有网络都可以

## 安装 kubeadm、kubelet 和 kubectl

预先下载了 [https://packages.cloud.google.com/apt/doc/apt-key.gpg](https://packages.cloud.google.com/apt/doc/apt-key.gpg), 放置在此项目中。您可以直接使用。

    $ sudo apt-key add apt-key.gpg
    
使用清华的镜像源。    
    
    $ echo "deb https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    $ sudo apt-get update
    
安装

    $ sudo apt-get install -y kubelet kubeadm kubectl
    $ sudo apt-mark hold kubelet kubeadm kubectl
    
    $ kubectl version
    $ kubeadm version
    
    $ kubectl get node
    
安装后处理：

	$ systemctl enable kubelet
    $ sudo systemctl daemon-reload && sudo systemctl restart kubelet
    $ sudo reboot

## 安装 kind 练习 Kubernetes 单机集群

### 安装 kind

	$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-linux-arm64
	$ chmod +x ./kind
	$ sudo mv ./kind /usr/local/
    
    $ kind --version
	kind version 0.8.1
    
    // 查看kubeadm镜像
    $ kubeadm config images list
    
    / 执行如下脚本（没有翻墙的同学只能通过阿里云镜像或者其他镜像）
$ for i in \`kubeadm config images list\`; do imageName=${i#k8s.gcr.io/}
docker pull registry.aliyuncs.com/google_containers/$imageName
docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
docker rmi registry.aliyuncs.com/google_containers/$imageName
done;
