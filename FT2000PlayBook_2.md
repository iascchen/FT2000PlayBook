# FT2000/4 & Kylin V10 Desktop 玩耍记录(2) —— Docker

## Kylin 预装的 Docker 18

Kylin 自己带了 Docker。您能够在 docker info 中看到 `Architecture: aarch64` 这样的信息。因为手里没有 Kylin 的安装盘，所以没敢将 Docker 升级到 19。

    $ docker --version
    Docker version 18.09.7, build 2d0083d
    
    $ docker info | grep Architecture
    Architecture: aarch64
  
先将当前用户加入 docker 组，这样我们就不必每次使用 docker 时都必须加 sudo 了。

    $ sudo usermod -aG docker $USER
    
Kylin 使用 Docker 来运行 Android 虚拟机环境，使用《麒麟软件商店》中的 Android 应用后，能够看到对应的 Container。
 
    $ docker ps
    CONTAINER ID        IMAGE                     COMMAND             CREATED             STATUS              PORTS               NAMES
    09e76642c5e5        kydroid3:v3.0-200710.11   "/init.kydroid"     3 days ago          Up 3 seconds                            kydroid-1000-phytium

## 手欠——升级到 Docker 19

**以下内容请谨慎测试** 会让《麒麟软件商店》中的 Android 虚拟环境起不来。

先删除老版本。

	$ sudo apt-get remove docker docker-engine docker.io containerd runc
    
准备安装所需的软件。

	$ sudo apt-get update
	$ sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	
	$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	$ sudo apt-key fingerprint 0EBFCD88
	
由于 Kylin 将版本名称修改成了 juniper，所以需要修改一下，才能设置好正确的 Docker Apt 源。

    $ lsb_release -cs
    juniper

使用以下命令增加 Docker Apt 源。

	$ echo "deb [arch=arm64] https://download.docker.com/linux/ubuntu xenial stable" | sudo tee /etc/apt/sources.list.d/docker.list
    $ sudo apt-get update
    
安装 Docker-ce。   
    
    $ sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	
    $ docker --version
	Docker version 19.03.12, build 48a6621
    
    $ docker --version
    Docker version 19.03.12, build 48a6621
    phytium@phytium:~$ docker info
    Client:
     Debug Mode: false

    Server:
     Containers: 2
      Running: 0
      Paused: 0
      Stopped: 2
     Images: 6
     Server Version: 19.03.12
     Storage Driver: overlay2
      Backing Filesystem: extfs
      Supports d_type: true
      Native Overlay Diff: true
     Logging Driver: json-file
     Cgroup Driver: systemd
     Plugins:
      Volume: local
      Network: bridge host ipvlan macvlan null overlay
      Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
     Swarm: inactive
     Runtimes: runc
     Default Runtime: runc
     Init Binary: docker-init
     containerd version: 7ad184331fa3e55e52b890ea95e65ba581ae3429
     runc version: dc9208a3303feef5b3839f4323d9beb36df0a9dd
     init version: fec3683
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
     Debug Mode: false
     Registry: https://index.docker.io/v1/
     Labels:
     Experimental: false
     Insecure Registries:
      127.0.0.0/8
     Registry Mirrors:
      https://docker.mirrors.ustc.edu.cn/
     Live Restore Enabled: false

    WARNING: No swap limit support

安装后处理：

	sudo usermod -aG docker $USER
    
	sudo systemctl enable docker
	sudo systemctl daemon-reload && sudo systemctl restart docker
	sudo reboot

## 修改 Docker 配置

    $ sudo vi /etc/docker/daemon.json
    
增加如下内容：

    {
        "exec-opts":["native.cgroupdriver=systemd"],
        "registry-mirrors":["https://hub-mirror.c.163.com/"]
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
    ...

Docker 缺省的 `Cgroup Driver: cgroupfs`，修改为 `systemd` 是安装 Kubernetes 的要求。另外修改了 Registry Mirrors 以使用国内源。