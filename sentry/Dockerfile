FROM ubuntu:18.04

# OS ENVS
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# APP ARGS
ARG NODE_VERSION
ARG NET_VERSION
ARG MONIKER
ARG NODE_IP
ARG PERSISTENT_PEER
ARG CHAIN_ID
ARG PERSISTENT_PEER_API
ARG NODE_TIMEOUT
ARG PRIVATE_PEERS

ARG APP_ENV
ENV APP_ENV ${APP_ENV}
ARG COSMOS_REST_SERVER_HOST
ENV COSMOS_REST_SERVER_HOST ${COSMOS_REST_SERVER_HOST}
ARG TENDERMINT_SERVER_HOST
ENV TENDERMINT_SERVER_HOST ${TENDERMINT_SERVER_HOST}
ARG TENDERMINT_SERVER_PORT
ENV TENDERMINT_SERVER_PORT ${TENDERMINT_SERVER_PORT}
ARG COSMOS_REST_SERVER_PORT
ENV COSMOS_REST_SERVER_PORT ${COSMOS_REST_SERVER_PORT}
ARG API_REST_PORT
ENV API_REST_PORT ${API_REST_PORT}
ARG POSTGRES_HOST
ENV POSTGRES_HOST ${POSTGRES_HOST}
ARG POSTGRES_PORT
ENV POSTGRES_PORT ${POSTGRES_PORT}
ARG POSTGRES_DB
ENV POSTGRES_DB ${POSTGRES_DB}
ARG POSTGRES_USER
ENV POSTGRES_USER ${POSTGRES_USER}
ARG REDIS_HOST
ENV REDIS_HOST ${REDIS_HOST}
ARG REDIS_PORT
ENV REDIS_PORT ${REDIS_PORT}
ARG LOG_TO_FILE
ENV LOG_TO_FILE ${LOG_TO_FILE}
ARG LOG_LEVEL
ENV LOG_LEVEL ${LOG_LEVEL}
ARG SWTH_UPGRADER
ENV SWTH_UPGRADER ${SWTH_UPGRADER}
ARG SEND_ETH_TXNS
ENV SEND_ETH_TXNS ${SEND_ETH_TXNS}
ARG WALLET_PASSWORD
ENV WALLET_PASSWORD ${WALLET_PASSWORD}

# OS update, then clean up
RUN apt-get -yq update && \
    apt-get -yq install tzdata && \
    apt-get -yq upgrade && \
    apt-get -yq install \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    aptitude \
    build-essential cmake \
    wget \
    curl \
    jq \
    sed \
    rsync \
    nano \
    psmisc \
    unzip && \
    apt-get clean

RUN wget https://github.com/google/leveldb/archive/1.22.tar.gz && \
      tar -zxvf 1.22.tar.gz && \
      cd leveldb-1.22/ && \
      cp -r include/leveldb /usr/local/include/ && \
      mkdir -p build && cd build && \
      cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_INSTALL_LIBDIR=/usr/lib \
      -DLEVELDB_BUILD_TESTS=ON \
      -DLEVELDB_INSTALL=ON \
      -DBUILD_SHARED_LIBS=ON && \
      make && \
      cp -r lib* /usr/local/lib/ && \
      ldconfig && \
      cd ../.. && rm -f 1.22.tar.gz

RUN curl -L https://github.com/Switcheo/tradehub/releases/download/${NODE_VERSION}/install-${NET_VERSION}.tar.gz | tar -xz
RUN cd install-${NET_VERSION} && \
    cp bin/switcheocli /usr/local/bin && \
    cp bin/switcheod /usr/local/bin && \
    cp bin/cosmovisor /usr/local/bin && \
    cd - && \
    rm -rf install-${NET_VERSION}

RUN switcheod init ${MONIKER} --chain-id ${CHAIN_ID}
RUN switcheocli config chain-id ${CHAIN_ID} && switcheocli config output json && switcheocli config indent true && switcheocli config trust-node true

RUN sed -i -e 's/timeout_commit = "5s"/timeout_commit = "'"${NODE_TIMEOUT}"'"/g' ~/.switcheod/config/config.toml
RUN sed -i -e 's/pruning-keep-recent = "0"/pruning-keep-recent = "100"/g' ~/.switcheod/config/app.toml
RUN sed -i -e 's/pruning-keep-every = "0"/pruning-keep-every = "10000"/g' ~/.switcheod/config/app.toml
RUN sed -i -e 's/pruning-interval = "0"/pruning-interval = "10"/g' ~/.switcheod/config/app.toml
RUN sed -i -e 's/cors_allowed_origins = \[\]/cors_allowed_origins = \["*"\]/g' ~/.switcheod/config/config.toml
RUN sed -i -e 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/'"${TENDERMINT_SERVER_HOST}"':'"${TENDERMINT_SERVER_PORT}"'"/g' ~/.switcheod/config/config.toml
RUN sed -i -e 's/addr_book_strict = true/addr_book_strict = false/g' ~/.switcheod/config/config.toml
RUN sed -i -e "s/pex.*/pex = true/g" ~/.switcheod/config/config.toml
RUN sed -i -e "s/persistent_peers = \"\"/persistent_peers = \"${PERSISTENT_PEER}\"/g" ~/.switcheod/config/config.toml
RUN sed -i -e "s/private_peer_ids = \"\"/private_peer_ids = \"${PRIVATE_PEERS}\"/g" ~/.switcheod/config/config.toml

RUN mkdir -p ~/.switcheod/migrations ~/.switcheo_logs/old ~/.switcheod/logs/old ~/.switcheo_migrations/migrate ~/.switcheo_config

ENTRYPOINT sh /root/init.sh -w ${WALLET_PASSWORD}