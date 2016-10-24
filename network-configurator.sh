#!/bin/bash


# Podría añadir la instalación de paquetes necesarios para correr este script según el sistema operativo,
# de esta forma el script sería genérico
# lo suyo sería prepararlo para ubuntu, debian, centos y alpine, que son las distribuciones más usadas para containers
# 
# De momento, paquetes a instalar: sipcalculator, bc o expr y net-tools(para tener ifconfig)

# TIMEOUT milliseconds 
TIMEOUT=$TIMEOUT

HOSTNAME=$HOSTNAME

IP_OVERLAY
MASK_OVERLAY
SUBNET_OVERLAY=$SUBNET_OVERLAY
SUFFIX_OVERLAY=$SUFFIX_OVERLAY
# HOSTNAME_OVERLAY=${HOSTNAME}-${SUFFIX_OVERLAY}

# Si sufijo está vacio: HOSTNAME_OVERLAY=${HOSTNAME}
# si sufijo no está vacio: HOSTNAME_OVERLAY=${HOSTNAME}"-"${SUFFIX_OVERLAY}
if [#$SUFFIX_OVERLAY -ne 0]
    then
    HOSTNAME_OVERLAY=${HOSTNAME}"-"$SUFFIX_OVERLAY
else
    HOSTNAME_OVERLAY=$HOSTNAME
if

IP_GWBRIDGE
MASK_GWBRIDGE
SUBNET_GWBRIDGE
SUFFIX_GWBRIDGE=$SUFFIX_GWBRIDGE

if [#$SUFFIX_GWBRIDGE -ne 0]
    then
    HOSTNAME_GWBRIDGE=${HOSTNAME}"-"$SUFFIX_GWBRIDGE
else
    HOSTNAME_GWBRIDGE=$HOSTNAME
if

# HOSTNAME_GWBRIDGE=$HOSTNAME-$SUFFIX_GWBRIDGE
 
# SUBNET_GWBRIDGE="-"$SUFFIX_GWBRIDGE
# HOSTNAME_GWBRIDGE=$HOSTNAME$SUFFIX_GWBRIDGE

# HOSTNAME_GWBRIDGE=$HOSTNAME
# HOSTNAME_GWBRIDGE+="-"
# HOSTNAME_GWBRIDGE+=$SUFFIX_GWBRIDGE
 
#HOSTNAME_GWBRIDGE=${HOSTNAME}"-"${SUFFIX_GWBRIDGE}

HOSTS_FILE=/etc/hosts
HOSTS_FILE_AUX=$HOST_FILE.aux

NUM_ETH=2
COUNT_ETH=$(ifconfig | grep -ce "^eth[0-9]\+")

# Debería comprobar que SUBNET_OVERLAY y TIMEOUT existe

#SECONDS=$(echo "scale=3; $TIMEOUT/1000" | bc)
TIME_INIT=$(date +%s%N)
# resta=`expr $x - $y`
TIME='expr $(date +%s%N) - $TIME_INIT'
#TIME_END=$(echo "$TIMEOUT*1000000" | bc)
TIME_END=$(expr '${TIMEOUT}\*1000000')


while [[COUNT_ETH -ne NUM_ETH] && [TIME -lt TIME_END]]
do
    TIME='expr $(date +%s%N) - $TIME_INIT'
    COUNT_ETH=$(ifconfig | grep -ce "^eth[0-9]\+")
done

if [COUNT_ETH -eq NUM_ETH]
    then
    IP_ETH0=$(ifconfig eth0 | awk '/inet addr/{split($2,a,":"); print a[2]}')
    IP_ETH1=$(ifconfig eth1 | awk '/inet addr/{split($2,a,":"); print a[2]}')
    MASK_ETH0=$(ifconfig eth0 | awk '/Mask:/{split($4,a,":"); print a[2]}')
    MASK_ETH1=$(ifconfig eth1 | awk '/Mask:/{split($4,a,":"); print a[2]}')
    SUBNET_ETH0=$(sipcalc $IP_ETH0 $MASK_ETH0|awk '/Network address/{split($4,a,"-"); print a[1]}')
    SUBNET_ETH1=$(sipcalc $IP_ETH1 $MASK_ETH1|awk '/Network address/{split($4,a,"-"); print a[1]}')

        if [SUBNET_OVERLAY == SUBNET_ETH0]
            then
            IP_OVERLAY=$IP_ETH0
            MASK_OVERLAY=$MASK_ETH0
            IP_GWBRIDGE=$IP_ETH1
            MASK_GWBRIDGE=$MASK_ETH1
        else
            IP_OVERLAY=$IP_ETH1
            MASK_OVERLAY=$MASK_ETH1
            IP_GWBRIDGE=$IP_ETH0
            MASK_GWBRIDGE=$MASK_ETH0
        fi
    export IP_OVERLAY
    export MASK_OVERLAY
    export IP_GWBRIDGE
    export MASK_GWBRIDGE
    cp /etc/hosts /etc/hosts.new
    sed -i 's/'$IP_GWBRIDGE'\s*'$HOSTNAME'/'$IP_GWBRIDGE'        '$HOSTNAME_GWBRIDGE'/g' /etc/hosts.new
    sed -i 's/'$IP_OVERLAY'\s*'$HOSTNAME'/'$IP_OVERLAY'        '$HOSTNAME_OVERLAY'/g' /etc/hosts.new
    echo $(cat hosts.new) > /etc/hosts

    # Último paso: arrancar el servicio
    # sería buena idea usar el script en el entrypoint del dockerfile
    # y pasar el comando de arranque del servicio como argumento con el cmd
    # de esta forma quedaría más genérico el script
fi


# si no subnet_overlay o suffix_overlay o timeout entonces error
# comprueba numero de redes eth, si no son dos sigue comprobando hasta que se agote timeout. si se agota y no = 2 => fin
#   Para comprobar el número de redes eth: ifconfig | grep -ce "^eth[0-9]\+"
#   Para comprobar time usa: date +%s%N TIME=$(date +%s%N)-$TIME_INIT
#
# IP_ETH0=$(ifconfig eth0 | awk '/inet addr/{split($2,a,":"); print a[2]}')
# IP_ETH1=$(ifconfig eth1 | awk '/inet addr/{split($2,a,":"); print a[2]}')
# MASK_ETH0=$(ifconfig eth0 | awk '/Mask:/{split($4,a,":"); print a[2]}')
# MASK_ETH1=$(ifconfig eth1 | awk '/Mask:/{split($4,a,":"); print a[2]}')
# SUBNET_ETH0=$(sipcalc $IP_ETH0 $MASK_ETH0|awk '/Network address/{split($4,a,"-"); print a[1]}')
# SUBNET_ETH1=$(sipcalc $IP_ETH1 $MASK_ETH1|awk '/Network address/{split($4,a,"-"); print a[1]}')
# 
# Si SUBNET_ETH0 == SUBNET_OVERLAY entonces es la overlay
#   IP_OVERLAY=$IP_ETH0
#   MASK_OVERLAY=$MASK_ETH0
#   IP_GWBRIDGE=$IP_ETH1
#   MASK_GWBRIDGE=$MASK_ETH1
# sino, es la gwbridge
#   IP_OVERLAY=$IP_ETH1
#   MASK_OVERLAY=$MASK_ETH1
#   IP_GWBRIDGE=$IP_ETH0
#   MASK_GWBRIDGE=$MASK_ETH0
#   
# Cambiamos /etc/hosts. (Ojo, el comando sed no funciona -> error: Device or resource busy)
#   cp /etc/hosts /etc/hosts.new
#   sed -i 's/'$IP_GWBRIDGE'\s*'$HOSTNAME'/'$IP_GWBRIDGE'        '$HOSTNAME'-'$SUFFIX_GWBRIDGE/g' /etc/hosts.new
#   sed -i 's/'$IP_OVERLAY'\s*'$HOSTNAME'/'$IP_OVERLAY'        '$HOSTNAME'-'$SUFFIX_OVERLAY/g' /etc/hosts.new
#   echo $(cat hosts.new) > /etc/hosts