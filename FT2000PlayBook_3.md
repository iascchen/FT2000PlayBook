# FT2000/4 & Kylin V10 Desktop 玩耍记录(3) —— Kubernetes

## 安装 kind 练习 Kubernetes 单机集群

### 安装 kind

	$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-linux-arm64
	$ chmod +x ./kind
	$ sudo mv ./kind /usr/local/
    
    $ kind --version
	kind version 0.8.1

### 安装 kubectl 

kind does not require kubectl, but you will not be able to perform some of the examples in our docs without it. 

	curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/arm64/kubectl
	
	sudo mv ./kubectl /usr/local/bin
	
	kubectl version
	
	kubectl get node
    
首先导入 gpg key：

    $ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    
    
