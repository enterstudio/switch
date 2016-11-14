USE `--DB_KAMAILIO--`;
                      
DELETE FROM --TABLE_RTPPROXY--  WHERE url='udp:--HOSTNAME--:--PORT_RTPPROXY--';
                                                           
INSERT INTO --TABLE_RTPPROXY--  (url) VALUES ('udp:--HOSTNAME--:--PORT_RTPPROXY--');
