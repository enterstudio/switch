FROM alpine
MAINTAINER Jorge Cerpa

RUN apk add --update rtpproxy && rm -rf /var/cache/apk/*
#ENV RTPPROXY_OPTS "-A 10.200.3.60/192.168.0.1 -F -f -l 10.200.3.60/192.168.0.1 -m 10000 -M 10100 -s udp:*:7722 -d DBUG:LOG_LOCAL0"

#EXPOSE 7722

#VOLUME /etc/conf.d/rtpproxy

# ENV PORT_PROXY 7711
# ENV PORT_MIN 10000
# ENV PORT_MAX 10100

WORKDIR /etc/init.d/

CMD rtpproxy