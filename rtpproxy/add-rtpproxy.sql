USE `--DB_KAMAILIO--`;

DELETE FROM rtpproxy WHERE setid=--HOSTNAME--;

INSERT INTO rtpproxy (setid,url) VALUES (--HOSTNAME--,udp:--HOSTNAME--:--PORT_RTPPROXY--);