#!/bin/bash
set -eo pipefail

if [ "$1" == "keepalived" ] ; then
  [ ! -e /etc/keepalived/enabled ] && echo 'ENABLED=1' > /etc/keepalived/enabled

  touch /tmp/keepalived_notify.log
  (tail -f /tmp/keepalived_notify.log > /dev/stdout)&
  PIDS="$! $PIDS"

  touch /tmp/keepalived_notify.err
  (tail -f /tmp/keepalived_notify.err > /dev/stderr)&
  PIDS="$! $PIDS"

  # Run keepalived as defined in CMD
  $@ &
  PIDS="$! $PIDS"

  if ! $DISABLE_EXPORTER; then
    /keepalived-exporter \
      --ka.pid-path /var/run/keepalived/keepalived.pid \
      --web.listen-address $EXPORTER_LISTEN_ADDRESS \
      &
    PIDS="$! $PIDS"
  fi

  set +e

  function gracefulShutdown {
    for PID in $PIDS ; do
      if [ -e /proc/$PID/status ]; then
        kill -s $1 $PID
      fi
    done
  }
  trap "gracefulShutdown SIGHUP" SIGHUP
  trap "gracefulShutdown SIGINT" SIGINT
  trap "gracefulShutdown SIGTERM" SIGTERM

  wait -n $PIDS
  E=$?

  gracefulShutdown SIGTERM

  wait $PIDS
  [ -n "$E" ] && exit $E
else
  exec "$@"
fi
