#!/bin/bash
###############################################################################
# Keepalived check script to monitor a simple http-endpoint
# Usage: check-http.sh <url>
###############################################################################

URL=$1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/_utils.sh

[ -z "$URL" ] && reportFAULT "Error $0: URL Parameter is empty"

RES=$(curl -fsSI -m 1 -o /dev/null $URL 2>&1)
[ "$?" -gt 0 ] && reportFAULT "Error $0: $RES" || reportOK
