FROM alpine:3.11

LABEL maintainer="ProcessOne <contact@process-one.net>" \
      product="Ejabberd mix development environment"

MAINTAINER IascCHEN

# 更新Alpine的软件源为国内（清华大学）的站点 TUNA
RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.11/main" > /etc/apk/repositories && \
    echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.11/community" >> /etc/apk/repositories && \
    echo "https://mirror.tuna.tsinghua.edu.cn/alpine/edge/testing" >> /etc/apk/repositories

# Install required dependencies
RUN apk upgrade --update musl \
    && apk add build-base git zlib-dev openssl-dev yaml-dev expat-dev sqlite-dev \
    gd-dev jpeg-dev libpng-dev libwebp-dev autoconf automake bash \
    elixir erlang-crypto erlang-eunit erlang-mnesia erlang-erts erlang-hipe \
    erlang-tools erlang-os-mon erlang-syntax-tools erlang-parsetools \
    erlang-runtime-tools erlang-reltool erlang-odbc file curl \
    && rm -rf /var/cache/apk/*

# Setup runtime environment
RUN mix local.hex --force \
    && mix local.rebar --force

ENTRYPOINT ["/usr/bin/mix"]
CMD ["compile"]
