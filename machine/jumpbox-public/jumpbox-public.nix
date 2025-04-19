{
	hostname = "jumpbox-public";
	network = "external";
	##
	passthrough = {self, ...}: {pkgs, config, modulesPath, ...}: {
		imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
		ec2.efi = true;
		services.tailscale = {
			enable = true;
			openFirewall = true;
			interfaceName = "tailscale0";
			extraUpFlags = [ "--ssh" "--advertise-exit-node" ];
			extraSetFlags = [ "--ssh" "--advertise-exit-node" ];
		};
		networking.nftables.enable = true;
		networking.nftables.ruleset = ''
			table ip nat {
				chain PREROUTING {
					iifname "ens5" \
					ip protocol tcp \
					tcp dport { 80, 443 } \
					dnat to caddy-public
				}
				chain POSTROUTING {
					oifname "tailscale0" \
					ip protocol tcp \
					ip daddr caddy-public \
					tcp dport { 80, 443 } \
					masquerade
				}
			}
		'';
	};
}
