#!/bin/bash

# En el dockerfile tengo que pedir las siguientes variables de entorno:
# nombre de usuario de la base de datos:
# contraseña de usuario de la base de datos:
# hostname de la base de datos:
# nombre de la base de datos a modificar:
# tabla de la base de datos a modificar:
# puertos donde escucha el rtpproxy a kamailio:

sed -i 's/--HOSTNAME--\s*/'$HOSTNAME'/g' add-retpproxy.sql
sed -i 's/--DB_KAMAILIO--\s*/'$DB_KAMAILIO'/g' add-retpproxy.sql
sed -i 's/--PORT_RTPPROXY--\s*/'$PORT_RTPPROXY'/g' add-retpproxy.sql

# podríamos enviar los comandos directamente para no tener que copiar el add-rtpproxy.sql y modificarlo con el sed
mysql -u $DB_USER -p $DB_PWD -h $DB_HOST < add-rtpproxy.sql

$@
exit 0