# OpenLDAP & LAM

创建 OpenLDAP 和 LAM 以及相关的 Docker 服务

## OpenLDAP

参考链接 [https://github.com/osixia/docker-openldap](https://github.com/osixia/docker-openldap)

### 测试环境

OpenLDAP 支持 Arm64V8, 可以直接下载使用。

    $ docker pull osixia/openldap:1.4.0
    $ docker pull osixia/openldap:1.4.0-arm64v8

您可以确认一下这两个 IMAGE ID 是一致的。

    $ docker images
    REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
    osixia/openldap          1.4.0               54a3fdc9e5e6        6 months ago        256MB
    osixia/openldap          1.4.0-arm64v8       54a3fdc9e5e6        6 months ago        256MB

创建和设置 OpenLDAP Server

    $ docker stop my-openldap && docker rm my-openldap

按照如下参数设置 LDAP 域

    配置LDAP组织者：--env LDAP_ORGANISATION="ftcpu"
    配置LDAP域：--env LDAP_DOMAIN="ftcpu.net"
    配置LDAP密码：--env LDAP_ADMIN_PASSWORD="my-ldap-password"
    默认登录用户名：admin

    $ docker run --name my-openldap -p 389:389 -p 636:636 \
        --env LDAP_ORGANISATION="ftcpu" --env LDAP_DOMAIN="ftcpu.net" \
        --env LDAP_ADMIN_PASSWORD="my-ldap-password" \
        --detach osixia/openldap:1.4.0

### 生产环境使用

在生产环境中，需要支持 LDAP Backup ，可以使用 `osixia/openldap-backup`

    $ docker pull osixia/openldap-backup:1.4.0
    $ docker pull osixia/openldap-backup:1.4.0-arm64v8

    $ docker images
    REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
    osixia/openldap-backup   1.4.0               095672429b58        6 months ago        326MB
    osixia/openldap-backup   1.4.0-arm64v8       095672429b58        6 months ago        326MB

设定 Docker Network

    $ docker network create -d bridge my-bridge

    $ sudo mkdir -p /data/openldap/slapd/database
    $ sudo mkdir -p /data/openldap/slapd/config
    $ sudo mkdir -p /data/openldap/certificates
    $ sudo mkdir -p /data/openldap/backup

完整的创建脚本如下：

    $ docker run --name my-openldap -p 389:389 -p 636:636 \
        --env LDAP_ORGANISATION="ftcpu" --env LDAP_DOMAIN="ftcpu.net" \
        --env LDAP_ADMIN_PASSWORD="my-ldap-password" \
        --env LDAP_READONLY_USER=true --env LDAP_READONLY_USER_PASSWORD="my-readonly-password" \
        --network my-bridge --hostname ldap.ftcpu.net \
        --volume /data/openldap/slapd/database:/var/lib/ldap --volume /data/openldap/slapd/config:/etc/ldap/slapd.d \
        --volume /data/openldap/certificates:/container/service/slapd/assets/certs \
        --env LDAP_TLS_CRT_FILENAME=my-ldap.crt \
        --env LDAP_TLS_KEY_FILENAME=my-ldap.key \
        --env LDAP_TLS_CA_CRT_FILENAME=the-ca.crt \
        --volume /data/openldap/backup:/data/backup \
        --env LDAP_BACKUP_CONFIG_CRON_EXP="0 5 * * *" \
        --detach osixia/openldap-backup:1.4.0

参数说明如下：

* 增加网络相关参数

        --network my-bridge --hostname ldap.ftcpu.net \

* 增加只读用户，并设置密码

    -env LDAP_READONLY_USER=true --env LDAP_READONLY_USER_PASSWORD="my-readonly-password" \

* 指定 LDAP 存储卷

        --volume /data/openldap/slapd/database:/var/lib/ldap --volume /data/openldap/slapd/config:/etc/ldap/slapd.d \

* 设定 TLS 证书

        --volume /data/openldap/certificates:/container/service/slapd/assets/certs \
        --env LDAP_TLS_CRT_FILENAME=my-ldap.crt \
        --env LDAP_TLS_KEY_FILENAME=my-ldap.key \
        --env LDAP_TLS_CA_CRT_FILENAME=the-ca.crt \
        
* 设定 Backup，需要改换 Docker Image， 使用 osixia/openldap-backup

        --volume /data/openldap/backup:/data/backup \
        --env LDAP_BACKUP_CONFIG_CRON_EXP="0 5 * * *" \
        --detach osixia/openldap-backup:1.4.0

### 验证服务

    $ docker exec my-openldap ldapsearch -x -H ldap://localhost -b dc=ftcpu,dc=net -D "cn=admin,dc=ftcpu,dc=net" -w my-ldap-password

    $ docker exec my-openldap ldapsearch -x -H ldap://localhost -b dc=ftcpu,dc=net -D "cn=readonly,dc=ftcpu,dc=net" -w my-readonly-password

    # extended LDIF
    #
    # LDAPv3
    # base <dc=ftcpu,dc=net> with scope subtree
    # filter: (objectclass=*)
    # requesting: ALL
    #

    # ftcpu.net
    dn: dc=ftcpu,dc=net
    objectClass: top
    objectClass: dcObject
    objectClass: organization
    o: ftcpu
    dc: ftcpu

    # admin, ftcpu.net
    dn: cn=admin,dc=ftcpu,dc=net
    objectClass: simpleSecurityObject
    objectClass: organizationalRole
    cn: admin
    description: LDAP administrator
    userPassword:: e1NTSEF9T21MQmdIZzlZc2hwOC9ZN01QZVI0dVhHM29TVVA2TWo=

    # search result
    search: 2
    result: 0 Success

    # numResponses: 3
    # numEntries: 2


     $ docker exec my-openldap ldapsearch -x -ZZ

### 使用 JXplore 验证访问

麒麟软件商店自带 JXplorer LDAP 客户端，可以访问和管理 OpenLDAP

打开 JXplorer，设置参数如下，连接成功即表明OpenLDAP安装成功。

    主机: localhost
    Port: 389
    Version : LDAP v3
    Base DN: dc=ftcpu,dc=net
    安全 ： 
        Level ： 用户+密码
        使用者DN： cn=admin,dc=ftcpu,dc=net
        密码: my-ldap-password

## 使用 phpLDAPadmin

    $ docker pull osixia/phpldapadmin:0.9.0
    $ docker pull osixia/phpldapadmin:0.9.0-arm64v8

您可以确认一下这两个 IMAGE ID 是一致的。

    $ docker images
    REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
    osixia/phpldapadmin      0.9.0               d409f50256f2        13 months ago       294MB
    osixia/phpldapadmin      0.9.0-arm64v8       d409f50256f2        13 months ago       294MB

    $ docker stop my-phpldapadmin && docker rm my-phpldapadmin

    $ docker run --name my-phpldapadmin -p 10080:80 \
        --network my-bridge --link my-openldap:ldap-host \
        --env PHPLDAPADMIN_HTTPS=false --env PHPLDAPADMIN_LDAP_HOSTS=ldap-host \
        --detach osixia/phpldapadmin:0.9.0

使用如下参数登录：

    Login DN: cn=admin,dc=ftcpu,dc=net
    Password: my-ldap-password

## 使用 LAM

LAM 是 LDAP Account Manager 的简称, 是一个 Web 端的 OpenLDAP 管理工具。

[https://github.com/ldapaccountmanager/lam](https://github.com/ldapaccountmanager/lam)

LAM 提供了对 docker 的支持，但是上缺少 Arm64V8 平台上的版本。因此，我们需要从 Dockerfile 自己 Build。

Git 有时下载不下来，并且脚本执行时需要从 sourceforge 下载，墙内有时会报错。所以修改了 Dockerfile，先将 deb 文件下载到本地，再制作 Docker Image。

    $ cd ./lam
    $ docker build . -t ldapaccountmanager/lam:7.4-arm64v8

    $ docker stop my-lam && docker rm my-lam
    $ docker run --name my-lam -p 10180:80 \
        --network my-bridge --link my-openldap:ldap-host \
        --env LAM_LANG=zh_CN \
        --env LDAP_DOMAIN=ftcpu.net \
        --env LDAP_BASE_DN=dc=ftcpu,dc=net \
        --env LDAP_USERS_DN=ou=people,dc=ftcpu,dc=net \
        --env LDAP_GROUPS_DN=ou=groups,dc=ftcpu,dc=net \
        --env LDAP_SERVER=ldap://ldap-host:389 \
        --env LDAP_USER=cn=admin,dc=ftcpu,dc=net \
        --env LAM_PASSWORD=my-lam-password \
        --detach ldapaccountmanager/lam:7.4-arm64v8

可用的环境变量：

    #
	# LAM setup
	#
	# skip LAM preconfiguration (lam.conf + config.cfg), values: (true/false)
	# If set to false the other variables below have no effect.
	LAM_SKIP_PRECONFIGURE=false
	# domain of LDAP database root entry, will be converted to dc=...,dc=...
	LDAP_DOMAIN=my-domain.com
	# LDAP base DN to overwrite value generated by LDAP_DOMAIN
	LDAP_BASE_DN=dc=my-domain,dc=com
	# LDAP users DN to overwrite value provided by LDAP_BASE_DN
	LDAP_USERS_DN=ou=people,dc=my-domain,dc=com
	# LDAP groups DN to overwrite value provided by LDAP_BASE_DN
	LDAP_GROUPS_DN=ou=groups,dc=my-domain,dc=com
	
	# LDAP server URL
	LDAP_SERVER=ldap://ldap:389
	# LDAP admin user (set as login user for LAM)
	LDAP_USER=cn=admin,dc=my-domain,dc=com
	# default language, e.g. en_US, de_DE, fr_FR, ...
	LAM_LANG=zh_CN
	# LAM configuration master password and password for server profile "lam"
	LAM_PASSWORD=my-lam-password
	
	# deactivate TLS certificate checks, activate for development only
	LAM_DISABLE_TLS_CHECK=false
	
	#
	# docker-compose only, LDAP server setup
	#
	# LDAP organisation name for OpenLDAP
	LDAP_ORGANISATION="LDAP Account Manager Demo"
	# LDAP admin password
	LDAP_ADMIN_PASSWORD=adminpw
	# password for LDAP read-only user
	LDAP_READONLY_USER_PASSWORD=readonlypw

    ## LDAP 数据和结构初始化

    