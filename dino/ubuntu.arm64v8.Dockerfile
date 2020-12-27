FROM arm64v8/ubuntu:20.04

MAINTAINER IascCHEN

# 更新Ubuntu的软件源为国内（清华大学）的站点 TUNA
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt update && apt upgrade -y && apt install -y apt-utils
RUN apt install -y git curl
    
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
RUN curl -sLO http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/pool/main/t/tzdata/tzdata_2020d-0ubuntu0.20.04_all.deb && \
    dpkg -i tzdata_2020d-0ubuntu0.20.04_all.deb

RUN apt install -y cmake valac libgee-0.8-dev libsqlite3-dev libgtk-3-dev libnotify-dev libgpgme-dev libsoup2.4-dev \ 
    libgcrypt20-dev libqrencode-dev gettext libsignal-protocol-c-dev

RUN mkdir -p /tmp/dino && cd /tmp/dino
RUN git clone https://github.com/dino/dino.git
RUN cd dino && ./configure && make

# ENTRYPOINT ["/usr/sbin/ejabberdctl"]
# RUN build/dino
