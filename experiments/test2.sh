#!/bin/bash
set -e

#LOCATION=nbg1
#LABEL=ingress

if [ -z "$HCLOUD_TOKEN" ]; then
  >&2 echo "ERROR: HCLOUD_TOKEN env var not defined"
  exit 1
fi

FLOATING_IPs=$(
  curl -f -sSL \
      -H "Authorization: Bearer ${HCLOUD_TOKEN}" \
      "https://api.hetzner.cloud/v1/floating_ips" \
    | jq -r ".floating_ips[] | .ip" \
    | sort
)
# | select(.home_location.name == \"${LOCATION}\" and .labels.${LABEL})

if [ -z "${FLOATING_IPs}" ]; then
  >&2 echo "ERROR: No Floating-IPs found"
  exit 1
fi

echo "HCloud Floating-IPs:" $FLOATING_IPs

PEER_IPs=$(
  curl -f -sSL \
      -H "Authorization: Bearer ${HCLOUD_TOKEN}" \
      "https://api.hetzner.cloud/v1/servers" \
    | jq -r ".servers[] | .public_net.ipv4.ip" \
    | sort
)
# | select(.datacenter.location.name == \"${LOCATION}\" and .labels.ingress)

if [ -z "${PEER_IPs}" ]; then
  >&2 echo "ERROR: No Peer-IPs found"
  exit 1
fi

# Find local Node-IP and IFace
for IP in ${PEER_IPs} ; do
  IFACE=$(ip -br -4 addr show | grep $IP | awk '{print $1}')
  if [ -n "${IFACE}" ]; then
    NODE_IP=$IP
    break;
  fi
done

if [ -z "${IFACE}" ]; then
  >&2 echo "ERROR: No interface found which binds any of the peer IPs"
  exit 1
fi

echo "Found Public-IP $NODE_IP on $IFACE"

IFACE_IPs=$( ip -json a s dev $IFACE | jq -r '.[] | .addr_info[] | select(.family == "inet") | .local' )

BOUND_FLOATING_IPs=""
for FIP in ${FLOATING_IPs} ; do
  if echo "$IFACE_IPs" | grep -qF $FIP; then
    echo "Found Floating IP $FIP on $IFACE"
    BOUND_FLOATING_IPs="${BOUND_FLOATING_IPs} $FIP"
  fi
done

#echo $(IndexOf 162.55.213.182 ${PEER_IPs[@]})
