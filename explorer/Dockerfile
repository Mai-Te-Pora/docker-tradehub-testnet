FROM ubuntu:18.04

RUN apt-get -yq update && \
    apt-get -yq install tzdata && \
    apt-get -yq upgrade && \
    apt-get -yq install \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    aptitude \
    nodejs \
    npm \
    curl \
    nano \
    git && \
    apt-get clean

WORKDIR /root
RUN git clone https://github.com/Mai-Te-Pora/big-dipper
RUN curl https://install.meteor.com/ | sh

ENTRYPOINT sh /root/explorer-init.sh