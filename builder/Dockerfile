FROM jenkinsci/jnlp-slave:3.16-1

USER root
RUN dpkg --add-architecture i386 && \
    apt update && apt upgrade -y && \
    apt install apt-transport-https && \
    curl -L https://dl.winehq.org/wine-builds/Release.key | apt-key add - && \
    echo "deb https://dl.winehq.org/wine-builds/debian/ stretch main" >> /etc/apt/sources.list && \
    apt update && apt upgrade -y && \
    apt install -y \
    wget gcc g++ clang make openssh-client ruby ruby-dev bison sudo gperf autoconf perl automake \
    libtool flex graphicsmagick-imagemagick-compat fts mingw-w64 cmake \
    libonig-dev libmaxminddb-dev libmbedtls-dev libpcre2-dev libjpeg-dev linux-headers-amd64 \
    libnl-3-dev ipvsadm libgmp-dev libnet1-dev libhiredis-dev libgles2-mesa-dev libunwind-dev \
    libcurl4-openssl-dev llvm-dev libsqlite3-dev libzstd-dev libmpg123-dev libnfnetlink-dev \
    libgsl-dev liblua5.2-dev liblz4-dev unixodbc-dev libmsgpack-dev libmagick++-dev libcgroup-dev \
    libxml2-dev libyaml-dev libfltk1.3-dev libsodium-dev libpcap-dev libglfw3-dev libclang-dev \
    libgeoip-dev liblmdb-dev docker libunbound-dev libmariadb-dev libglib2.0-dev libpam0g-dev libv8-dev \
    libasan3 libmemcached-dev libmnl-dev libmecab-dev liblzma-dev libplplot-dev libargon2-0-dev \
    libmagic-dev libmariadbclient-dev libssl-dev libleveldb-dev libncurses5-dev liballegro5-dev \
    libczmq-dev chipmunk-dev libjansson-dev libevent-dev libsystemd-dev libaugeas-dev \
    python-dev cython libev-dev libc-ares-dev libjemalloc-dev python-setuptools \
    redis-server gobjc ccache nano portaudio19-dev winehq-staging
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /root

ENV ONIGMO_VERSION 6.1.3
RUN wget https://github.com/k-takata/Onigmo/releases/download/Onigmo-${ONIGMO_VERSION}/onigmo-${ONIGMO_VERSION}.tar.gz && \
    tar xf onigmo-${ONIGMO_VERSION}.tar.gz && \
    cd onigmo-${ONIGMO_VERSION} && \
    ./configure && \
    make -j2 install

ENV LIBUV_VERSION 1.19.1
RUN wget https://dist.libuv.org/dist/v${LIBUV_VERSION}/libuv-v${LIBUV_VERSION}.tar.gz && \
    tar xf libuv-v${LIBUV_VERSION}.tar.gz && \
    cd libuv-v${LIBUV_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make -j2 install

RUN ldconfig

WORKDIR /home/jenkins

USER jenkins
RUN mkdir -p ~/.ssh; ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
