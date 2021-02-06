#!/usr/bin/env bash

ROTATE_TIME=60 # seconds.

public_ip() {
    WAN_IP=$(curl -s http://whatismyip.akamai.com/)
    echo "[$(date +'%H:%M:%S')] The public IP is ${WAN_IP}."
	echo "[$(date +'%H:%M:%S')] [ProxyServer_X] The public IP is ${WAN_IP}" >> /root/usedip.log # Collects logs for used IPs 
}


echo "[$(date +'%H:%M:%S')] This script changes your WAN_IP every ${ROTATE_TIME} seconds."
expressvpn disconnect >/dev/null 2>&1
echo "[$(date +'%H:%M:%S')] Connection to VPN reset. The public IP without VPN is:"
public_ip
while true
do
    # Select a random VPN location from the 80 fastest ones.
    VPN_LOCATION=$(expressvpn list all | tail -n+3 | head -n 80 | column -t | awk '$1 != "Type" { print }' | cut -d ' ' -f 1 | shuf | head -n 1)
    echo "[$(date +'%H:%M:%S')] New VPN location : ${VPN_LOCATION}."
    echo "[$(date +'%H:%M:%S')] Connecting to the location. It will take a few seconds "
    expressvpn connect ${VPN_LOCATION} >/dev/null 2>&1
    sleep 2 # to make sure the connection
    echo "[$(date +'%H:%M:%S')] Connected to ${VPN_LOCATION}"
    public_ip
    echo "[$(date +'%H:%M:%S')] Waiting for ${ROTATE_TIME} seconds before switching location."
    sleep ${ROTATE_TIME}
    expressvpn disconnect >/dev/null 2>&1
    sleep 2 # to make sure the connection
    echo "[$(date +'%H:%M:%S')] Disconnected."
    # expressvpn status
done