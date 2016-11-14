FROM alpine
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

RUN apk add --update rtpproxy mysql-client sipcalc bind bind-tools && rm -rf /var/cache/apk/*
#RUN mkdir /docker-entrypoint-init 
#WORKDIR /docker-entrypoint-init
#RUN ln -s /etc/init.d/rtpproxy rtpproxy
#COPY ./etc/conf.d/rtpproxy /etc/conf.d/rtpproxy

COPY ./docker-entrypoint-init /docker-entrypoint-init

#WORKDIR /etc/init.d/
WORKDIR /docker-entrypoint-init

#ENTRYPOINT ["sh", "network-configurator-alpine.sh", "sh", "db-client.sh"]

#WORKDIR /etc/init.d/
# Otra opción sería modificar el script /etc/init.d/rtpproxy añadiendo el contenido del db-client.sh
#CMD rtpproxy -A $IP_GWBRIDGE/$IP_OVERLAY -F -f -l $PUBLIC_IP/$IP_GWBRIDGE -m $PORT_MIN -M $PORT_MAX -s udp:*:$PORT_RTPPROXY -d DBUG:LOG_LOCAL0

#CMD sh init-rtpproxy.sh
#CMD /usr/bin/rtpproxy $RTPPROXY_OPTS
CMD sh rtpproxy-autoconfigure.sh
