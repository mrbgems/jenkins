FROM jenkins/jenkins:2.103

USER root
RUN apt update && apt upgrade -y && apt install -y ruby

USER jenkins
RUN mkdir -p ~/.ssh; ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
