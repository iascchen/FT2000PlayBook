# FT2000/4 & Kylin V10 Desktop 玩耍记录(2) —— Docker & Kubernetes

## Docker 

Kylin 自己带了 Docker。您能够在 docker info 中看到 `Architecture: aarch64` 这样的信息。因为手里没有 Kylin 的安装盘，所以没敢将 Docker 升级到 19。

    $ docker --version
    Docker version 18.09.7, build 2d0083d
    
    $ docker info
    Containers: 2
     Running: 1
     Paused: 0
     Stopped: 1
    Images: 6
    Server Version: 18.09.7
    Storage Driver: overlay2
     Backing Filesystem: extfs
     Supports d_type: true
     Native Overlay Diff: true
    Logging Driver: json-file
    Cgroup Driver: cgroupfs
    Plugins:
     Volume: local
     Network: bridge host macvlan null overlay
     Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
    Swarm: inactive
    Runtimes: runc
    Default Runtime: runc
    Init Binary: docker-init
    containerd version: 
    runc version: N/A
    init version: v0.18.0 (expected: fec3683b971d9c3ef73f284f176672c44b448662)
    Security Options:
     seccomp
      Profile: default
    Kernel Version: 4.4.131-20200618.kylin.desktop.android-generic
    Operating System: Kylin V10
    OSType: linux
    Architecture: aarch64
    CPUs: 4
    Total Memory: 7.696GiB
    Name: phytium
    ID: PUQM:46AQ:BKON:FBXK:ORWR:UPEE:RH3I:JDJF:WS2E:S4KR:VJXK:T5N5
    Docker Root Dir: /var/lib/docker
    Debug Mode (client): false
    Debug Mode (server): false
    Registry: https://index.docker.io/v1/
    Labels:
    Experimental: false
    Insecure Registries:
     127.0.0.0/8
    Live Restore Enabled: false

    WARNING: No swap limit support
  
先将当前用户加入 docker 组，这样我们就不必每次使用 docker 时都必须加 sudo 了。

    $ sudo usermod -aG docker $USER
    
Kylin 使用 Docker 来运行 Android 虚拟机环境，使用《麒麟软件商店》中的 Android 应用后，能够看到对应的 Container。
 
    $ docker ps
    CONTAINER ID        IMAGE                     COMMAND             CREATED             STATUS              PORTS               NAMES
    09e76642c5e5        kydroid3:v3.0-200710.11   "/init.kydroid"     3 days ago          Up 3 seconds                            kydroid-1000-phytium

### 修改 Docker 配置

    $ sudo vi /etc/docker/daemon.json
    
增加如下内容：

    {
        "exec-opts":["native.cgroupdriver=systemd"],
        "registry-mirrors":["https://docker.mirrors.ustc.edu.cn"]
    }

然后，重启 Docker

    $ sudo systemctl daemon-reload && sudo systemctl restart docker
    
再次检查 docker info，能够看到修改所对应的变化。 

    $ docker info
    ...
    Cgroup Driver: systemd
    ...
    Registry Mirrors:
     https://docker.mirrors.ustc.edu.cn/
    ...

Docker 缺省的 `Cgroup Driver: cgroupfs`，修改为 `systemd` 是安装 Kubernetes 的要求。另外修改了 Registry Mirrors 以使用国内源。

## 安装 Kind 练习 Kubernetes




