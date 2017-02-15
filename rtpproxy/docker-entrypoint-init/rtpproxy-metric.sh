#!/bin/bash

IP_GWBRIDGE=$1
TOTAL_PORTS=$(expr $PORT_MAX - $PORT_MIN + 1)

while true
do
    ACTIVE_PORTS=$(netstat -na | grep -c $IP_GWBRIDGE)
    FREE_PORTS=$(expr $TOTAL_PORTS - $ACTIVE_PORTS)

    echo "Active Ports: $ACTIVE_PORTS" > /metric/ports.metric
    echo "Free Ports: $FREE_PORTS" >> /metric/ports.metric
    echo "Total ports: $TOTAL_PORTS" >> /metric/ports.metric

    sleep $METRIC_PERIOD
done
