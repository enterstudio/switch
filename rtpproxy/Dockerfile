FROM docker:1.12.3-dind
MAINTAINER Jorge Cerpa

ENV SWARM_MASTER_IP=10.128.19.60 \
    SWARM_MASTER_PORT=3375 \

    PORT_MAX=10099 \
    PORT_MIN=10000 \

    SUBNET_OVERLAY=192.168.1.0 \
    SUFFIX_OVERLAY=int \
    SUFFIX_GWBRIDGE=ext \

    PORT_RTPPROXY=7711 \
    DB_KAMAILIO=kamailio_db \
    TABLE_RTPPROXY=rtpproxy \
    DB_USER=kamailio_user \
    DB_PWD=kamailiopwd \
    DB_HOST=db \

    SSH_KAMAILIO_PASSWORD=docker \
    SSH_KAMAILIO_USER=root \
    KAMAILIO_HOST=kamailio \

    DB_METRIC=metric_db \
    TABLE_HOST=host \
    TABLE_CONTAINER=container \
    TABLE_METRIC=metric \
    DB_USER_METRIC=metric_user \
    DB_PWD_METRIC=metricpwd \

    METRIC_PERIOD=0.01

RUN apk add --update rtpproxy mysql-client sipcalc bind bind-tools openssh-client sshpass && rm -rf /var/cache/apk/*
RUN echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

COPY ./docker-entrypoint-init /docker-entrypoint-init

WORKDIR /docker-entrypoint-init

CMD ["sh", "init.sh"]
