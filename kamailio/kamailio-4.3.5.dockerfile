FROM switch_docker:1.12.3-dind
MAINTAINER Jorge Cerpa

RUN apk add --update kamailio kamailio-mysql kamailio-unixodbc kamailio-utils kamailio-presence kamailio-outbound kamailio-websocket mysql-client openssh sipcalc bind bind-tools \
    && rm -rf /var/cache/apk/*
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N "" \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N "" \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N "" \
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" \
    && echo "root:docker" | chpasswd

COPY /config/ssh/sshd_config /etc/ssh/sshd_config
COPY /db/msilo-create.sql /usr/share/kamailio/mysql/msilo-create.sql
#COPY /db/topos-create.sql /usr/share/kamailio/mysql/topos-create.sql
#COPY /db/kamdbctl.base /usr/lib/kamailio/kamctl/kamdbctl.base
COPY /config/kamailio/kamctlrc /etc/kamailio/kamctlrc
COPY /config/kamailio/kamailio.cfg /etc/kamailio/kamailio.cfg
COPY /docker-entrypoint/kamailio-autoconfigure.sh /docker-entrypoint/kamailio-autoconfigure.sh

EXPOSE 5060

WORKDIR /docker-entrypoint

CMD ["sh", "kamailio-autoconfigure.sh"]
