# FT2000/4 & Kylin V10 Desktop 玩耍记录(3) —— Kubernetes 安装

## 安装 Kubernetes 的准备工作

FT2000/4 的机器可以符合要求。

-   一个或者多个兼容 deb 或者 rpm 软件包的操作系统，比如 Ubuntu 或者 CentOS
-   每台机器 2 GB 以上的内存，内存不足时应用会受限制
-   主节点上 2 CPU 以上
-   集群里所有的机器有完全的网络连接，公有网络或者私有网络都可以

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

修改 vm.swappiness 值。swapiness 参数表明系统中内存与 swap 分区的数据交换次数。如果数值是 0，那么内核会仅仅在必要的情况下才会把数据写入 swap 分区；如果值是 100，内核会尽量多地把数据写入 swap 分区，使内存有更多的空闲空间。

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
            "https://hub-mirror.c.163.com/",
            "https://ustc-edu-cn.mirror.aliyuncs.com/"
        ],
        "exec-opts": [ "native.cgroupdriver=cgroupfs" ]
    }

然后，重启 Docker

    $ sudo systemctl daemon-reload && sudo systemctl restart docker

再次检查 docker info，能够看到修改所对应的变化。

    $ docker info
    ...
    Cgroup Driver: systemd
    ...
    Registry Mirrors:
      https://hub-mirror.c.163.com/
      https://ustc-edu-cn.mirror.aliyuncs.com/
    ...

Kubernetes 建议 Docker 设置为 `Cgroup Driver: cgroupfs`，如果这个值您设置过，请改成 `cgroupfs`，这个也是 Docker 的缺省值。另外修改了 Registry Mirrors 以使用国内源。

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

检查最近更新的 Mirror，使用链接 [https://hub.docker.com/search?q=kube-apiserver-arm64&type=image&sort=updated_at&order=desc](https://hub.docker.com/search?q=kube-apiserver-arm64&type=image&sort=updated_at&order=desc) 。在结果页中，可以看到 kubesphere 有较近的更新。

检查当前 kubesphere 上最新的 K8S Image 的版本，使用链接 [https://hub.docker.com/r/kubesphere/kube-apiserver-arm64/tags?name=1.19](https://hub.docker.com/r/kubesphere/kube-apiserver-arm64/tags?name=1.19) ，name 后的参数可以过滤所要检查的 Docker Image 版本。

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

退出 Root 用户，返回 Phytium 用户。执行 download_k8s_1.19.0.sh ， 在这个脚本里，对所需下载的 Docker Image 的版本进行了设定。

    $ cd FT2000PlayBook/script/
    $ ./download_k8s_1.19.0.sh

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

如果有已经创建的不需要的集群，可以先 Reset。

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

    kubeadm join 10.10.20.183:6443 --token i3txr0.i4bgsrh9zh9iuruo \
        --discovery-token-ca-cert-hash sha256:0ba5e35fcf7a7f9d6ae7b468e8a320f73f3f2909abea99a01eff198aa717c662
    root@phytium:~#

### kubectl

退出 Root 用户。

为 kubectl 配置参数。

    $ mkdir -p $HOME/kube
    $ sudo cp -i /etc/kubernetes/admin.conf $HOME/kube/config
    $ sudo chown $(id -u):$(id -g) $HOME/kube/config
    $ export KUBECONFIG=$HOME/kube/admin.conf

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

### 映射 Fannal 网络

    $ kubectl get node
    NAME      STATUS     ROLES    AGE   VERSION
    phytium   NotReady   master   10m   v1.19.0

此时 k8s node 状态为 NotReady，我们还需要映射 flannel 网络。

对于 Kubernetes v1.7+ 需要执行以下命令：

    $ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

此文件已经被提前下载，可以直接使用

    $ cd k8s/flannel
    $ kubectl apply -f kube-flannel.yml

    $ kubectl get pod -n kube-system
    NAME                              READY   STATUS             RESTARTS   AGE
    coredns-f9fd979d6-tchqk           0/1     CrashLoopBackOff   2          5m16s
    coredns-f9fd979d6-zt4rd           0/1     CrashLoopBackOff   2          5m16s
    etcd-phytium                      1/1     Running            0          5m
    kube-apiserver-phytium            1/1     Running            0          5m
    kube-controller-manager-phytium   1/1     Running            0          5m
    kube-flannel-ds-vvrgn             1/1     Running            0          25s
    kube-proxy-hbh2p                  1/1     Running            0          4m56s
    kube-scheduler-phytium            1/1     Running            0          5m

    $ kubectl get node
    NAME      STATUS   ROLES    AGE   VERSION
    phytium   Ready    master   87s   v1.19.0

有时您可能需要了解，如何卸载 flannel 网络：

    # 第一步，在master节点删除flannel
    $ kubectl delete -f kube-flannel.yml

    # 第二步，在node节点清理flannel网络留下的文件
    $ sudo -i

    root@phytium:~# ifconfig cni0 down
    root@phytium:~# ip link delete cni0
    root@phytium:~# ifconfig flannel.1 down
    root@phytium:~# ip link delete flannel.1
    root@phytium:~# rm -rf /var/lib/cni/
    root@phytium:~# rm -f /etc/cni/net.d/*

    # 注：执行完上面的操作，重启kubelet
    root@phytium:~# systemctl daemon-reload && systemctl restart kubelet

### 处理 CoreDNS 问题

接下来，处理 coredns CrashLoopBackOff 的问题。

    $ kubectl get pod -n kube-system
    NAME                              READY   STATUS             RESTARTS   AGE
    coredns-f9fd979d6-tchqk           0/1     CrashLoopBackOff   2          5m16s
    coredns-f9fd979d6-zt4rd           0/1     CrashLoopBackOff   2          5m16s

查看详细信息

    $ kubectl describe -n kube-system pod/coredns-f9fd979d6-tchqk
    Name:                 coredns-f9fd979d6-tchqk
    Namespace:            kube-system
    Priority:             2000000000
    Priority Class Name:  system-cluster-critical
    Node:                 phytium/10.10.20.183
    Start Time:           Fri, 16 Oct 2020 08:42:42 +0800
    Labels:               k8s-app=kube-dns
                        pod-template-hash=f9fd979d6
    Annotations:          <none>
    Status:               Running
    IP:                   10.244.0.2
    IPs:
    IP:           10.244.0.2
    Controlled By:  ReplicaSet/coredns-f9fd979d6
    Containers:
    coredns:
        Container ID:  docker://e8b231891a5f5b646a5afc0670ab96f01e0cfc61ae85637f817c4770eb60659a
        Image:         k8s.gcr.io/coredns:1.7.0
        Image ID:      docker://sha256:db91994f4ee8f894a1e8a6c1a76f615da8fc3c019300a3686291ce6fcbc57895
        Ports:         53/UDP, 53/TCP, 9153/TCP
        Host Ports:    0/UDP, 0/TCP, 0/TCP
        Args:
        -conf
        /etc/coredns/Corefile
        State:          Waiting
        Reason:       CrashLoopBackOff
        Last State:     Terminated
        Reason:       Error
        Exit Code:    1
        Started:      Fri, 16 Oct 2020 09:39:44 +0800
        Finished:     Fri, 16 Oct 2020 09:39:44 +0800
        Ready:          False
        Restart Count:  16
        Limits:
        memory:  170Mi
        Requests:
        cpu:        100m
        memory:     70Mi
        Liveness:     http-get http://:8080/health delay=60s timeout=5s period=10s #success=1 #failure=5
        Readiness:    http-get http://:8181/ready delay=0s timeout=1s period=10s #success=1 #failure=3
        Environment:  <none>
        Mounts:
        /etc/coredns from config-volume (ro)
        /var/run/secrets/kubernetes.io/serviceaccount from coredns-token-np6cb (ro)
    Conditions:
    Type              Status
    Initialized       True
    Ready             False
    ContainersReady   False
    PodScheduled      True
    Volumes:
    config-volume:
        Type:      ConfigMap (a volume populated by a ConfigMap)
        Name:      coredns
        Optional:  false
    coredns-token-np6cb:
        Type:        Secret (a volume populated by a Secret)
        SecretName:  coredns-token-np6cb
        Optional:    false
    QoS Class:       Burstable
    Node-Selectors:  kubernetes.io/os=linux
    Tolerations:     CriticalAddonsOnly op=Exists
                    node-role.kubernetes.io/master:NoSchedule
                    node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                    node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
    Events:
    Type     Reason            Age                    From               Message
    ----     ------            ----                   ----               -------
    Warning  FailedScheduling  59m (x6 over 63m)      default-scheduler  0/1 nodes are available: 1 node(s) had taint {node.kubernetes.io/not-ready: }, that the pod didn't tolerate.
    Normal   Scheduled         59m                    default-scheduler  Successfully assigned kube-system/coredns-f9fd979d6-tchqk to phytium
    Normal   Pulled            57m (x5 over 59m)      kubelet, phytium   Container image "k8s.gcr.io/coredns:1.7.0" already present on machine
    Normal   Created           57m (x5 over 59m)      kubelet, phytium   Created container coredns
    Normal   Started           57m (x5 over 59m)      kubelet, phytium   Started container coredns
    Warning  BackOff           4m12s (x265 over 59m)  kubelet, phytium   Back-off restarting failed container

此问题原因是当部署在 Kubernetes 中的 CoreDNS Pod 检测到循环时，CoreDNS Pod 将开始“CrashLoopBackOff”。这是因为每当 CoreDNS 检测到循环并退出时，Kubernetes 将尝试重新启动 Pod。

使用 `network-admin` 工具，将 DNS 服务器设置为不是 `127.0.0.1` 的 DNS。

    $ sudo -i
    root@phytium:~# systemctl daemon-reload && systemctl restart docker && systemctl restart kubelet
    root@phytium:~# exit

    $ kubectl get pod -n kube-system
    NAME                              READY   STATUS    RESTARTS   AGE
    coredns-f9fd979d6-tchqk           1/1     Running   19         81m
    coredns-f9fd979d6-zt4rd           1/1     Running   19         81m
    etcd-phytium                      1/1     Running   1          81m
    kube-apiserver-phytium            1/1     Running   1          81m
    kube-controller-manager-phytium   1/1     Running   1          81m
    kube-flannel-ds-74jxr             1/1     Running   1          77m
    kube-proxy-vv4cz                  1/1     Running   1          81m
    kube-scheduler-phytium            1/1     Running   2          81m
