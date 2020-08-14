# FT2000/4 & Kylin V10 Desktop 玩耍记录(6) —— VSCode

## 获得基础安装脚本

    wget https://packagecloud.io/install/repositories/swift-arm/vscode/script.deb.sh
    
修改 script.deb.sh 以支持 Kylin。修改后的文件参见 [script.deb.sh](script.deb.sh)

## 安装

	$ sudo ./script.deb.sh
	$ sudo apt install code-oss
    
    $ code-oss --version
    1.39.2
    6ab598523be7a800d7f3eb4d92d7ab9a66069390
    arm64

## 使用 

	$ code-oss
    
    