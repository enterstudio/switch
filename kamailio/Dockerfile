FROM alpine
MAINTAINER Jorge Cerpa

RUN apk add --update kamailio kamailio-mysql kamailio-unixodbc kamailio-utils kamailio-presence kamailio-outbound kamailio-websocket mysql-client && rm -rf /var/cache/apk/*

COPY msilo-create.sql /usr/share/kamailio/mysql/msilo-create.sql
COPY topos-create.sql /usr/share/kamailio/mysql/topos-create.sql
COPY kamdbctl.base /usr/lib/kamailio/kamctl/kamdbctl.base

EXPOSE 5060

#ENV PUBLICIP=10.200.3.53

COPY ./etc/kamailio/kamctlrc /etc/kamailio/kamctlrc
COPY ./etc/kamailio/kamailio.cfg /etc/kamailio/kamailio.cfg
#RUN sed -i 's/#!define PUBLICIP \s*.*/#!define PUBLICIP  \"'$PUBLICIP'\"/g' /etc/kamailio/kamailio.cfg

#CMD kamailio start
CMD sed -i 's/#!define PUBLICIP \s*.*/#!define PUBLICIP  \"'$PUBLICIP'\"/g' /etc/kamailio/kamailio.cfg && /usr/sbin/kamailio -P /var/run/kamailio/kamailio.pid -m 64 -M 8 -u kamailio -g kamailio -DD -E -e
