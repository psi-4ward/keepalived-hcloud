#!/bin/bash -e

# Helper function to uri encode
encodeUriComponent() {
  jq -rn --arg x "$1" '$x|@uri'
}

# Test label selector
LABEL_SELECTOR=$(encodeUriComponent ingress=true)

K8S_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

declare -p PEER_IPS

# Fetch all node-IPs matching the label selector
PEER_IPS=$(curl -f -sSL \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $K8S_TOKEN" \
  https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/nodes?labelSelector=${$LABEL_SELECTOR} \
  | jq -r ".items[].status.addresses[] | select(.type == \"ExternalIP\") | .address" | sort)

# Find lokal Node-IP and IFace
for IP in $PEER_IPS ; do
  IFACE=$(ip -br -4 addr show | grep $IP | awk '{print $1}')
  if [ -n "${IFACE}" ]; then
    NODE_IP=$IP
    break;
  fi
done

if [ -z "$NODE_IP" ] ; then
  >&2 echo "ERROR: Could not find any interface with for $PEER_IPS"
  exit 1
fi
