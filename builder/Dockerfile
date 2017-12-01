FROM ruby:alpine3.6

RUN apk update && apk upgrade && apk add libuv-dev wget gcc g++ clang make

WORKDIR /root

ENV ONIGMO_VERSION 6.1.3
RUN wget https://github.com/k-takata/Onigmo/releases/download/Onigmo-${ONIGMO_VERSION}/onigmo-${ONIGMO_VERSION}.tar.gz && \
    tar xf onigmo-${ONIGMO_VERSION}.tar.gz && \
    cd onigmo-${ONIGMO_VERSION} && \
    ./configure && \
    make -j2 install
