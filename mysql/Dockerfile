FROM mysql
MAINTAINER Jorge Cerpa

#RUN apt-get -y update && apt-get install -y openssh-client sshpass && apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/*
#RUN echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

ENV MYSQL_ROOT_PASSWORD=supersecret

COPY ./docker-entrypoint-initdb.d/kamailio_db.sql /docker-entrypoint-initdb.d/kamailio_db.sql
COPY ./docker-entrypoint-initdb.d/asterisk_db.sql /docker-entrypoint-initdb.d/asterisk_db.sql

VOLUME /var/lib/mysql
