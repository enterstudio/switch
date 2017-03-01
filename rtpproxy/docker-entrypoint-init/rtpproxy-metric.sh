#!/bin/bash

IP_GWBRIDGE=$1
TOTAL_PORTS=$(expr $PORT_MAX - $PORT_MIN + 1)

while true
do
    ACTIVE_PORTS=$(netstat -na | grep -c $IP_GWBRIDGE)
    FREE_PORTS=$(expr $TOTAL_PORTS - $ACTIVE_PORTS)

    echo "Active_Ports: $ACTIVE_PORTS
Free_Ports: $FREE_PORTS
Total_Ports: $TOTAL_PORTS" >> /metric/ports.metric

    sleep $METRIC_PERIOD
done
