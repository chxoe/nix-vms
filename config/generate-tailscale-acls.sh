#!/run/current-system/sw/bin/bash
jq -n -f $1 \
	--arg host    "$(tailscale ip -4 host)" \
	--arg jumpbox "$(tailscale ip -4 jumpbox)" \
	--arg caddy   "$(tailscale ip -4 caddy)" \
	--arg zitadel "$(tailscale ip -4 zitadel)" \
	--arg misc_trusted "$(tailscale ip -4 misc-trusted)" \
	--arg jumpbox_public "$(tailscale ip -4 jumpbox-public)" \
	--arg caddy_public "$(tailscale ip -4 caddy-public)"
