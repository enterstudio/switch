#!/bin/bash

pid=0

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    echo "stopping container"
    mysql -u$DB_USER -p$DB_PWD -h$DB_HOST < del-rtpproxy.sql
    mysql -u$DB_USER_METRIC -p$DB_PWD_METRIC -h$DB_HOST < del-metric.sql
    sshpass -p $SSH_KAMAILIO_PASSWORD ssh $SSH_KAMAILIO_USER@$KAMAILIO_HOST 'kamctl restart'
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
    mysql -u$DB_USER_METRIC -p$DB_PWD_METRIC -h$DB_HOST < del-metric.sql
    sshpass -p $SSH_KAMAILIO_PASSWORD ssh $SSH_KAMAILIO_USER@$KAMAILIO_HOST 'kamctl restart'
    kill -SIGKILL "$pid"
    wait "$pid"
  fi
  exit 137; # 128 + 9 -- SIGKILL
}

# setup handlers
trap 'term_handler' SIGTERM
trap 'kill_handler' SIGKILL

# run application
sh /docker-entrypoint-init/rtpproxy-autoconfigure.sh &
pid="$!"

wait "$pid"