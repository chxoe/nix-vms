{
	system = "aarch64-linux";
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
		networking.nftables.enable = false;
		systemd.services.jumpbox = {
			enable = true;
			serviceConfig = {
				ExecStart = "{self}/iptables.sh";
				Type="oneshot";
				Restart="on-failure";
				RestartSec=30;
				After="network.target tailscaled.service sys-subsystem-net-devices-tailscale0.device";
			};
		};
		boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
	};
}
