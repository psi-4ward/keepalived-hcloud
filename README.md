# Keepalived for Kubernetes with Hetzner-Cloud scripts

[![Current Release](https://img.shields.io/github/release/psi-4ward/keepalived-hcloud.svg)](https://github.com/psi-4ward/keepalived-hcloud/releases)
[![Publish Docker image](https://github.com/psi-4ward/keepalived-hcloud/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/psi-4ward/keepalived-hcloud/pkgs/container/keepalived-hcloud)
![Docker Pulls](https://img.shields.io/docker/pulls/psitrax/keepalived-hcloud)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/psitrax/keepalived-hcloud)
![GitHub](https://img.shields.io/github/license/psi-4ward/keepalived-hcloud)

Docker image for keepalived to failover Floating-IPs (of Hetzner Cloud).

* Includes helper scripts to check and handle Floating-IPs
  * `assign-floating-ip.sh`: Assigns a Floating-IP to the current Node
  * `check-fip.sh`: Checks if a Floating-IP is assigned to the current Node
  * `check-http.sh`: Simple HTTP-Check to validate if the upstream proxy is healthy
  * `check-enabled.sh`: Script which fails if `ENABLED=0` is defined to manually put Keepalived in FAULT-mode.
* Includes [prometheus exporter](https://github.com/cafebazaar/keepalived-exporter) (Port 9165)
* Redirects script-outputs to stdout/stderr

## Usage

* Create your [docs/keepalived.conf](keepalived.conf) scripts and mount it to `/etc/keepalived`
* Run the Container/Pod with `HCLOUD_TOKEN` environment variable or (better) put the token in `/etc/keepalived/HCLOUD_TOKEN` secrets file.

* Optional: Configure keepalived-exporter using env-vars
  * `DISABLE_EXPORTER=false`: Set `true` to disable the exporter.
  * `EXPORTER_LISTEN_ADDRESS=:9165`: Listen address/port for prometheus exporter. 

