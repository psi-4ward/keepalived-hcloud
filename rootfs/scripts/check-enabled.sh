#!/bin/bash

source /etc/keepalived/enabled

if [ "$ENABLED" != "1" ] ; then
  echo "keepalived is disabled by file-flag" > >(tee -a /tmp/keepalived_notify.err >&2)
  exit 1
fi
