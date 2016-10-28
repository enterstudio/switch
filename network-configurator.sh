#!/bin/bash


# Podría añadir la instalación de paquetes necesarios para correr este script según el sistema operativo,
# de esta forma el script sería genérico
# lo suyo sería prepararlo para ubuntu, debian, centos y alpine, que son las distribuciones más usadas para containers
# 
# De momento, paquetes a instalar: sipcalc y net-tools(para tener ifconfig)
if [ -f /etc/debian_version]
    then
    apt-get -y install sipcalc net-tools
else
    echo "This script is not valid for this Linux distribution."
fi

IP_REGEXP='^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]).){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'
if ! [[ $SUBNET_OVERLAY =~ $IP_REGEXP ]]
    then
    echo "subnet overlay is wrong"
    exit -1
fi

TIMEOUT_REGEXP='^[0-9]+$'
if ! [[ $TIMEOUT =~ $TIMEOUT_REGEXP ]]
    then
    echo "timeout is wrong"
    exit -1
fi

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

NUM_ETH=2
COUNT_ETH=$(ifconfig | grep -ce "^eth[0-9]\+")

TIME_INIT=$(date +%s%N)
TIME=$(($(date +%s%N) - $TIME_INIT))
TIME_END=$(($TIMEOUT * 1000000))

while [ $COUNT_ETH -ne $NUM_ETH ] && [ $TIME -lt $TIME_END ]
do
    $TIME=$(($(date +%s%N) - $TIME_INIT))
    $COUNT_ETH=$(ifconfig | grep -ce "^eth[0-9]\+")
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
            exit -1

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

    cp $HOSTS_FILE $HOSTS_FILE_AUX
    sed -i 's/'$IP_GWBRIDGE'\s*'$HOSTNAME'/'$IP_GWBRIDGE'        '$HOSTNAME_GWBRIDGE'/g' $HOSTS_FILE_AUX
    sed -i 's/'$IP_OVERLAY'\s*'$HOSTNAME'/'$IP_OVERLAY'        '$HOSTNAME_OVERLAY'/g' $HOSTS_FILE_AUX
    echo $(cat $HOSTS_FILE_AUX) > $HOSTS_FILE
    
    # Último paso: arrancar el servicio
    # sería buena idea usar el script en el entrypoint del dockerfile
    # y pasar el comando de arranque del servicio como argumento con el cmd
    # de esta forma quedaría más genérico el script
    $@
    exit 0
fi
echo "you can not connect the $NUM_ETH interfaces."
exit -1
