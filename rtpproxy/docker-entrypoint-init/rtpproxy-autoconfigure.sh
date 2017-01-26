#!/bin/bash

(echo "$SUBNET_OVERLAY" | grep -Eq "$IP_REGEXP") && echo "subnet overlay is $SUBNET_OVERLAY" || (echo "subnet overlay is wrong" && exit 1)

LENGTH_SUFFIX_OVERLAY=${#SUFFIX_OVERLAY}
if [ $LENGTH_SUFFIX_OVERLAY -eq 0 ]
    then
    HOSTNAME_OVERLAY=$HOSTNAME
else
    HOSTNAME_OVERLAY=${HOSTNAME}"-"$SUFFIX_OVERLAY
fi

LENGTH_SUFFIX_GWBRIDGE=${#SUFFIX_GWBRIDGE}
if [ $LENGTH_SUFFIX_GWBRIDGE -eq 0 ]
    then
    HOSTNAME_GWBRIDGE=$HOSTNAME
else
    HOSTNAME_GWBRIDGE=${HOSTNAME}"-"$SUFFIX_GWBRIDGE
fi

HOSTS_FILE=/etc/hosts
HOSTS_FILE_AUX=${HOSTS_FILE}".aux"
HOSTS_FILE_BACKUP=${HOSTS_FILE}".bck"

RESOLV_FILE=/etc/resolv.conf
RESOLV_FILE_AUX=${RESOLV_FILE}".aux"
RESOLV_FILE_BACKUP=${RESOLV_FILE}".bck"

NUM_ETH=2
COUNT_ETH=$(ifconfig | grep -cE "^eth[0-9]+")

if [ $COUNT_ETH -eq $NUM_ETH ]
    then
    # DETECT NETWORK CONFIG
    IP_ETH0=$(ifconfig eth0 | awk '/inet addr/{split($2,a,":"); print a[2]}')
    IP_ETH1=$(ifconfig eth1 | awk '/inet addr/{split($2,a,":"); print a[2]}')
    MASK_ETH0=$(ifconfig eth0 | awk '/Mask:/{split($4,a,":"); print a[2]}')
    MASK_ETH1=$(ifconfig eth1 | awk '/Mask:/{split($4,a,":"); print a[2]}')
    SUBNET_ETH0=$(sipcalc $IP_ETH0 $MASK_ETH0 | awk '/Network address/{split($4,a,"-"); print a[1]}')
    SUBNET_ETH1=$(sipcalc $IP_ETH1 $MASK_ETH1 | awk '/Network address/{split($4,a,"-"); print a[1]}')

        if [ $SUBNET_OVERLAY == $SUBNET_ETH0 ]
            then
            ETH_OVERLAY="eth0"
            IP_OVERLAY=$IP_ETH0
            MASK_OVERLAY=$MASK_ETH0
            ETH_GWBRIDGE="eth1"
            IP_GWBRIDGE=$IP_ETH1
            MASK_GWBRIDGE=$MASK_ETH1
            SUBNET_GWBRIDGE=$SUBNET_ETH1
        elif [ $SUBNET_OVERLAY == $SUBNET_ETH1 ]
            then
            ETH_OVERLAY="eth1"
            IP_OVERLAY=$IP_ETH1
            MASK_OVERLAY=$MASK_ETH1
            ETH_GWBRIDGE="eth0"
            IP_GWBRIDGE=$IP_ETH0
            MASK_GWBRIDGE=$MASK_ETH0
            SUBNET_GWBRIDGE=$SUBNET_ETH0
        else
            echo "subnet overlay match anything"
            exit 1

        fi

    # UPDATE /etc/resolv.conf
    if ! [ -f $RESOLV_FILE_BACKUP ]
        then
        cp $RESOLV_FILE $RESOLV_FILE_BACKUP
    fi
    cp $RESOLV_FILE_BACKUP $RESOLV_FILE_AUX
    sed -i 's/options ndots:0/options ndots:1/g' $RESOLV_FILE_AUX
    cat $RESOLV_FILE_AUX > $RESOLV_FILE

    HOSTNAME_EXTERNAL_OVERLAY=$(host $IP_OVERLAY | awk '/pointer/{split($5,a,"."); print a[1]}')
    DOCKER_HOST_NAME=$(docker -H $SWARM_MASTER_IP:$SWARM_MASTER_PORT ps -a | awk '/'$HOSTNAME_EXTERNAL_OVERLAY'/ {split ($NF,a,"/"); print a[1]}')
    PUBLIC_IP=$(host $DOCKER_HOST_NAME | awk '/address/{split ($4,a," "); print a[1]}')
    RTPPROXY_OPTS=$(echo "-f -u rtpproxy:rtpproxy -A $PUBLIC_IP -l $IP_GWBRIDGE -m $PORT_MIN -M $PORT_MAX -s udp:$IP_OVERLAY:$PORT_RTPPROXY -d DBUG:LOG_LOCAL0")
    # UPDATE /etc/hosts
    if ! [ -f $HOSTS_FILE_BACKUP ]
        then
        cp $HOSTS_FILE $HOSTS_FILE_BACKUP
    fi
    cp $HOSTS_FILE_BACKUP $HOSTS_FILE_AUX
    sed -i 's/'$IP_GWBRIDGE'\s*'$HOSTNAME'/'$IP_GWBRIDGE'        '$HOSTNAME_GWBRIDGE'/g' $HOSTS_FILE_AUX
    sed -i 's/'$IP_OVERLAY'\s*'$HOSTNAME'/'$IP_OVERLAY'        '$HOSTNAME_OVERLAY'/g' $HOSTS_FILE_AUX
    cat $HOSTS_FILE_AUX > $HOSTS_FILE
       
    # UPDATE DATABASE
    cp /docker-entrypoint-init/add-rtpproxy.sql.ori /docker-entrypoint-init/add-rtpproxy.sql
    cp /docker-entrypoint-init/del-rtpproxy.sql.ori /docker-entrypoint-init/del-rtpproxy.sql

    sed -i 's/--HOSTNAME--\s*/'$HOSTNAME_EXTERNAL_OVERLAY'/g' add-rtpproxy.sql
    sed -i 's/--DB_KAMAILIO--\s*/'$DB_KAMAILIO'/g' add-rtpproxy.sql
    sed -i 's/--PORT_RTPPROXY--\s*/'$PORT_RTPPROXY'/g' add-rtpproxy.sql
    sed -i 's/--TABLE_RTPPROXY--/'$TABLE_RTPPROXY'/g' add-rtpproxy.sql

    sed -i 's/--HOSTNAME--\s*/'$HOSTNAME_EXTERNAL_OVERLAY'/g' del-rtpproxy.sql
    sed -i 's/--DB_KAMAILIO--\s*/'$DB_KAMAILIO'/g' del-rtpproxy.sql
    sed -i 's/--PORT_RTPPROXY--\s*/'$PORT_RTPPROXY'/g' del-rtpproxy.sql
    sed -i 's/--TABLE_RTPPROXY--/'$TABLE_RTPPROXY'/g' del-rtpproxy.sql

    mysql -u$DB_USER -p$DB_PWD -h$DB_HOST < add-rtpproxy.sql
    if test $? -ne 0 
      then
	echo "ERROR: Could not be added to the database"
	exit 1
    else
        sshpass -p $SSH_KAMAILIO_PASSWORD ssh $SSH_KAMAILIO_USER@$KAMAILIO_HOST 'kamctl restart'
        if test $? -ne 255
          then
            echo "ERROR: could not connect with kamailio"
            exit 1
        else
          # START METRICS
          sh /docker-entrypoint-init/rtpproxy-metric.sh $DOCKER_HOST_NAME $PUBLIC_IP $HOSTNAME_EXTERNAL_OVERLAY $IP_GWBRIDGE &
          # START RTPPROXY
          /usr/bin/rtpproxy $RTPPROXY_OPTS
          mysql -u$DB_USER -p$DB_PWD -h$DB_HOST < del-rtpproxy.sql
          if test $? -ne 0
            then
              echo "ERROR: Could not be added to the database"
              exit 1
          fi
       fi
    fi
fi
echo "you can not connect the $NUM_ETH interfaces."
exit 1

