#!/bin/bash
###############################################################################
# Keepalived check script for Hetzner HCloud Floating-IPs
# Usage: check-fip.sh <vrrp_instance_name> <floating-ip>
#
# 1. Checks ENABLED state of "enabled" file. Must be 1 to succeed
# 2. Checks if given Floating-IP is assigned to this node when STATE=MASTER
#    STATE must be set using set-state.sh notify script
###############################################################################

set -e -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/_utils.sh

NAME=$1
FLOATING_IP=$2

if [ -e /etc/keepalived/HCLOUD_TOKEN ]; then
  HCLOUD_TOKEN=$(cat /etc/keepalived/HCLOUD_TOKEN)
fi

[ -z "$NAME" ] && reportFAULT "Error in $0: NAME Parameter is empty"
[ -z "$FLOATING_IP" ] && reportFAULT "Error in $0: FLOATING_IP Parameter is empty"
[ -z "$HCLOUD_TOKEN" ] && reportFAULT "Error in $0: HCLOUD_TOKEN is empty"

# Check Floating-IP assignment

# No state known
[ ! -e /tmp/keepalive_state_${NAME} ] && reportOK

STATE=$(cat /tmp/keepalive_state_${NAME})

if [ -e /tmp/${FLOATING_IP}_ID ]; then
  FLOATING_IP_ID=$(cat /tmp/${FLOATING_IP}_ID)
else
  FLOATING_IP_ID=$(
    (curl -f -sSL \
        --retry 2 --retry-delay 1 \
        -H "Authorization: Bearer ${HCLOUD_TOKEN}" \
        "https://api.hetzner.cloud/v1/floating_ips" \
      | jq ".floating_ips[] | select(.ip == \"${FLOATING_IP}\") | .id") \
      2> >(tee -a /tmp/keepalived_notify.err >&2)
  )
  echo $FLOATING_IP_ID > /tmp/${FLOATING_IP}_ID
fi

ASSIGNED_IP_IDs=$(
  (curl -f -sSL \
      --retry 2 --retry-delay 1 \
      -H "Authorization: Bearer ${HCLOUD_TOKEN}" \
      "https://api.hetzner.cloud/v1/servers?name=${HOSTNAME}" \
    | jq -r  '.servers[0].public_net.floating_ips | @sh') \
    2> >(tee -a /tmp/keepalived_notify.err >&2)
)

# State is not master, no need to check floating-ip assignment
[ "$STATE" != "MASTER" ] && reportOK

# Check if Floating-IP ID is assigned to this server
for F_ID in $ASSIGNED_IP_IDs ; do
  [ "$FLOATING_IP_ID" -eq "$F_ID" ] && reportOK
done

reportFAULT "Floating-IP $FLOATING_IP is not assigned to this node"
