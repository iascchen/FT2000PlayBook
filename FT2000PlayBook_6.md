# FT2000/4 & Kylin V10 Desktop 玩耍记录(6) —— VSCode or VSCodium

## 安装 Code-OSS

### 获得基础安装脚本

    wget https://packagecloud.io/install/repositories/swift-arm/vscode/script.deb.sh
    
修改 script.deb.sh 以支持 Kylin，在 89 行附近做如下修改。

      if [ -z "$dist" ]; then
        unknown_os
      fi
    
      if [ "${dist}" = "juniper" ]; then
        dist='xenial'
        os='ubuntu'
      fi
    
      # remove whitespace from OS and dist name
      os="${os// /}"
      dist="${dist// /}"

修改后的文件参见 [script.deb.sh](script/script.deb.sh)

### 安装

	$ sudo ./script.deb.sh
	$ sudo apt install code-oss
    
    $ code-oss --version
    1.39.2
    6ab598523be7a800d7f3eb4d92d7ab9a66069390
    arm64

### 使用 

	$ code-oss
    
## 安装 Codium

**注意** ： 安装后 Codium 的部分扩展使用不太正常。如：git、markdown。以下内容仅供参考

VS Code 1.50 稳定版刚发布，已经提供 Arm64 的版本。VSCodium 是 VSCode 的 Clean 版本。

在您安装 VS Code的时候，会看到这样一个熟悉的声明：

> VS Code 收集使用数据并将其发送给 Microsoft 以帮助改进我们的产品和服务。阅读我们的隐私声明以了解更多信息。

也就是说，在微软官网上下载的VS Code包含了Trakcer和远程报告功能，它会把你的文件数、文件大小、功能使用次数等统计数据发送给微软。

VS Codium 剔除了可能侵犯你隐私的功能。VS Codium 的开发者竭尽全力禁用了所有难以寻找的遥测选项，除非你自行编译，否则这已经是你能找到的最干净的 VS Code 版本了。

### 下载安装 VSCodium

VS Codium 的 Github 地址是 [https://github.com/VSCodium/vscodium](https://github.com/VSCodium/vscodium)

    wget https://github.com/VSCodium/vscodium/releases/download/1.50.0/codium_1.50.0-1602204130_arm64.deb
    sudo dpkg -i codium_1.50.0-1602204130_arm64.deb

### 使用 

运行直接执行以下命令即可：

    $ codium --version
    1.50.0
    93c2f0fbf16c5a4b10e4d5f89737d9c2c25488a3
    arm64
    
	$ codium
