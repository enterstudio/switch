#! /bin/sh
sleep 5
/etc/init.d rtpproxy -A rtpproxy02-ext/rtpproxy02-int -F -f -l 10.200.3.59/rtpproxy02-ext -m 10100 -M 10199 -s udp:*:7722 -d DBUG:LOG_LOCAL0