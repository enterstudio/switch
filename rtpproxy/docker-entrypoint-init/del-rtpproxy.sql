USE `--DB_KAMAILIO--`;
                      
DELETE FROM --TABLE_RTPPROXY--  WHERE url='udp:--HOSTNAME--:--PORT_RTPPROXY--';