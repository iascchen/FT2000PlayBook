# FT2000/4 & Kylin V10 Desktop 玩耍记录(6) —— VSCodium

VS Code 1.50 稳定版刚发布，已经提供 Arm64 的版本。VSCodium 是 VSCode 的 Clean 版本。

在您安装 VS Code的时候，会看到这样一个熟悉的声明：

> VS Code 收集使用数据并将其发送给 Microsoft 以帮助改进我们的产品和服务。阅读我们的隐私声明以了解更多信息。

也就是说，在微软官网上下载的VS Code包含了Trakcer和远程报告功能，它会把你的文件数、文件大小、功能使用次数等统计数据发送给微软。

VS Codium 剔除了可能侵犯你隐私的功能。VS Codium 的开发者竭尽全力禁用了所有难以寻找的遥测选项，除非你自行编译，否则这已经是你能找到的最干净的 VS Code 版本了。

## 下载安装 VSCodium

VS Codium 的 Github 地址是 [https://github.com/VSCodium/vscodium](https://github.com/VSCodium/vscodium)

安装脚本

    sudo apt update
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/etc/apt/trusted.gpg.d/vscodium.gpg
    echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee --append /etc/apt/sources.list.d/vscodium.list
    sudo apt update && sudo apt install codium

## 使用 

运行直接执行以下命令即可：

    $ codium --version
    1.50.0
    93c2f0fbf16c5a4b10e4d5f89737d9c2c25488a3
    arm64
    
	$ codium
