FROM jenkins/slave:alpine

USER root

RUN apk update && apk upgrade && apk add libuv-dev wget gcc g++ clang make openssh ruby bison sudo gperf oniguruma-dev ccache
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
ENV PATH "/usr/lib/ccache/bin:${PATH}"

WORKDIR /root

ENV ONIGMO_VERSION 6.1.3
RUN wget https://github.com/k-takata/Onigmo/releases/download/Onigmo-${ONIGMO_VERSION}/onigmo-${ONIGMO_VERSION}.tar.gz && \
    tar xf onigmo-${ONIGMO_VERSION}.tar.gz && \
    cd onigmo-${ONIGMO_VERSION} && \
    ./configure && \
    make -j2 install

WORKDIR /home/jenkins

USER jenkins

RUN mkdir -p ~/.ssh; ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
