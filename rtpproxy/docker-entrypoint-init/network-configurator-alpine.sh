#!/bin/bash
echo "Entro en network-configurator-alpine.sh"

if [ -f /etc/debian_version ]
    then
    apt-get -y install sipcalc net-tools
elif [ -f /etc/alpine-release ]
    then
    apk add --update sipcalc bind bind-tools && rm -rf /var/cache/apk/*
else
    echo "This script is not valid for this Linux distribution."
fi

(echo "$SUBNET_OVERLAY" | grep -Eq "$IP_REGEXP") && echo "subnet overlay is $SUBNET_OVERLAY" || (echo "subnet overlay is wrong" && exit 1)
(echo "$TIMEOUT" | grep -Eq "$TIMEOUT_REGEXP") && echo "timeout is $TIMEOUT millisecond" || (echo "timeout is wrong" && exit 1)

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

NUM_ETH=2
COUNT_ETH=$(ifconfig | grep -cE "^eth[0-9]+")

TIME_INIT=$(date +%s%N)
TIME=$(($(date +%s%N) - $TIME_INIT))
TIME_END=$(($TIMEOUT * 1000000))

while [ $COUNT_ETH -ne $NUM_ETH ] && [ $TIME -lt $TIME_END ]
do
    $TIME=$(($(date +%s%N) - $TIME_INIT))
    $COUNT_ETH=$(ifconfig | grep -cE "^eth[0-9]+")
done

if [ $COUNT_ETH -eq $NUM_ETH ]
    then
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

    export ETH_OVERLAY=$ETH_OVERLAY
    export IP_OVERLAY=$IP_OVERLAY
    export MASK_OVERLAY=$MASK_OVERLAY
    export HOSTNAME_OVERLAY=$HOSTNAME_OVERLAY

    export ETH_GWBRIDGE=$ETH_GWBRIDGE
    export IP_GWBRIDGE=$IP_GWBRIDGE
    export MASK_GWBRIDGE=$MASK_GWBRIDGE
    export SUBNET_GWBRIDGE=$SUBNET_GWBRIDGE
    export HOSTNAME_GWBRIDGE=$HOSTNAME_GWBRIDGE

    export HOSTNAME_EXTERNAL_OVERLAY=$(host $IP_OVERLAY | awk '/pointer/{split($5,a,"."); print a[1]}')
    export RTPPROXY_OPTS=$(echo "-A $IP_GWBRIDGE/$IP_OVERLAY -F -f -l $PUBLIC_IP/$IP_GWBRIDGE -m $PORT_MIN -M $PORT_MAX -s udp:*:$PORT_RTPPROXY -d DBUG:LOG_LOCAL0")

    if ! [ -f $HOSTS_FILE_BACKUP ]
        then
        cp $HOSTS_FILE $HOSTS_FILE_BACKUP
    fi
    cp $HOSTS_FILE_BACKUP $HOSTS_FILE_AUX
    sed -i 's/'$IP_GWBRIDGE'\s*'$HOSTNAME'/'$IP_GWBRIDGE'        '$HOSTNAME_GWBRIDGE'/g' $HOSTS_FILE_AUX
    sed -i 's/'$IP_OVERLAY'\s*'$HOSTNAME'/'$IP_OVERLAY'        '$HOSTNAME_OVERLAY'/g' $HOSTS_FILE_AUX
    echo $(cat $HOSTS_FILE_AUX) > $HOSTS_FILE
    
    echo " finalizando network-configurator-alpine.sh"
    exec $@
    exit 0
fi
echo "you can not connect the $NUM_ETH interfaces."
exit 1

