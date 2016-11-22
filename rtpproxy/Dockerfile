FROM docker:1.12.3-dind
MAINTAINER Jorge Cerpa

#ENV PUBLIC_IP

#ENV PORT_MAX
#ENV PORT_MIN

#ENV TIMEOUT

##ENV ETH_OVERLAY
##ENV IP_OVERLAY
##ENV MASK_OVERLAY
#ENV SUBNET_OVERLAY
#ENV SUFFIX_OVERLAY
##ENV HOSTNAME_OVERLAY

##ENV ETH_GWBRIDGE
##ENV IP_GWBRIDGE
##ENV MASK_GWBRIDGE
##ENV SUBNET_GWBRIDGE
##ENV HOSTNAME_GWBRIDGE
#ENV SUFFIX_GWBRIDGE

#ENV PORT_RTPPROXY
#ENV DB_KAMAILIO
#ENV TABLE_RTPPROXY
#ENV DB_USER
#ENV DB_PWD
#ENV DB_HOST

#ENV RTPPROXY_OPTS=-A $IP_GWBRIDGE/$IP_OVERLAY -F -f -l $PUBLIC_IP/$IP_GWBRIDGE -m $PORT_MIN -M $PORT_MAX -s udp:*:$PORT_RTPPROXY -d DBUG:LOG_LOCAL0

RUN apk add --update rtpproxy mysql-client sipcalc bind bind-tools openssh-client sshpass && rm -rf /var/cache/apk/*
RUN echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

COPY ./docker-entrypoint-init /docker-entrypoint-init

WORKDIR /docker-entrypoint-init

CMD ["sh", "sig-handler.sh", "sh", "rtpproxy-autoconfigure.sh"]
