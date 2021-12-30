#!/bin/bash

URL=$1

function reportOK() {
  exit 0
}
function reportFAULT() {
  echo "Check HTTP $URL failed: $1" > >(tee -a /tmp/keepalived_notify.err >&2)
  exit 1
}

[ -z "$URL" ] && reportFAULT "URL Parameter is empty"

RES=$(curl -fsSI -m 1 -o /dev/null $URL 2>&1)
[ "$?" -gt 0 ] && reportFAULT "$RES" || reportOK
