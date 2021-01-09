# FT2000/4 & Kylin V10 Desktop 玩耍记录(6) —— VSCode

## VSCode 微软官方版本
### 安装

使用此链接下载最新的 VSCode Arm64版本 [https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64](https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64) 

    $ sudo dpkg -i code_1.52.1-1608136325_arm64.deb

### 使用 

    $ code --version
    1.52.1
    ea3859d4ba2f3e577a159bc91e3074c5d85c0523
    arm64

    $ code

### 问题处理

直接安装的 VSCode 在 Kylin V10 上运行有些问题，主要表现是：需要使用系统内工具的，都没有效果。例如：没法打开 Git，并且 Markdown 支持窗口打不开。

解决和分析的过程如下：

1. 鼠标右键点击任务条中的 VSCode 的图标，选择“属性”菜单。将“启动器属性”对话框中的“类型：”属性，从“应用程序”更改为“终端应用程序”。然后关闭对话框。
2. 鼠标左键单击 VSCode 图标，打开程序。你可以看到程序运行的日志窗口。
3. 进行操作，例如点击 Git 导航按钮，能够在日志中看到类似下面的错误输出。

        警告: "sandbox"不在已知选项列表中，但仍传递给 Electron/Chromium。
        Error: /usr/lib/aarch64-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.22' not found (required by /usr/share/code/resources/app/node_modules.asar.unpacked/spdlog/build/Release/spdlog.node)

问题找到了！Kylin自带的 libstdc++.so.6 版本太低，不满足 VSCode 需要。

让我们在系统中找找 libstdc++.so.6，看看都是什么版本的。

    $ sudo find / -name "libstdc++.so.6*"

返回的结果输出类似于下面的示例：

    ...
    /home/phytium/miniforge3/lib/libstdc++.so.6.0.28
    /home/phytium/miniforge3/lib/libstdc++.so.6
    /usr/lib/aarch64-linux-gnu/libstdc++.so.6.0.21
    /usr/lib/aarch64-linux-gnu/libstdc++.so.6
    /usr/share/gdb/auto-load/usr/lib/aarch64-linux-gnu/libstdc++.so.6.0.21-gdb.py
    /opt/client/windows/libs/libstdc++.so.6
    /opt/kingsoft/wps-office/office6/libstdc++.so.6.0.21
    /opt/kingsoft/wps-office/office6/libstdc++.so.6
    ...

让我们来看看被 VSCode 调用的 libstdc++

    $ strings /usr/lib/aarch64-linux-gnu/libstdc++.so.6 | grep GLIBCXX

    ...
    GLIBCXX_3.4.18
    GLIBCXX_3.4.19
    GLIBCXX_3.4.20
    GLIBCXX_3.4.21
    GLIBCXX_DEBUG_MESSAGE_LENGTH

幸运的是，我们安装 Conda 时，已经在系统中安装了 libstdc++.so.6.0.28 的一个版本。

    $ strings /home/phytium/miniforge3/lib/libstdc++.so.6 | grep GLIBCXX

    ...
    GLIBCXX_3.4.18
    GLIBCXX_3.4.19
    GLIBCXX_3.4.20
    GLIBCXX_3.4.21
    GLIBCXX_3.4.22
    GLIBCXX_3.4.23
    GLIBCXX_3.4.24
    GLIBCXX_3.4.25
    GLIBCXX_3.4.26
    GLIBCXX_3.4.27
    GLIBCXX_3.4.28
    GLIBCXX_DEBUG_MESSAGE_LENGTH
    ...

我们可以直接用它来替换 /usr/lib/aarch64-linux-gnu 目录下的这个文件

    $ sudo cp /home/phytium/miniforge3/lib/libstdc++.so.6.0.28 /usr/lib/aarch64-linux-gnu/
    $ sudo rm -rf /usr/lib/aarch64-linux-gnu/libstdc++.so.6
    $ sudo ln -s /usr/lib/aarch64-linux-gnu/libstdc++.so.6.0.28 /usr/lib/aarch64-linux-gnu/libstdc++.so.6

然后再打开 VSCode，一切都正常了。您可以将 VSCode 的执行方式恢复成“应用程序”。

## 安装 Codium(不建议使用)

VSCodium 是 VSCode 的 Clean 版本。

在您安装 VS Code的时候，会看到这样一个熟悉的声明：

> VS Code 收集使用数据并将其发送给 Microsoft 以帮助改进我们的产品和服务。阅读我们的隐私声明以了解更多信息。

也就是说，在微软官网上下载的VS Code包含了Trakcer和远程报告功能，它会把你的文件数、文件大小、功能使用次数等统计数据发送给微软。

VS Codium 剔除了可能侵犯你隐私的功能。VS Codium 的开发者竭尽全力禁用了所有难以寻找的遥测选项，除非你自行编译，否则这已经是你能找到的最干净的 VS Code 版本了。

### 下载安装 VSCodium

**注意** ： 此版本在 Kylin V10 上会报 libc.so.6 版本不兼容, 导致安装后部分扩展使用不太正常。如：git、markdown。以下内容仅供参考，您可以参考上 VSCode 官方版本的解决方式尝试处理。

VS Codium 的 Github 地址是 [https://github.com/VSCodium/vscodium](https://github.com/VSCodium/vscodium)

    wget https://github.com/VSCodium/vscodium/releases/download/1.52.1/codium_1.52.1-1608165462_arm64.deb
    sudo dpkg -i codium_1.52.1-1608165462_arm64.deb

### 使用 

运行直接执行以下命令即可：

    $ codium --version
    1.52.1
    93c2f0fbf16c5a4b10e4d5f89737d9c2c25488a3
    arm64
    
	$ codium

## 安装 Code-OSS(已失效)

[https://github.com/futurejones/code-oss-aarch64](https://github.com/futurejones/code-oss-aarch64)

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
    