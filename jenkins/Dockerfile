FROM jenkins/jenkins:2.92-alpine

USER root
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.6/main" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.6/community" >> /etc/apk/repositories
RUN apk update && apk upgrade && \
    apk add libuv-dev wget gcc g++ clang make openssh ruby bison sudo gperf \
    oniguruma-dev libmaxminddb-dev mbedtls-dev pcre-dev pcre2-dev jpeg-dev openjpeg-dev linux-headers \
    libressl-dev libnl-dev ipvsadm gmp-dev libnet-dev hiredis-dev autoconf mesa-dev libunwind-dev glib-dev perl \
    curl-dev llvm-dev cmake sqlite-dev zstd-dev automake mpg123-dev util-linux libnfnetlink-dev \
    imagemagick-c++ imagemagick-dev gsl-dev lua5.2-dev lz4-dev unixodbc-dev clang-dev libxml2-dev yaml-dev \
    fltk-dev libtool flex linux-pam-dev fts-dev libsodium-dev libpcap-dev glfw-dev geoip-dev msgpack-c-dev \
    lmdb-dev clang-static llvm-static file docker

RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

ENV ONIGMO_VERSION 6.1.3
RUN wget https://github.com/k-takata/Onigmo/releases/download/Onigmo-${ONIGMO_VERSION}/onigmo-${ONIGMO_VERSION}.tar.gz && \
    tar xf onigmo-${ONIGMO_VERSION}.tar.gz && \
    cd onigmo-${ONIGMO_VERSION} && \
    ./configure && \
    make -j2 install

RUN mkdir -p ~/.ssh; ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

USER jenkins
