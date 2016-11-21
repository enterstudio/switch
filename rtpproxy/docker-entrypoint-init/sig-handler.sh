#!/usr/bin/env bash
set -x

pid=0

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    echo "stopping container"
    mysql -u$DB_USER -p$DB_PWD -h$DB_HOST < del-rtpproxy.sql
    sshpass -p docker ssh root@kamailio-c 'kamctl restart'
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

# SIGKILL-handler
kill_handler() {
  if [ $pid -ne 0 ]; then
    echo "killing container"   
    mysql -u$DB_USER -p$DB_PWD -h$DB_HOST < del-rtpproxy.sql
    sshpass -p docker ssh root@kamailio-c 'kamctl restart'
    kill -SIGKILL "$pid"
    wait "$pid"
  fi
  exit 137; # 128 + 9 -- SIGKILL
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'echo "pid bucle ${!}"; kill ${!}; term_handler' SIGTERM
trap 'echo "pid bucle ${!}"; kill ${!}; kill_handler' SIGKILL

# run application
$@ &
pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
