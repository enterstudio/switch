#!/bin/bash

cp /docker-entrypoint-init/add-metric.sql.ori /docker-entrypoint-init/add-metric.sql
cp /docker-entrypoint-init/del-metric.sql.ori /docker-entrypoint-init/del-metric.sql

DOCKER_HOST_NAME=$1
PUBLIC_IP=$2
HOSTNAME_EXTERNAL_OVERLAY=$3
IP_GWBRIDGE=$4
TOTAL_PORTS=$(expr $PORT_MAX - $PORT_MIN + 1)

sed -i 's/--CONTAINER_NAME--\s*/'$HOSTNAME_EXTERNAL_OVERLAY'/g' add-metric.sql
sed -i 's/--DOCKER_HOST_NAME--\s*/'$DOCKER_HOST_NAME'/g' add-metric.sql
sed -i 's/--PUBLIC_IP--\s*/'$PUBLIC_IP'/g' add-metric.sql
sed -i 's/--DB_METRIC--\s*/'$DB_METRIC'/g' add-metric.sql
sed -i 's/--TABLE_METRIC--\s/'$TABLE_METRIC'/g' add-metric.sql
sed -i 's/--TABLE_CONTAINER--\s/'$TABLE_CONTAINER'/g' add-metric.sql
sed -i 's/--TABLE_HOST--\s/'$TABLE_HOST'/g' add-metric.sql
sed -i 's/--TOTAL_PORTS--\s/'$TOTAL_PORTS'/g' add-metric.sql

sed -i 's/--CONTAINER_NAME--/'$HOSTNAME_EXTERNAL_OVERLAY'/g' del-metric.sql
sed -i 's/--DOCKER_HOST_NAME--/'$DOCKER_HOST_NAME'/g' del-metric.sql
sed -i 's/--DB_METRIC--/'$DB_METRIC'/g' del-metric.sql
sed -i 's/--TABLE_CONTAINER--/'$TABLE_CONTAINER'/g' del-metric.sql
sed -i 's/--TABLE_HOST--/'$TABLE_HOST'/g' del-metric.sql

mysql -u$DB_USER_METRIC -p$DB_PWD_METRIC -h$DB_HOST < add-metric.sql

while true
do
    cp /docker-entrypoint-init/update-metric.sql.ori /docker-entrypoint-init/update-metric.sql

    ACTIVE_PORTS=$(netstat -na | grep -c $IP_GWBRIDGE)
    FREE_PORTS=$(expr $TOTAL_PORTS - $ACTIVE_PORTS)

    sed -i 's/--CONTAINER_NAME--/'$HOSTNAME_EXTERNAL_OVERLAY'/g' update-metric.sql
    sed -i 's/--DB_METRIC--/'$DB_METRIC'/g' update-metric.sql
    sed -i 's/--TABLE_METRIC--/'$TABLE_METRIC'/g' update-metric.sql
    sed -i 's/--ACTIVE_PORTS--/'$ACTIVE_PORTS'/g' update-metric.sql
    sed -i 's/--FREE_PORTS--/'$FREE_PORTS'/g' update-metric.sql

    mysql -u$DB_USER_METRIC -p$DB_PWD_METRIC -h$DB_HOST < update-metric.sql

    sleep $METRIC_PERIOD
done
mysql -u$DB_USER_METRIC -p$DB_PWD_METRIC -h$DB_HOST < del-metric.sql
