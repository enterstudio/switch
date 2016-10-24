FROM mysql
MAINTAINER Jorge Cerpa

ENV MYSQL_ROOT_PASSWORD=supersecret

COPY ./docker-entrypoint-initdb.d/kamailio_db.sql /docker-entrypoint-initdb.d/kamailio_db.sql
COPY ./docker-entrypoint-initdb.d/asterisk_db.sql /docker-entrypoint-initdb.d/asterisk_db.sql

VOLUME /var/lib/mysql