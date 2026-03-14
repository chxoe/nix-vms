#!/bin/bash
caddy=$(tailscale ip -4 caddy)
iptables -t nat -A PREROUTING  -j DNAT       -i ens5                 -p tcp -m multiport --dports 80,443 --to-destination $caddy
iptables -t nat -A POSTROUTING -j MASQUERADE -o tailscale0 -d $caddy -p tcp -m multiport --dports 80,443
