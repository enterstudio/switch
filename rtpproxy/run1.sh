#! /bin/sh
sleep 5
/etc/init.d rtpproxy -A rtpproxy01-ext/rtpproxy01-int -F -f -l 10.200.3.53/rtpproxy01-ext -m 10000 -M 10099 -s udp:*:7711 -d DBUG:LOG_LOCAL0