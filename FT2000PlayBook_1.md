# FT2000/4 & Kylin V10 Desktop 玩耍记录(1)——APT & NodeJs

## 检查系统情况


    $ cat /proc/version 
    Linux version 4.4.131-20200618.kylin.desktop.android-generic (YHKYLIN-OS@Kylin) (gcc version 5.5.0 20171010 (Ubuntu/Linaro 5.5.0-12ubuntu1~16.04) ) #kylin SMP Thu Jun 18 13:23:13 CST 2020

    $ uname -a
    Linux phytium 4.4.131-20200618.kylin.desktop.android-generic #kylin SMP Thu Jun 18 13:23:13 CST 2020 aarch64 aarch64 aarch64 GNU/Linux

此处需要注意 `Ubuntu/Linaro 5.5.0-12ubuntu1~16.04` 和 `aarch64` 。在后面我们会用得到这两个值。

## 修改 APT 镜像源

首先使用 Kylin 缺省的源，进行更新和安装。

    $ sudo apt update
    $ sudo apt upgrade
    $ sudo apt install apt-transport-https
    
从清华的 TUNA 能够找到可以使用的镜像说明 [https://mirror.tuna.tsinghua.edu.cn/help/ubuntu/](https://mirror.tuna.tsinghua.edu.cn/help/ubuntu/) 。我们需要选择 `16.04LTS` 相关的镜像源进行修改。由于 FT2000/4 是 ARM64v8 的架构，所以需要使用 ubuntu-ports 下的包。考虑到可能有些包以后需要做交叉编译，所以把 deb-src 打开。

使用以下命令修改 `sudo vi /etc/apt/sources.list`，在文件末尾增加以下内容

    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial main restricted universe multiverse
    deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-updates main restricted universe multiverse
    deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-updates main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-backports main restricted universe multiverse
    deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-backports main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-security main restricted universe multiverse
    deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-security main restricted universe multiverse

修改完成后，需要更新一下 apt 源

    $ sudo apt update
    
## 安装 Markdown 编辑器

Kylin 上没有 Markdown 编辑器。在网上也能够找到很多支持  Ubuntu 的 Markdown Editor 下载和安装，只不过大多只提供 X86-64 的版本。Arm64 的版本只能想办法自己搞！尝试了众多开源项目，最后比较理想的工具是 Zettlr。

### 安装 nvm & nodejs

官方安装指令如下。

    $ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

由于 raw.githubusercontent.com 被墙。我们只能从 git clone 后再安装。

    $ git clone https://github.com/nvm-sh/nvm.git
    $ cd nvm
    $ ./install.sh
    
安装之后。可以使用以下命令：

    $ nvm --version
    0.35.3
  
    $ nvm install 14
    
    $ node --version
    v14.8.0
    $ npm --version
    6.14.7

使用国内的 npm 源以提升安装效率。

    $ npm config set registry https://registry.npm.taobao.org
    $ npm config set ELECTRON_MIRROR=https://npm.taobao.org/mirrors/electron/
    
    $ npm config list
    ; cli configs
    metrics-registry = "http://registry.npm.taobao.org/"
    scope = ""
    user-agent = "npm/6.14.7 node/v14.8.0 linux arm64"

    ; userconfig /home/phytium/.npmrc
    ELECTRON_MIRROR = "https://npm.taobao.org/mirrors/electron/"
    registry = "http://registry.npm.taobao.org/"

    ; node bin location = /home/phytium/.nvm/versions/node/v14.8.0/bin/node
    ; cwd = /home/phytium/workspaces
    ; HOME = /home/phytium
    ; "npm config ls -l" to show all defaults.

### 安装 yarn

    $ sudo apt install curl
    $ curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    
    $ echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

    $ sudo apt update
    $ sudo apt install yarn
    
    $ yarn --version
    1.22.4


### 安装Zettlr

尝试了众多开源项目，最后比较理想的工具是 Zettlr。目前还在很活跃的更新。

    $ git clone https://github.com/Zettlr/Zettlr.git
    $ cd Zettlr
    $ yarn install
    $ cd source
    $ yarn install
    
运行

    $ yarn start
    
哈哈哈，当前这个文件就是用 Zettlr 编辑的。
