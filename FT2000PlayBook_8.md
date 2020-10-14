# FT2000/4 & Kylin V10 Desktop 玩耍记录(8) —— 各种 Docker Image

这个地址有针对于 Arm64V8 的各种 Docker Image [https://hub.docker.com/u/arm64v8/](https://hub.docker.com/u/arm64v8/)

## MySQL

仅有 MySQL 8 支持 Arm64。

    docker pull mysql/mysql-server

    docker run --name=my-mysql -d -p 3306:3306 mysql/mysql-server

## 数据库

    docker pull arm64v8/mongo:4.0-xenial

    docker pull arm64v8/postgres:13-alpine

    docker pull arm64v8/influxdb

    docker pull arm64v8/cassandra:3

    docker pull arm64v8/redis:6-alpine

    docker pull arm64v8/memcached:alpine

    docker pull arm64v8/flink

    docker pull arm64v8/zookeeper

    docker pull arm64v8/elasticsearch:7.9.2


## 代理或应用服务器

    docker pull arm64v8/traefik

    docker pull arm64v8/nginx

    docker pull arm64v8/tomcat

    docker pull arm64v8/jetty

    docker pull arm64v8/xwiki

## 编程语言

    docker pull arm64v8/php

    docker pull arm64v8/phpmyadmin

    docker pull arm64v8/python:3-alpine

    docker pull arm64v8/node:12-alpine3.12

    docker pull arm64v8/openjdk

    docker pull arm64v8/mono  （c#）

## Linux

    docker pull arm64v8/alpine

    docker pull arm64v8/debian

    docker pull arm64v8/ubuntu

    docker pull arm64v8/centos

    docker pull arm64v8/oraclelinux

## 邮件

    docker pull arm64v8/postfixadmin

## Docker & Micro Service

    docker pull arm64v8/registry

    docker pull arm64v8/kong