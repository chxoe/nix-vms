#!/bin/bash
set -e
caddy_public=$(tailscale ip -4 caddy-public)
iptables -t nat -A PREROUTING  -j DNAT       -i ens5                 -p tcp -m multiport --dports 80,443 --to-destination $caddy_public
iptables -t nat -A POSTROUTING -j MASQUERADE -o tailscale0 -d $caddy_public -p tcp -m multiport --dports 80,443
