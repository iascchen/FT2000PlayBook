# FT2000/4 & Kylin V10 Desktop 玩耍记录(5) —— Conda， Jupyter & Tensorflow | Pytorch

## MiniConda

在 ARM64 上，暂时没有官方版本可用。我们可以使用其他的开源替代版本。

网上能够搜到三个可用的 MiniConda 替代，我们选择最近还在更新的 miniforge。miniforge 已经绑定了 conda-forge。

* [miniforge](https://github.com/conda-forge/miniforge)
* [Archiconda](https://github.com/Archiconda/build-tools/releases)
* [jjhelmus/conda4aarch64](https://github.com/jjhelmus/conda4aarch64)
### 下载和安装

    $ wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh
    $ bash Miniforge3-Linux-aarch64.sh

一路选择 yes 和回车即可。

检查 Conda 版本

  $ conda --version
  conda 4.9.2
  $ python --version
  Python 3.8.6
  $ pip --version
  pip 20.3.3 from /home/phytium/miniforge3/lib/python3.8/site-packages/pip (python 3.8)

升级命令

    $ conda update conda
    $ python -m pip install --upgrade pip

关于 Conda 的使用，可以参考 [https://www.seu-mhw.cn/conda__python_common_operation_commands/](https://www.seu-mhw.cn/conda__python_common_operation_commands/)

## Jupyter

    $ conda install jupyterlab
    $ conda install notebook
    $ conda install voila
