USE `kamailio_db`;
                      
DELETE FROM rtpproxy WHERE url='udp:switch_rtpproxy_1:7711';
                                                           
INSERT INTO rtpproxy (url) VALUES ('udp:switch_rtpproxy_1:7711');
