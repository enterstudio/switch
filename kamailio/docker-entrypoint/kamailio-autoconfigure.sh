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

    # UPDATE /etc/hosts
    if ! [ -f $HOSTS_FILE_BACKUP ]
        then
        cp $HOSTS_FILE $HOSTS_FILE_BACKUP
    fi
    cp $HOSTS_FILE_BACKUP $HOSTS_FILE_AUX
    sed -i 's/'$IP_GWBRIDGE'\s*'$HOSTNAME'/'$IP_GWBRIDGE'        '$HOSTNAME_GWBRIDGE'/g' $HOSTS_FILE_AUX
    sed -i 's/'$IP_OVERLAY'\s*'$HOSTNAME'/'$IP_OVERLAY'        '$HOSTNAME_OVERLAY'/g' $HOSTS_FILE_AUX
    cat $HOSTS_FILE_AUX > $HOSTS_FILE

    /usr/sbin/sshd
    if test $? -ne 0
        then
        echo "ERROR: could not run sshd"
        exit 1
    else
        sed -i 's/#!define PUBLIC_IP \s*.*/#!define PUBLIC_IP  \"'$PUBLIC_IP'\"/g' /etc/kamailio/kamailio.cfg 
        sed -i 's/#!define EXTERNAL_IP \s*.*/#!define EXTERNAL_IP  \"'$IP_GWBRIDGE'\"/g' /etc/kamailio/kamailio.cfg
        if test $? -ne 0
            then
            echo "ERROR: could not config kamailio"
            exit 1
        else
            /usr/sbin/kamailio -P /var/run/kamailio/kamailio.pid -m 64 -M 8 -u kamailio -g kamailio -DD -E -e
        fi
    fi       
fi
echo "you can not connect the $NUM_ETH interfaces."
exit 1
