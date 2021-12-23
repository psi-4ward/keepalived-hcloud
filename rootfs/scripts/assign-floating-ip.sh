#!/bin/bash
##########################################################################
# Script to assign a Floating-IP to this host
# Usage: assign-floating-ip.sh <floating-ip>
###############################################################################

set -e -o pipefail

FLOATING_IP="$1"
HOSTNAME=$(hostname)

echo $(date -Iseconds): Start assigning $FLOATING_IP to $HOSTNAME | tee -a /tmp/keepalived_notify.log

if [ -z "${FLOATING_IP}" ]; then
  echo "ERROR: First argument of $0 should be the floating-ip." | tee -a /tmp/keepalived_notify.log
  exit 1
fi

if [ -z "${HCLOUD_TOKEN}" ]; then
  echo "ERROR: ENV-Var HCLOUD_TOKEN is not set." | tee -a /tmp/keepalived_notify.log
  exit 1
fi

SERVER_ID=$(curl -f -sSL -H "Authorization: Bearer ${HCLOUD_TOKEN}" "https://api.hetzner.cloud/v1/servers?name=${HOSTNAME}" | jq .servers[0].id)

FLOATING_IP_ID=$(curl -f -sSL -H "Authorization: Bearer ${HCLOUD_TOKEN}" "https://api.hetzner.cloud/v1/floating_ips" | jq ".floating_ips[] | select(.ip == \"${FLOATING_IP}\") | .id")

curl -f -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${HCLOUD_TOKEN}" \
  -d "{ \"server\": ${SERVER_ID} }" \
  "https://api.hetzner.cloud/v1/floating_ips/${FLOATING_IP_ID}/actions/assign"

echo $(date -Iseconds): Assigned $FLOATING_IP to $HOSTNAME | tee -a /tmp/keepalived_notify.log