#!/bin/bash
###############################################################################
# Keepalived notify script to persist current state in a file
# Usage: set-state.sh <type> <vrrp_instance_name> <state>
###############################################################################

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/_utils.sh

# $1 = “GROUP” or “INSTANCE”
# $2 = name of group or instance
# $3 = target state of transition (“MASTER”, “BACKUP”, “FAULT”)

TYPE=$1
NAME=$2
STATE=$3

echo $STATE > /tmp/keepalive_state_${NAME}
report Keepalived state changed: $NAME=$STATE
