# FT2000/4 & Kylin V10 Desktop 玩耍记录(3) —— Kubernetes安装

## 安装 Kubernetes 的准备工作

FT2000/4 的机器可以符合要求。

* 一个或者多个兼容 deb 或者 rpm 软件包的操作系统，比如 Ubuntu 或者 CentOS
* 每台机器 2 GB 以上的内存，内存不足时应用会受限制
* 主节点上 2 CPU 以上
* 集群里所有的机器有完全的网络连接，公有网络或者私有网络都可以

### 处理 Swap 分区

查看 Swap 分区

    root@phytium:~# swapon --show
    NAME           TYPE      SIZE USED PRIO
    /dev/nvme0n1p3 partition 7.5G   0B   -1

禁止 Swap 分区是 Kubernetes 的安装要求。您可以选择手工禁止 Swap, 或者删除它。删除 Swap 会导致系统启动较慢。

以下操作使用 root 账号操作。

	$ sudo -i

#### 禁用 Swap

    root@phytium:~# free -h
                  total        used        free      shared  buff/cache   available
    Mem:           7.7G        1.1G        5.3G         11M        1.2G        6.3G
    Swap:          7.5G          0B        7.5G

    root@phytium:~# swapoff -a
    root@phytium:~# free -h
                  total        used        free      shared  buff/cache   available
    Mem:           7.7G        273M        6.6G         17M        891M        7.2G
    Swap:            0B          0B          0B

#### 删除 Swap
    
    root@phytium:~# lsblk

    NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    nvme0n1     259:0    0 238.5G  0 disk 
    ├─nvme0n1p1 259:1    0   976M  0 part /boot
    ├─nvme0n1p2 259:2    0 229.5G  0 part /
    ├─nvme0n1p3 259:3    0   7.5G  0 part 
    └─nvme0n1p4 259:4    0   488M  0 part /boot/efi

    root@phytium:~# fdisk /dev/nvme0n1

    命令(输入 m 获取帮助)： d
    分区号 (1-4, default 4): 3

    Partition 3 has been deleted.

    命令(输入 m 获取帮助)： p
    Disk /dev/nvme0n1: 238.5 GiB, 256060514304 bytes, 500118192 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: gpt
    Disk identifier: 9E1FD0EF-9369-422D-87F8-8DEBFF83E728

    设备               Start    末尾    扇区   Size 类型
    /dev/nvme0n1p1      2048   2000895   1998848   976M Linux filesystem
    /dev/nvme0n1p2   2000896 483356671 481355776 229.5G Linux filesystem
    /dev/nvme0n1p4 499118080 500117503    999424   488M EFI System

    命令(输入 m 获取帮助)： w
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Re-reading the partition table failed.: 设备或资源忙

    The kernel still uses the old table. The new table will be used at the next reboot or after you run partprobe(8) or kpartx(8).

 修改 vm.swappiness 值。swapiness参数表明系统中内存与swap分区的数据交换次数。如果数值是0，那么内核会仅仅在必要的情况下才会把数据写入swap分区；如果值是100，内核会尽量多地把数据写入swap分区，使内存有更多的空闲空间。    
    
    root@phytium:~# cat /proc/sys/vm/swappiness
    10

    这个值设置为0会更好。
    
    root@phytium:~# vi /etc/sysctl.conf

    vm.swappiness=0

    root@phytium:~# reboot

### 修改 Docker 配置

    $ sudo vi /etc/docker/daemon.json
    
增加如下内容：

    {
      "registry-mirrors": [
        "https://dockerhub.azk8s.cn",
        "https://reg-mirror.qiniu.com",
        "https://quay-mirror.qiniu.com",
        "https://hub-mirror.c.163.com/"
      ],
      "exec-opts": [ "native.cgroupdriver=systemd" ]
    }

然后，重启 Docker

    $ sudo systemctl daemon-reload && sudo systemctl restart docker
    
再次检查 docker info，能够看到修改所对应的变化。 

    $ docker info
    ...
    Cgroup Driver: systemd
    ...
    Registry Mirrors:
      https://dockerhub.azk8s.cn/
      https://reg-mirror.qiniu.com/
      https://quay-mirror.qiniu.com/
      https://hub-mirror.c.163.com/
    ...

Docker 缺省的 `Cgroup Driver: cgroupfs`，修改为 `systemd` 是安装 Kubernetes 的要求。另外修改了 Registry Mirrors 以使用国内源。

### 设置国内镜像源

预先下载了 [https://packages.cloud.google.com/apt/doc/apt-key.gpg](https://packages.cloud.google.com/apt/doc/apt-key.gpg), 放置在此项目中。您可以直接使用。

    $ sudo cp apt-key.gpg /etc/apt/trusted.gpg.d/kubernetes.gpg

使用清华的镜像源。    
    
    $ echo "deb https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    $ sudo apt update

## Kubernetes 安装

以下操作使用 root 账号操作。

	$ sudo -i

### 寻找最近的 DockerHub 镜像

直接使用 Google 的 K8S Image 会被墙阻断，需要使用国内的 Docker Hub 镜像站下载所需的容器镜像。

检查最近更新的 Mirror，使用链接 [https://hub.docker.com/search?q=kube-apiserver-arm64&type=image](https://hub.docker.com/search?q=kube-apiserver-arm64&type=image) 。在结果页中，可以看到 kubesphere 有较近的更新。

检查当前 kubesphere 上最新的 K8S Image 的版本，使用链接 [https://hub.docker.com/r/kubesphere/kube-apiserver-arm64/tags?name=1.19](https://hub.docker.com/r/kubesphere/kube-apiserver-arm64/tags?name=1.19) ，name后的参数可以过滤所要检查的 Docker Image 版本。

### 安装

**20201015 说明** 目前 Arm64 Kubernetes 的 DockerHub Image 镜像，只能下载到 v1.19.0 版本的，所以我们只能使用 1.19.0 的 kubelet kubeadm kubectl。

如有必要，先删除其他版本

    root@phytium:~# apt remove -y --allow-change-held-packages kubelet kubeadm kubectl && apt autoremove -y
    
安装，首先检查可用的 kubeadm 版本号。

    root@phytium:~# sudo apt-cache madison kubeadm | grep 1.19
    kubeadm |  1.19.3-00 | https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial/main arm64 Packages
    kubeadm |  1.19.2-00 | https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial/main arm64 Packages
    kubeadm |  1.19.1-00 | https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial/main arm64 Packages
    kubeadm |  1.19.0-00 | https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial/main arm64 Packages

    root@phytium:~# apt install -y kubelet=1.19.0-00 kubeadm=1.19.0-00 kubectl=1.19.0-00
    root@phytium:~# apt-mark hold kubelet kubeadm kubectl
    
    root@phytium:~# kubeadm version
    kubeadm version: &version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.0", GitCommit:"e19964183377d0ec2052d1f1fa930c4d7575bd50", GitTreeState:"clean", BuildDate:"2020-08-26T14:28:32Z", GoVersion:"go1.15", Compiler:"gc", Platform:"linux/arm64"}

安装后处理：

    root@phytium:~# systemctl enable kubelet
    root@phytium:~# systemctl daemon-reload && systemctl restart kubelet
    root@phytium:~# reboot

### 查看并下载 kubeadm 镜像

    root@phytium:~# kubeadm config images list
    I1014 17:18:47.809173    3211 version.go:252] remote version is much newer: v1.20.0-alpha.2; falling back to: stable-1.19
    W1014 17:18:53.840981    3211 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
    k8s.gcr.io/kube-apiserver:v1.19.2
    k8s.gcr.io/kube-controller-manager:v1.19.2
    k8s.gcr.io/kube-scheduler:v1.19.2
    k8s.gcr.io/kube-proxy:v1.19.2
    k8s.gcr.io/pause:3.2
    k8s.gcr.io/etcd:3.4.13-0
    k8s.gcr.io/coredns:1.7.0
    
使用 DockerHub 镜像站下载所需的容器镜像，目前 Arm64 版本只能下载到 v1.19.0 的镜像。所以我们启动时必须使用 `--kubernetes-version=v1.19.0` 来指定版本。

    root@phytium:~# kubeadm config images list --kubernetes-version=v1.19.0
    W1015 17:26:46.871934   12909 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
    k8s.gcr.io/kube-apiserver:v1.19.0
    k8s.gcr.io/kube-controller-manager:v1.19.0
    k8s.gcr.io/kube-scheduler:v1.19.0
    k8s.gcr.io/kube-proxy:v1.19.0
    k8s.gcr.io/pause:3.2
    k8s.gcr.io/etcd:3.4.9-1
    k8s.gcr.io/coredns:1.7.0

退出 Root 用户，返回 Phytium 用户。执行 download_k8s.sh ， 在这个脚本里，对所需下载的 Docker Image 的版本进行了设定。

    $ cd FT2000PlayBook/script/
    $ ./download_k8s.sh

    $ docker images
    REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
    k8s.gcr.io/kube-proxy                v1.19.0             5335ed830782        7 weeks ago         116MB
    k8s.gcr.io/kube-apiserver            v1.19.0             ea03374905cc        7 weeks ago         110MB
    k8s.gcr.io/kube-controller-manager   v1.19.0             800e696d17cb        7 weeks ago         103MB
    k8s.gcr.io/kube-scheduler            v1.19.0             a94d6c76e8fe        7 weeks ago         42.6MB
    k8s.gcr.io/etcd                      3.4.9-1             70e8d49c8aee        3 months ago        312MB
    k8s.gcr.io/coredns                   1.7.0               db91994f4ee8        3 months ago        42.8MB
    k8s.gcr.io/pause                     3.2                 2a060e2e7101        8 months ago        484kB

## Kubernetes 开整

### kubeadm init
	
    $ sudo -i
    
如果有已经创建的不需要的集群，可以先Reset。    
    
    root@phytium:~# kubeadm reset
    [reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
    [reset] Are you sure you want to proceed? [y/N]: y
    [preflight] Running pre-flight checks
    W0814 15:07:07.097589    9030 removeetcdmember.go:79] [reset] No kubeadm config, using etcd pod spec to get data directory
    [reset] No etcd config found. Assuming external etcd
    [reset] Please, manually reset etcd to prevent further issues
    [reset] Stopping the kubelet service
    [reset] Unmounting mounted directories in "/var/lib/kubelet"
    [reset] Deleting contents of config directories: [/etc/kubernetes/manifests /etc/kubernetes/pki]
    [reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]
    [reset] Deleting contents of stateful directories: [/var/lib/kubelet /var/lib/dockershim /var/run/kubernetes /var/lib/cni]

    The reset process does not clean CNI configuration. To do so, you must remove /etc/cni/net.d

    The reset process does not reset or clean up iptables rules or IPVS tables.
    If you wish to reset iptables, you must do so manually by using the "iptables" command.

    If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
    to reset your system's IPVS tables.

    The reset process does not clean your kubeconfig files and you must remove them manually.
    Please, check the contents of the $HOME/.kube/config file.
    
使用 kubeadm init 创建新集群，命令如下，其中的 `--pod-network-cidr=10.244.0.0/16` 与后面应用的 kube-flannel.yml 有关： 
    
    root@phytium:~# kubeadm init --kubernetes-version=v1.19.0 --pod-network-cidr=10.244.0.0/16
    W1015 18:34:06.853761    8635 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
    [init] Using Kubernetes version: v1.19.0
    [preflight] Running pre-flight checks
        [WARNING SystemVerification]: missing optional cgroups: hugetlb
    [preflight] Pulling images required for setting up a Kubernetes cluster
    [preflight] This might take a minute or two, depending on the speed of your internet connection
    [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
    [certs] Using certificateDir folder "/etc/kubernetes/pki"
    [certs] Generating "ca" certificate and key
    [certs] Generating "apiserver" certificate and key
    [certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local phytium] and IPs [10.96.0.1 10.10.20.183]
    [certs] Generating "apiserver-kubelet-client" certificate and key
    [certs] Generating "front-proxy-ca" certificate and key
    [certs] Generating "front-proxy-client" certificate and key
    [certs] Generating "etcd/ca" certificate and key
    [certs] Generating "etcd/server" certificate and key
    [certs] etcd/server serving cert is signed for DNS names [localhost phytium] and IPs [10.10.20.183 127.0.0.1 ::1]
    [certs] Generating "etcd/peer" certificate and key
    [certs] etcd/peer serving cert is signed for DNS names [localhost phytium] and IPs [10.10.20.183 127.0.0.1 ::1]
    [certs] Generating "etcd/healthcheck-client" certificate and key
    [certs] Generating "apiserver-etcd-client" certificate and key
    [certs] Generating "sa" key and public key
    [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    [kubeconfig] Writing "admin.conf" kubeconfig file
    [kubeconfig] Writing "kubelet.conf" kubeconfig file
    [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    [kubeconfig] Writing "scheduler.conf" kubeconfig file
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Starting the kubelet
    [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    [control-plane] Creating static Pod manifest for "kube-apiserver"
    [control-plane] Creating static Pod manifest for "kube-controller-manager"
    [control-plane] Creating static Pod manifest for "kube-scheduler"
    [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
    [apiclient] All control plane components are healthy after 24.002608 seconds
    [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    [kubelet] Creating a ConfigMap "kubelet-config-1.19" in namespace kube-system with the configuration for the kubelets in the cluster
    [upload-certs] Skipping phase. Please see --upload-certs
    [mark-control-plane] Marking the node phytium as control-plane by adding the label "node-role.kubernetes.io/master=''"
    [mark-control-plane] Marking the node phytium as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
    [bootstrap-token] Using token: r8h8rd.tse8gstju3qg06sm
    [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
    [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
    [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
    [bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
    [bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
    [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
    [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
    [addons] Applied essential addon: CoreDNS
    [addons] Applied essential addon: kube-proxy

    Your Kubernetes control-plane has initialized successfully!

    To start using your cluster, you need to run the following as a regular user:

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    You should now deploy a pod network to the cluster.
    Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    https://kubernetes.io/docs/concepts/cluster-administration/addons/

    Then you can join any number of worker nodes by running the following on each as root:

    kubeadm join 10.10.20.183:6443 --token r8h8rd.tse8gstju3qg06sm \
        --discovery-token-ca-cert-hash sha256:f6ead374f0d3a810f2c5b42c9f82e995994091f2e89818a71341137c2118c969 
    root@phytium:~# 


### kubectl 

退出 Root 用户。

为 kubectl 配置参数。

    $ mkdir -p $HOME/.kube
    $ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    $ sudo chown $(id -u):$(id -g) $HOME/.kube/config

    $ kubectl version
    Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.0", GitCommit:"e19964183377d0ec2052d1f1fa930c4d7575bd50", GitTreeState:"clean", BuildDate:"2020-08-26T14:30:33Z", GoVersion:"go1.15", Compiler:"gc", Platform:"linux/arm64"}
    Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.0", GitCommit:"e19964183377d0ec2052d1f1fa930c4d7575bd50", GitTreeState:"clean", BuildDate:"2020-08-26T14:23:04Z", GoVersion:"go1.15", Compiler:"gc", Platform:"linux/arm64"}

    
检查 K8S 集群情况
    
    $ kubectl cluster-info
    Kubernetes master is running at https://10.10.20.183:6443
    KubeDNS is running at https://10.10.20.183:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

    $ kubectl get secrets
    NAME                  TYPE                                  DATA   AGE
    default-token-mr8z4   kubernetes.io/service-account-token   3      27m
    
### 激活网络 Fannal

    $ kubectl get node
    NAME      STATUS     ROLES    AGE   VERSION
    phytium   NotReady   master   10m   v1.19.0

此时 k8s node 状态为 NotReady，我们还需要应用 flannel，实现网络映射。

对于 Kubernetes v1.7+ 需要执行以下命令：
    
    $ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

此文件已经被提前下载，可以直接使用

    $ cd yaml/fannel
    $ kubectl apply -f kube-flannel.yml

    $ kubectl get pod -n kube-system
    NAME                              READY   STATUS             RESTARTS   AGE
    coredns-f9fd979d6-77vbh           0/1     CrashLoopBackOff   1          4m56s
    coredns-f9fd979d6-8kf6m           0/1     Error              2          4m56s
    etcd-phytium                      1/1     Running            0          5m
    kube-apiserver-phytium            1/1     Running            0          5m
    kube-controller-manager-phytium   1/1     Running            0          5m
    kube-flannel-ds-vvrgn             1/1     Running            0          25s
    kube-proxy-hbh2p                  1/1     Running            0          4m56s
    kube-scheduler-phytium            1/1     Running            0          5m

    $ kubectl get node
    NAME      STATUS   ROLES    AGE   VERSION
    phytium   Ready    master   87s   v1.19.0
