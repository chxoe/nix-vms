{
	system = "aarch64-linux";
	hostname = "jumpbox-public";
	network = "external";
	##
	passthrough = {configDir, ...}: {pkgs, config, modulesPath, ...}: {
		imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
		ec2.efi = true;
		services.tailscale = {
			enable = true;
			openFirewall = true;
			interfaceName = "tailscale0";
			extraUpFlags = [ "--ssh" "--advertise-exit-node" ];
			extraSetFlags = [ "--ssh" "--advertise-exit-node" ];
		};
		environment.systemPackages = with pkgs; [ iptables ];
		networking.nftables.enable = false;
		networking.firewall.package = pkgs.iptables-legacy;
		systemd.services.jumpbox = {
			enable = true;
			after = [ "network.target" "tailscaled.service" "sys-subsystem-net-devices-tailscale0.device" ];
			serviceConfig = {
				Type="oneshot";
				Restart="on-failure";
				RestartSec=30;
			};
			script = ''
				caddy_public=$(/run/current-system/sw/bin/tailscale ip -4 caddy-public)
				/run/current-system/sw/bin/iptables -t nat -A PREROUTING  -j DNAT       -i ens5                 -p tcp -m multiport --dports 80,443 --to-destination $caddy_public
				/run/current-system/sw/bin/iptables -t nat -A POSTROUTING -j MASQUERADE -o tailscale0 -d $caddy_public -p tcp -m multiport --dports 80,443
			'';
		};
		boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
	};
}
