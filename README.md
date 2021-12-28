# Keepalived for Kubernetes with Hetzner-Cloud scripts

[![Current Release](https://img.shields.io/github/release/psi-4ward/keepalived-hcloud.svg)](https://github.com/psi-4ward/keepalived-hcloud/releases)
[![Github Stars](https://img.shields.io/github/stars/psi-4ward/keepalived-hcloud.svg?style=social&label=Star)](https://github.com/psi-4ward/keepalived-hcloud)
[![Docker Stars](https://img.shields.io/docker/stars/psitrax/keepalived-hcloud.svg)](https://hub.docker.com/r/psitrax/keepalived-hcloud/)
[![Publish Docker image](https://github.com/psi-4ward/keepalived-hcloud/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/psi-4ward/keepalived-hcloud/actions/workflows/docker-publish.yml)

Docker image to run keepalived to failover Floating-IPs (of Hetzner Cloud).

* Includes helper scripts to check and handle Floating-IPs
* Includes [prometheus exporter](https://github.com/cafebazaar/keepalived-exporter) (Port 9165)
* Redirects script-outputs to stdout

## Usage

* Create your [docs/keepalived.conf](keepalived.conf) scripts and mount it to `/etc/keepalived`
* Run the Container/Pod with `HCLOUD_TOKEN` environment variable or (better) put the token in `/etc/keepalived/HCLOUD_TOKEN` secrets file.

* Optional: Configure keepalived-exporter using env-vars
  * `DISABLE_EXPORTER=false`: Set `true` to disable the exporter.
  * `EXPORTER_LISTEN_ADDRESS=:9165`: Listen address/port for prometheus exporter. 


## TODO / Idea

TBDC ...

Since the HCloud-Token is known to fetch available Floating-IPs and Servers all required 
information are available to auto-generate the keepalived config:

* Determine some labels to match hcloud resources
* Fetch all Floating-IPs (filtered by lables)
* Fetch all Server(-IPs) (filtered by lables)
* Find the network-interface wich binds one of public server-IPs
* Find all configured Floating-IPs on this iface
* Generate a keepalived.conf using this information for each Floating-IP
  * Treat the node as _MASTER_ when `serverIps.indexOf(serverIp) == floatingIPs.indexOf(floatingIps) % serverIps.length`
  * else as _BACKUP_ with `priority = 100 - serverIps.indexOf(serverIp)`
