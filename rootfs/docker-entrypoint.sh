#!/bin/bash -e

if [ "$1" == "keepalived" ] ; then
  [ ! -e /etc/keepalived/enabled ] && echo 'ENABLED=1' > /etc/keepalived/enabled

  touch /tmp/keepalived_notify.log

  touch /tmp/keepalived_notify.log
  (tail -f /tmp/keepalived_notify.log > /dev/stdout)&

  $DISABLE_EXPORTER || /keepalived-exporter \
    --ka.pid-path /var/run/keepalived/keepalived.pid \
    --web.listen-address $EXPORTER_LISTEN_ADDRESS \
    &
fi

exec "$@"
