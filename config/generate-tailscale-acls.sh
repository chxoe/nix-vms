#!/bin/bash
jq -n -f $1 \
	--arg host    "$(tailscale ip -4 host)" \
	--arg jumpbox "$(tailscale ip -4 jumpbox)" \
	--arg caddy   "$(tailscale ip -4 caddy)"
