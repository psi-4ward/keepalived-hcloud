#!/bin/bash

function report() {
  echo "$(date -Iseconds): $*" | tee -a /tmp/keepalived_notify.log
}

function reportOK() {
  [ -n "$*" ] && report $*
  exit 0
}

function reportFAULT() {
  # Don't repeat log lines
  if [ "$(tail -n 1 /tmp/keepalived_notify.err)" != "$*" ] ; then
    echo "$*" > >(tee -a /tmp/keepalived_notify.err >&2)
  fi
  exit 1
}

function hcloud_curl() {
  RES=$(curl -fsSL --retry 2 --retry-delay 1 -H "Authorization: Bearer ${HCLOUD_TOKEN}" "$1" 2>&1)
  [ "$?" -gt 0 ] && reportFAULT "Error requesting $1: $RES"
  echo "$RES" | jq -r "$2"
}
