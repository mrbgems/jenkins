FROM jenkins/jenkins:2.92-alpine

USER root
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.6/main" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.6/community" >> /etc/apk/repositories
RUN apk update && apk upgrade && apk add docker sudo ruby docker
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

USER jenkins
