#!/bin/bash

# En el dockerfile tengo que pedir las siguientes variables de entorno:
# nombre de usuario de la base de datos:
# contraseña de usuario de la base de datos:
# hostname de la base de datos:
# nombre de la base de datos a modificar:
# tabla de la base de datos a modificar:
# puertos donde escucha el rtpproxy a kamailio:

echo "iniciando db-client.sh"

echo "iniciando sustitucion con sed"

sed -i 's/--HOSTNAME--\s*/'$HOSTNAME_EXTERNAL_OVERLAY'/g' add-rtpproxy.sql
sed -i 's/--DB_KAMAILIO--\s*/'$DB_KAMAILIO'/g' add-rtpproxy.sql
sed -i 's/--PORT_RTPPROXY--\s*/'$PORT_RTPPROXY'/g' add-rtpproxy.sql
sed -i 's/--TABLE_RTPPROXY--\s/'$TABLE_RTPPROXY'/g' add-rtpproxy.sql

echo "aplicando cambios en db"

# podríamos enviar los comandos directamente para no tener que copiar el add-rtpproxy.sql y modificarlo con el sed
echo "mysql -u$DB_USER -p$DB_PWD -h$DB_HOST < add-rtpproxy.sql"
mysql -u$DB_USER -p$DB_PWD -h$DB_HOST < add-rtpproxy.sql

echo "finalizando db-client.sh"

$@
exit 0
