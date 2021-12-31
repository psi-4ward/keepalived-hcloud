#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/_utils.sh

source /etc/keepalived/enabled

if [ "$ENABLED" != "1" ] ; then
  reportFAULT "Keepalived is disabled by file-flag"
fi
